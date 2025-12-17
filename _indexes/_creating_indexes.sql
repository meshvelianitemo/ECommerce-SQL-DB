USE ECommerce;
GO

--creating indexes on orders' CustomerId and OrderStatusId
CREATE INDEX IX_Orders_CustomerId ON Orders(CustomerId);
CREATE INDEX IX_Orders_OrderStatusId ON Orders(OrderStatusId);

--creating indexes on OrderItems' OrderId and ProductId
CREATE INDEX IX_OrderItems_OrderId ON OrderItems(OrderId);
CREATE INDEX IX_OrderItems_ProductId ON OrderItems(ProductId);

--creating index on OrderStatusHistory's OrderId
CREATE INDEX IX_OrderStatusHistory_OrderId ON OrderStatusHistory(OrderId);

--creating index on InventoryLog's ProductId
CREATE INDEX IX_InventoryLog_ProductId ON InventoryLog(ProductId);
