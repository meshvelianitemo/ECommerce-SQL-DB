USE ECommerce;
GO 



CREATE PROCEDURE sp_AddOrderItem
	@orderID INT ,
	@productID INT,	
	@quantity INT
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartedTran BIT = 0;
	
	BEGIN TRY
		IF @@TRANCOUNT = 0
		BEGIN 
			BEGIN TRAN;
			SET @StartedTran = 1;
		END
		--VALIDATING INPUT QUANTITY 
		IF @quantity <=0 
			THROW 51001, 'Quantity must be greater than zero.',1;	

		-- VALIDATING THAT PRODUCT EXISTS AND HAS STOCK
		IF NOT EXISTS (
			SELECT 1
			FROM Products
			WHERE ProductId = @productID
			AND	StockQuantity >= @quantity
			AND IsDiscontinued = 0
		)
			THROW 51002, 'Product does not exist, is discontinued, or insufficient stock.', 1;
	
		-- PREVENTING DUPLICATE ORDERS
		IF EXISTS (
		SELECT 1
		FROM OrderItems
		WHERE OrderId = @orderID
		AND ProductId = @productID
		)
		THROW 51003, 'Product already exists in this order.',1;

		INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice)
			SELECT 
				@orderID, @productID, @quantity, UnitPrice
				FROM Products 
				WHERE ProductId = @productID;

			IF @StartedTran =1
				COMMIT;
	END TRY
	BEGIN CATCH
		IF @StartedTran = 1 AND @@TRANCOUNT > 0
        ROLLBACK;
			
			
		THROW;
	END CATCH
END;
GO



CREATE PROCEDURE sp_CancelOrder
@orderID INT ,
@customerID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartedTran BIT = 0

	BEGIN TRY
		IF @@TRANCOUNT = 0
		BEGIN 
			BEGIN TRAN;
			SET @StartedTran = 1;
		END

		--VALIDATING USER
		IF NOT EXISTS (
		SELECT 1 FROM Customers
		WHERE CustomerId  =@customerID
		) 
			THROW 51004, 'Customer with this CustomerId Does not exist.',1;

		--VALIDATING THAT THIS USER HAS THIS ORDER 
		IF NOT EXISTS (
		SELECT 1 FROM Orders
		WHERE OrderId  =@orderID AND CustomerId = @customerID AND OrderStatusId <> 1005
		) 
			THROW 51005, 'order with this OrderId Does not exist or is already cancelled.',1;
		
		-- GET ITEMS LINKED TO THIS ORDER 
		DECLARE @items TABLE (ProductId INT ,Quantity INT);

		INSERT INTO @items(ProductId, Quantity)
		SELECT oi.ProductId, oi.Quantity
		FROM OrderItems oi
		WHERE oi.OrderId = @orderID


		-- UPDATE PRODUCT STOCK

		UPDATE p
		SET StockQuantity =StockQuantity + i.Quantity
		FROM Products p
		JOIN 
		@items i
		ON p.ProductId= i.ProductId

		-- MARK ORDER'S STATUS AS CANCELLED

		UPDATE Orders
		SET OrderStatusId = (SELECT OrderStatusId FROM OrderStatus WHERE StatusName = 'Cancelled')
		WHERE OrderId = @orderID

			IF @StartedTran =1
				COMMIT;
	END TRY
	BEGIN CATCH 
	IF @StartedTran = 1 AND @@TRANCOUNT > 0
        ROLLBACK;
			
			
		THROW;
	END CATCH
END;
GO




CREATE PROCEDURE sp_RestockProducts
@ProductID INT, @RestockQuantity INT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		

			--VALIDATING THAT PRODUCT WITH THIS ID EXISTS AND ISNT DISCONTINUED
			IF NOT EXISTS (
				SELECT 1 
				FROM Products 
				WHERE ProductId = @ProductID AND IsDiscontinued = 0)
				THROW 51006, 'This Product does not exist or is discontinued',1;
		
			--CHECKING THAT INPUT RESTOCKING QUANTITY IS GREATER THAN ZERO
			IF @RestockQuantity <=0 
				THROW 51007, 'Restock quantity must be greater than zero',1;
		BEGIN TRAN
			UPDATE Products WITH (UPDLOCK, ROWLOCK)
				SET StockQuantity = StockQuantity + @RestockQuantity
				WHERE ProductId = @ProductID;
			
			--LOGGING THIS IN INVENTORY TABLE
			INSERT INTO InventoryLog (ProductId, ChangeQuantity, Reason)	
				SELECT @ProductID , @RestockQuantity, 'Restocked'

			COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
        ROLLBACK;
			THROW;
	END CATCH
END;
GO 



CREATE PROCEDURE sp_AdjustInventory
	@ProductId INT,
    @QuantityChange INT,   
    @Reason NVARCHAR(100)
AS 
BEGIN
	BEGIN TRY
		
		--THE REASON NEEDS TO BE INFORMATIVE AND NOT EMPTY OR NULL
		IF @Reason IS NULL OR LTRIM(RTRIM(@Reason)) = ''
			THROW 51011, 'The Reason variable should not be empty.', 1;
		--VALIDATING THAT PRODUCT WITH THIS ID EXISTS AND ISNT DISCONTINUED
		IF NOT EXISTS (
		SELECT 1 FROM Products
		WHERE ProductId = @ProductId AND IsDiscontinued = 0)
			THROW 51008, 'this product does not exist, or is discontinued',1;

		--CHECKING THAT THE QUANTITY CHANGE IS NOT EQUAL TO ZERO
		IF @QuantityChange = 0 
			THROW 51009, 'Quantity change Amount should not be equal to zero', 1;
		--STOCK CAN NOT GO BELOW 0
		IF (SELECT StockQuantity FROM Products 
		WHERE ProductId = @ProductId) + @QuantityChange <0
			THROW 51010 ,'The Stock Quantity should be greater that Quantity Change',1;
		
		BEGIN TRAN 
			UPDATE Products
			SET StockQuantity = StockQuantity + @QuantityChange
			WHERE ProductId = @ProductId
			
			--LOGGIN THE INVENTORY CHANGE

			INSERT INTO InventoryLog (ProductId,ChangeQuantity, Reason)
				VALUES(@ProductId, @QuantityChange, @Reason)
			COMMIT 

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
				THROW;
	END CATCH
END 
GO



CREATE PROCEDURE sp_ChangeOrderStatus
	@orderID INT, 
	@orderStatusName NVARCHAR(50)

AS 
BEGIN
	BEGIN TRY
		--CHECKING IF AN ORDER WITH THIS ORDER ID EVEN EXISTS
		IF NOT EXISTS (
		SELECT 1 FROM Orders
		WHERE OrderId = @orderID )
			THROW 51012, 'An order with this OrderID does not exist', 1;
		
		--CHECKING IF THE INPUT STATUS NAME EXISTS IN ORDER STATUS TABLE
		IF TRIM(@orderStatusName) NOT IN (
		SELECT StatusName FROM OrderStatus)
			THROW 51014, 'This status name does not exist in Order Status Table', 1;

		--CHECKING IF THE CURRENT STATUS IS THE SAME AS THE INPUT STATUS NAME
		IF (SELECT OS.StatusName
			FROM Orders O
			JOIN OrderStatus OS
			ON O.OrderStatusId = OS.OrderStatusId
			WHERE O.OrderId = @orderID) = @orderStatusName
			
			THROW 51013, 'The current Status of Order is the same that was given.',1;

		--CHECKING IF THE STATUS IS TOO FAR GONE TO BE REVERTED OR CHANGED (THE CHRONOLOGICAL ORDER OF OrderStatus CSV ENSURES THIS PART)
		IF (SELECT OrderStatusId FROM OrderStatus WHERE StatusName = @orderStatusName) < (SELECT OS.OrderStatusId
																							FROM Orders O
																							JOIN OrderStatus OS
																							ON O.OrderStatusId = OS.OrderStatusId
																							WHERE O.OrderId = @orderID)
			THROW 51015, 'The Current Status cannot be changed to the input status',1;

		BEGIN TRAN
			UPDATE Orders
			SET OrderStatusId = (SELECT OrderStatusId FROM OrderStatus WHERE StatusName = @orderStatusName)
			WHERE OrderId = @orderID 

			--ORDER STATUS CHANGE LOGGING IS DONE BY A TRIGGER ON THE Orders TABLE

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK;
					THROW;
	END CATCH
END
GO


CREATE PROCEDURE sp_DiscontinueProduct
	@ProductID INT
AS 
BEGIN
	BEGIN TRY

	--VALIDATING THE PRODUCT'S EXISTENCE
	IF NOT EXISTS (
	SELECT 1 FROM Products
	WHERE ProductId = @ProductID)
		THROW 51016, 'this Product does not exist in Products table', 1;

	--CHECKING IF MAYBE THE PRODUCT IS ALREADY DISCONTINUED
	IF (SELECT IsDiscontinued FROM Products WHERE ProductId = @ProductID) = 1
		THROW 51017, 'This Product is already discontinued', 1;

		BEGIN TRAN
			UPDATE Products
			SET IsDiscontinued = 1
			WHERE ProductId = @ProductID

		COMMIT 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK;
					THROW;
	END CATCH
END
GO