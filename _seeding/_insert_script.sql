USE ECommerce;
GO

---------------------- CUSTOMERS
CREATE TABLE dbo.Customers_Staging
(
    FirstName NVARCHAR(50),
    LastName NVARCHAR(100),
    Email NVARCHAR(255),
    Phone NVARCHAR(25),
    IsActive BIT
);
GO

BULK INSERT dbo.Customers_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_customers_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO Customers (FirstName, LastName, Email, Phone, IsActive)
SELECT FirstName, LastName, Email, Phone, IsActive
FROM dbo.Customers_Staging;
GO

DROP TABLE Customers_Staging;
GO

---------------------- PRODUCTS
CREATE TABLE dbo.Products_Staging
(
    ProductName NVARCHAR(200),
    SKU NVARCHAR(100), 
    UnitPrice DECIMAL(8,2),
    StockQuantity INT , 
    IsDiscontinued BIT
);
GO

BULK INSERT dbo.Products_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_products_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO Products (ProductName, SKU, UnitPrice, StockQuantity, IsDiscontinued)
SELECT ProductName, SKU, UnitPrice, StockQuantity, IsDiscontinued
FROM dbo.Products_Staging;
GO

DROP TABLE Products_Staging;
GO

---------------------- ORDERSTATUS
CREATE TABLE dbo.OrderStatus_Staging
(
    StatusName NVARCHAR(50)
);
GO

BULK INSERT dbo.OrderStatus_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_orderStatus_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO OrderStatus (StatusName)
SELECT StatusName
FROM dbo.OrderStatus_Staging;
GO

DROP TABLE OrderStatus_Staging;
GO

---------------------- ORDERS
CREATE TABLE dbo.Orders_Staging
(
    CustomerId INT,
    OrderStatusId INT,
    TotalAmount DECIMAL(8,2)
);
GO

BULK INSERT dbo.Orders_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_orders_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO Orders (CustomerId, OrderStatusId, TotalAmount)
SELECT CustomerId, OrderStatusId, TotalAmount
FROM dbo.Orders_Staging;
GO

DROP TABLE Orders_Staging;
GO

---------------------- ORDERITEMS
CREATE TABLE dbo.OrderItems_Staging
(
    OrderId BIGINT,
    ProductId INT,
    Quantity INT,
    UnitPrice DECIMAL(8,2)
);
GO

BULK INSERT dbo.OrderItems_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_orderItems_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice)
SELECT OrderId, ProductId, Quantity, UnitPrice
FROM dbo.OrderItems_Staging;
GO

DROP TABLE OrderItems_Staging;
GO

---------------------- ORDERSTATUS HISTORY
CREATE TABLE dbo.OrderStatusHistory_Staging
(
    OrderId BIGINT,
    OldStatusId INT,
    NewStatusId INT
);
GO

BULK INSERT dbo.OrderStatusHistory_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_orderStatusHistory_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO OrderStatusHistory (OrderId, OldStatusId, NewStatusId)
SELECT OrderId, OldStatusId, NewStatusId
FROM dbo.OrderStatusHistory_Staging;
GO

DROP TABLE OrderStatusHistory_Staging;
GO

---------------------- INVENTORYLOG
CREATE TABLE dbo.InventoryLog_Staging
(
    ProductId INT,
    ChangeQuantity INT,
    Reason NVARCHAR(500)
);
GO

BULK INSERT dbo.InventoryLog_Staging
FROM 'C:\ECommerce-SQL-DB\_seeding\_seed\_inventoryLog_seed.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'
);
GO

INSERT INTO InventoryLog (ProductId, ChangeQuantity, Reason)
SELECT ProductId, ChangeQuantity, Reason
FROM dbo.InventoryLog_Staging;
GO

DROP TABLE InventoryLog_Staging;
GO
