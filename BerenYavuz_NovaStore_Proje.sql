-- ============================================
-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- Hazırlayan: Beren Yavuz
-- ============================================


-- ============================================
-- BÖLÜM 1: VERİ TABANI VE TABLO OLUŞTURMA (DDL)
-- ============================================

-- Veritabanı oluşturma
CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- A. Categories (Kategoriler) Tablosu
CREATE TABLE Categories (
    CategoryID   INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(50) NOT NULL
);

-- B. Customers (Müşteriler) Tablosu
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) UNIQUE
);

-- C. Products (Ürünler) Tablosu
CREATE TABLE Products (
    ProductID   INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT DEFAULT 0,
    CategoryID  INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

-- D. Orders (Siparişler) Tablosu
CREATE TABLE Orders (
    OrderID     INT PRIMARY KEY IDENTITY(1,1),
    CustomerID  INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate   DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- E. OrderDetails (Sipariş Detayları) Tablosu
CREATE TABLE OrderDetails (
    DetailID  INT PRIMARY KEY IDENTITY(1,1),
    OrderID   INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity  INT
);


-- ============================================
-- BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
-- ============================================

-- Görev 1: Kategoriler
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');

-- Görev 2: Müşteriler
INSERT INTO Customers (FullName, City, Email) VALUES
('Beren Yavuz',      'İstanbul', 'beren@email.com'),
('Betül Yıldırım',   'Ankara',   'betul@email.com'),
('Mehmet Demir',     'İzmir',    'mehmet@email.com'),
('Zeynep Çelik',     'Konya',    'zeynep@email.com'),
('Emre Şahin',       'Antalya',  'emre@email.com'),
('Defne Yıldız',     'İstanbul', 'defne@email.com');

-- Görev 3: Ürünler
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Samsung Galaxy S24',      32000.00,  15, 1),
('Apple AirPods',            8500.00,  30, 1),
('Laptop Çantası',            450.00,  50, 1),
('Erkek Mont',               1200.00,  25, 2),
('Kadın Elbise',              850.00,  40, 2),
('Spor Ayakkabı',            1500.00,  35, 2),
('Sapiens',                   180.00,  60, 3),
('Atomik Alışkanlıklar',      150.00,  45, 3),
('Yüz Temizleme Jeli',        220.00,  80, 4),
('Nemlendirici Krem',         350.00,  55, 4),
('Kahve Makinesi',           2800.00,  18, 5),
('Yatak Örtüsü Seti',         950.00,  22, 5);

-- Görev 4: Siparişler
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2024-01-15', 32000.00),
(2, '2024-01-20',  8500.00),
(3, '2024-02-05',  2050.00),
(4, '2024-02-14',  1200.00),
(5, '2024-03-01',  3650.00),
(1, '2024-03-10',   450.00),
(6, '2024-03-15',  1100.00),
(2, '2024-04-02',  2800.00),
(3, '2024-04-18',   330.00),
(5, '2024-05-01',   950.00);

-- Görev 4: Sipariş Detayları
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1,  1, 1),
(2,  2, 1),
(3,  4, 1),
(3,  8, 3),
(4,  4, 1),
(5,  6, 1),
(5, 11, 1),
(6,  3, 1),
(7,  5, 1),
(8, 11, 1),
(9,  7, 1),
(9,  9, 1),
(10,12, 1);


-- ============================================
-- BÖLÜM 3: SORGULAMA VE ANALİZ (DQL)
-- ============================================

-- Soru 1: Stok miktarı 20'den az olan ürünler (azalan sırada)
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- Soru 2: Hangi müşteri hangi tarihte sipariş vermiş
SELECT c.FullName, c.City, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Soru 3: Beren Yavuz'un aldığı ürünlerin adı, fiyatı ve kategorisi
SELECT c.FullName, p.ProductName, p.Price, cat.CategoryName
FROM Customers c
INNER JOIN Orders o       ON c.CustomerID  = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products p      ON od.ProductID = p.ProductID
INNER JOIN Categories cat  ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Beren Yavuz';

-- Soru 4: Her kategoride kaç ürün var
SELECT cat.CategoryName, COUNT(p.ProductID) AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;

-- Soru 5: Her müşterinin toplam harcaması (en çoktan en aza)
SELECT c.FullName, SUM(o.TotalAmount) AS ToplamCiro
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FullName
ORDER BY ToplamCiro DESC;

-- Soru 6: Siparişlerin üzerinden kaç gün geçmiş
SELECT c.FullName, o.OrderDate,
       DATEDIFF(day, o.OrderDate, GETDATE()) AS GecenGun
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID;


-- ============================================
-- BÖLÜM 4: İLERİ SEVİYE VERİTABANI NESNELERİ
-- ============================================

-- 1. VIEW Oluşturma: vw_SiparisOzet
CREATE VIEW vw_SiparisOzet AS
SELECT
    c.FullName    AS MusteriAdi,
    o.OrderDate   AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity   AS Adet
FROM Customers c
INNER JOIN Orders o        ON c.CustomerID  = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID     = od.OrderID
INNER JOIN Products p      ON od.ProductID  = p.ProductID;
GO

-- VIEW'i test etmek için:
SELECT * FROM vw_SiparisOzet;

-- 2. Yedekleme (Backup)
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak';
