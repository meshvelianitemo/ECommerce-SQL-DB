CREATE DATABASE ECommerce;
GO

USE ECommerce;
GO

CREATE TABLE Customers 
(
CustomerId INT IDENTITY(1000,1), --primary key
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(100) NOT NULL,
Email NVARCHAR(255) NOT NULL, --check & unique
Phone NVARCHAR(25) NOT NULL , 
CreatedAt DATETIME DEFAULT GETDATE(), --default
IsActive BIT DEFAULT 1 ,  --default
CONSTRAINT PK_Customers_CustomerId PRIMARY KEY (CustomerId), 
CONSTRAINT CH_Customers_Email CHECK(Email like '%@%'),
CONSTRAINT U_Customers_Email UNIQUE(Email), 
CONSTRAINT CH_Customers_CreatedAt CHECK (CreatedAt <= GETDATE())
);
GO

CREATE TABLE Products
(
ProductId INT IDENTITY(1000,1), --primary key
ProductName NVARCHAR(200) NOT NULL,
SKU NVARCHAR(100) NOT NULL, --unique
UnitPrice DECIMAL (8,2) NOT NULL , --check
StockQuantity INT NOT NULL, --check
IsDiscontinued BIT NOT NULL, 
CreatedAt DATETIME DEFAULT GETDATE(),
CONSTRAINT PK_Products_ProductId PRIMARY KEY(ProductId), 
CONSTRAINT U_Products_SKU UNIQUE(SKU), 
CONSTRAINT CH_Products_CreatedAt CHECK (CreatedAt <= GETDATE()),
CONSTRAINT CH_Products_UnitPrice CHECK (UnitPrice >= 0),
CONSTRAINT CH_Products_StockQuantity CHECK (StockQuantity >= 0)
);
GO

CREATE TABLE OrderStatus 
(
OrderStatusId INT IDENTITY(1000,1), --primary key
StatusName NVARCHAR(50) NOT NULL , --check
CONSTRAINT PK_OrderStatus_OrderStatusId PRIMARY KEY(OrderStatusId), 
CONSTRAINT CH_OrderStatus_StatusName CHECK (StatusName IN ('Created','Paid','Shipped','Completed','Cancelled', 'Processing','Returned','Refunded','On Hold','Failed'))
);
GO

CREATE TABLE Orders
(
OrderId BIGINT IDENTITY(1000,1), --primary key
CustomerId INT NOT NULL, --foreign key
OrderStatusId INT NOT NULL, 
OrderDate DATETIME DEFAULT GETDATE(),
TotalAmount DECIMAL(8,2) NOT NULL DEFAULT 0, 
CONSTRAINT PK_Orders_OrderId PRIMARY KEY(OrderId), 
CONSTRAINT FK_Orders_CustomerId FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId), 
CONSTRAINT CH_Orders_OrderDate CHECK (OrderDate <= GETDATE()),
CONSTRAINT FK_Orders_OrderStatus 
FOREIGN KEY (OrderStatusId) REFERENCES OrderStatus(OrderStatusId)
);
GO

CREATE TABLE OrderItems 
(
OrderItemId INT IDENTITY(1000,1) , --primary key
OrderId BIGINT NOT NULL, --foreign key to Orders table
ProductId INT NOT NULL, --foreign key to Products table
Quantity INT NOT NULL, 
UnitPrice DECIMAL (8,2) NOT NULL , 
LineTotal AS Quantity * UnitPrice,
CONSTRAINT PK_OrderItems_OrderItemId PRIMARY KEY (OrderItemId) , 
CONSTRAINT FK_OrderItems_OrderId FOREIGN KEY(OrderId) REFERENCES Orders(OrderId), 
CONSTRAINT FK_OrderItems_ProductId FOREIGN KEY(ProductId) REFERENCES Products(ProductId),
CONSTRAINT CH_OrderItems_Quantity CHECK (Quantity > 0),
CONSTRAINT CH_OrderItems_UnitPrice CHECK (UnitPrice >= 0)
);
GO

CREATE TABLE OrderStatusHistory
(
HistoryId INT IDENTITY(1000,1), --primary key
OrderId BIGINT NOT NULL , 
OldStatusId INT NOT NULL , 
NewStatusId INT NOT NULL , 
ChangedAt DATETIME DEFAULT GETDATE() , --check
CONSTRAINT PK_OSH_HistoryId PRIMARY KEY (HistoryId), 
CONSTRAINT CH_OSH_ChangedAt CHECK (ChangedAt <= GETDATE()),
CONSTRAINT FK_OSH_Order FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
CONSTRAINT FK_OSH_OldStatus FOREIGN KEY (OldStatusId) REFERENCES OrderStatus(OrderStatusId),
CONSTRAINT FK_OSH_NewStatus FOREIGN KEY (NewStatusId) REFERENCES OrderStatus(OrderStatusId)
);
GO

CREATE TABLE InventoryLog
(
InventoryLogId INT IDENTITY(1000,1) , --primary key 
ProductId INT NOT NULL, --foreign key
ChangeQuantity INT NOT NULL, 
Reason NVARCHAR(500) NOT NULL,
CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
CONSTRAINT FK_InventoryLog_ProductId FOREIGN KEY(ProductId) REFERENCES Products(ProductId),
CONSTRAINT PK_InventoryLog_InventoryLogId PRIMARY KEY(InventoryLogId)
);
GO

