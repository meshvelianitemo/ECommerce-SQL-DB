USE ECommerce;
GO

-- Reset identity for Customers
DBCC CHECKIDENT ('Customers', RESEED, 999);
GO
	
-- Reset identity for Products
DBCC CHECKIDENT ('Products', RESEED, 999);
GO

-- Reset identity for OrderStatus
DBCC CHECKIDENT ('OrderStatus', RESEED, 999);
GO

-- Reset identity for Orders
DBCC CHECKIDENT ('Orders', RESEED, 999);
GO

-- Reset identity for OrderItems
DBCC CHECKIDENT ('OrderItems', RESEED, 999);
GO

-- Reset identity for OrderStatusHistory
DBCC CHECKIDENT ('OrderStatusHistory', RESEED, 999);
GO

-- Reset identity for InventoryLog
DBCC CHECKIDENT ('InventoryLog', RESEED, 999);
GO
