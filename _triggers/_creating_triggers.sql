USE ECommerce;
GO

--creating trigger to update stock and log new orders in InventoryLog table
CREATE TRIGGER trg_OrderItems_DecreaseStock_
ON OrderItems
AFTER INSERT 
AS
BEGIN 
	SET NOCOUNT ON;

	UPDATE P
	SET p.StockQuantity = p.StockQuantity - i.Quantity
	FROM Products p
		JOIN
	inserted i on p.ProductId = i.ProductId;

	INSERT INTO InventoryLog (ProductId, ChangeQuantity, Reason)
	SELECT 
		ProductId,
		-Quantity, 
		'Order placed'
	FROM inserted;
END;
GO 

--creating a trigger to update TotalAmount of OrderTables each time new OrderItem gets inserted

CREATE TRIGGER trg_Update_Orders_TotalAmount
ON OrderItems
AFTER INSERT 
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE o 
	SET o.TotalAmount = (
		SELECT SUM(oi.LineTotal)
		FROM OrderItems oi
		WHERE oi.OrderId = o.OrderId)
	FROM Orders o
	JOIN inserted i ON o.OrderId = i.OrderId;
END;
GO

--creating a trigger to prevent making orders of discontinued products and also fetching actual UnitPrice from Products table instead of eternally inserting every time 

CREATE TRIGGER trg_Block_Discontinued_Products
ON OrderItems
INSTEAD OF INSERT 
AS 
BEGIN
	IF EXISTS (
		SELECT 1
        FROM inserted i
        JOIN Products p ON i.ProductId = p.ProductId
        WHERE p.IsDiscontinued = 1
	)
	BEGIN
		RAISERROR ('Cannot order discontinued products.', 16, 1);
		RETURN;
	END

	INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice)
	SELECT i.OrderId, i.ProductId, i.Quantity, p.UnitPrice
	FROM inserted i
	JOIN Products p ON i.ProductId = p.ProductId
END;
GO

--creating trigger that logs order status changes

CREATE TRIGGER trg_OrderStatusHistory
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrderStatusHistory (OrderId, OldStatusId, NewStatusId)
    SELECT
        d.OrderId,
        d.OrderStatusId,
        i.OrderStatusId
    FROM deleted d
		JOIN 
	inserted i ON d.OrderId = i.OrderId
    WHERE d.OrderStatusId <> i.OrderStatusId;
END;
GO


