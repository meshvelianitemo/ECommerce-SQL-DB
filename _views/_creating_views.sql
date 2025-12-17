USE ECommerce;
GO

--creating view of Customers' orders
CREATE VIEW vw_CustomerOrders
AS
SELECT 
	o.OrderId,
	c.CustomerId,
	c.FirstName,
	c.LastName,
	o.TotalAmount,
	os.StatusName,
	o.OrderDate
FROM Orders o
	JOIN
Customers c ON o.CustomerId = c.CustomerId
	JOIN
OrderStatus os ON o.OrderStatusId = os.OrderStatusId ;
GO

--creating view of order details
CREATE VIEW vw_OrderDetails
AS
SELECT 
	o.OrderId,
	p.ProductName,
	oi.Quantity,
	oi.UnitPrice,
	oi.LineTotal
FROM OrderItems oi
	JOIN
Orders o ON oi.OrderId = o.OrderId
	JOIN
Products p ON oi.ProductId = p.ProductId ;
GO

--creating view of product stock
CREATE VIEW vw_ProductStock
AS
SELECT 
	ProductId,
	ProductName, 
	StockQuantity, 
	IsDiscontinued
FROM Products;
GO

SELECT * FROM vw_CustomerOrders
SELECT * FROM vw_OrderDetails
SELECT * FROM vw_ProductStock