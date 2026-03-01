CREATE DATABASE ToysGroup;

USE ToysGroup;

CREATE TABLE Category (
    CategoryID   INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    PRIMARY KEY (CategoryID)
);

CREATE TABLE SubCategory (
    SubCategoryID   INT NOT NULL,
    SubCategoryName VARCHAR(100) NOT NULL,
    CategoryID      INT NOT NULL,
    PRIMARY KEY (SubCategoryID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Product (
    ProductID      INT NOT NULL,
    ProductName    VARCHAR(150) NOT NULL,
    SubCategoryID  INT NOT NULL,
    PRIMARY KEY (ProductID),
    FOREIGN KEY (SubCategoryID) REFERENCES SubCategory(SubCategoryID)
);

CREATE TABLE Region (
    RegionID    INT NOT NULL,
    RegionName  VARCHAR(100) NOT NULL,
    PRIMARY KEY (RegionID)
);

CREATE TABLE Country (
    CountryID    INT NOT NULL,
    CountryName  VARCHAR(100) NOT NULL,
    RegionID     INT NOT NULL,
    PRIMARY KEY (CountryID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sale (                                                                                  -- Ho inserito CountryID per evitare ridondanza e possibili inconsistenze, poiché la regione è determinabile univocamente tramite Country.
    SaleID     INT NOT NULL,
    ProductID  INT NOT NULL,
    CountryID  INT NOT NULL,
    Date       DATE NOT NULL,
    Quantity   INT NOT NULL,
    Price      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (SaleID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

INSERT INTO Category (CategoryID, CategoryName) VALUES
(1, 'Bikes'),
(2, 'Clothing'),
(3, 'Toys');

INSERT INTO SubCategory (SubCategoryID, SubCategoryName, CategoryID) VALUES
(10, 'Mountain Bikes', 1),
(11, 'Road Bikes', 1),
(20, 'Gloves', 2),
(21, 'Jerseys', 2),
(30, 'Action Figures', 3),
(31, 'Board Games', 3);

INSERT INTO Product (ProductID, ProductName, SubCategoryID) VALUES
(100, 'Bikes-100', 10),
(101, 'Bikes-200', 11),
(102, 'Bikes-300', 10),
(103, 'Bikes-400', 11),

(200, 'Bike Gloves M', 20),
(201, 'Bike Gloves L', 20),
(202, 'Cycling Jersey S', 21),
(203, 'Cycling Jersey M', 21),

(300, 'Robot Warrior', 30),
(301, 'Space Ranger', 30),
(310, 'Chess Classic', 31),
(311, 'Family Trivia', 31);

INSERT INTO Region (RegionID, RegionName) VALUES
(1, 'WestEurope'),
(2, 'SouthEurope');

INSERT INTO Country (CountryID, CountryName, RegionID) VALUES
(10, 'France', 1),
(11, 'Germany', 1),
(20, 'Italy', 2),
(21, 'Greece', 2);

INSERT INTO Sale (SaleID, ProductID, CountryID, Date, Quantity, Price) VALUES
(1, 100, 10, '2025-01-05', 2, 499.99),
(2, 200, 10, '2025-01-06', 5, 19.90),
(3, 202, 11, '2025-01-07', 3, 39.50),
(4, 300, 20, '2025-01-08', 4, 14.99),
(5, 310, 21, '2025-01-09', 1, 24.90),
(6, 101, 11, '2025-01-10', 1, 599.00),
(7, 203, 20, '2025-01-11', 2, 41.00),
(8, 311, 10, '2025-01-12', 2, 18.50),
(9, 201, 21, '2025-01-13', 6, 21.50),
(10, 102, 20, '2025-01-14', 1, 549.00),
(11, 301, 11, '2025-01-15', 3, 16.75),
(12, 103, 10, '2025-01-16', 2, 650.00);


SELECT                                                            -- 1) Query per controllo unicità PK 
  COUNT(*) AS TOTraw,
  COUNT(DISTINCT CategoryID) AS TOT_DistinctPK
FROM Category;

SELECT                                                            -- 2) Query per esporre le transizioni
  s.SaleID AS CodiceDocumento,
  p.ProductName AS NomeProdotto,
  cat.CategoryName AS CategoriaProdotto,
  co.CountryName AS Stato,
  r.RegionName   AS Regione,
  IF(DATEDIFF(CURDATE(), s.Date) > 180, 'True', 'False') AS PiuDi180Giorni
FROM Sale s
JOIN Product p      ON s.ProductID = p.ProductID
JOIN SubCategory sc ON p.SubCategoryID = sc.SubCategoryID
JOIN Category cat   ON sc.CategoryID = cat.CategoryID
JOIN Country co     ON s.CountryID = co.CountryID
JOIN Region r       ON co.RegionID = r.RegionID
ORDER BY s.Date, s.SaleID;


SELECT                                                              -- 3) Query per esporre l’elenco dei prodotti che hanno venduto, in totale, una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito. 
  s.ProductID,
  SUM(s.Quantity) AS TotaleVenduto
FROM Sale s
WHERE YEAR(s.Date) = (SELECT YEAR(MAX(Date)) FROM Sale)
GROUP BY s.ProductID
HAVING SUM(s.Quantity) > (
  SELECT AVG(x.TotalePerProdotto)
  FROM (
    SELECT
      s2.ProductID,
      SUM(s2.Quantity) AS TotalePerProdotto
    FROM Sale s2
    WHERE YEAR(s2.Date) = (SELECT YEAR(MAX(Date)) FROM Sale)
    GROUP BY s2.ProductID
  ) x
)
ORDER BY TotaleVenduto DESC;


SELECT                                                             -- 4) Query per esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno
  t.ProductID,
  p.ProductName,
  t.Anno,
  t.FatturatoTotale
FROM (
  SELECT
    s.ProductID,
    YEAR(s.Date) AS Anno,
    SUM(s.Quantity * s.Price) AS FatturatoTotale
  FROM Sale s
  GROUP BY s.ProductID, YEAR(s.Date)
) t
JOIN Product p ON t.ProductID = p.ProductID
ORDER BY t.ProductID, t.Anno;


SELECT                                                             -- 5) Query per esporre il fatturato totale per stato per anno ordinandolo per anno e fatturato (in maniera decrescente)
  co.CountryName AS Stato,
  EXTRACT(YEAR FROM s.Date) AS Anno,
  SUM(s.Quantity * s.Price) AS FatturatoTotale
FROM Sale s
JOIN Country co ON s.CountryID = co.CountryID
GROUP BY co.CountryName, EXTRACT(YEAR FROM s.Date)
ORDER BY Anno, FatturatoTotale DESC;


SELECT                                                               -- 6) Query per esporre la categoria più richiesta in base la quantità
  cat.CategoryName,
  SUM(s.Quantity) AS QuantitaTotale
FROM Sale s
JOIN Product p      ON s.ProductID = p.ProductID
JOIN SubCategory sc ON p.SubCategoryID = sc.SubCategoryID
JOIN Category cat   ON sc.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
HAVING SUM(s.Quantity) = (
  SELECT MAX(t.QuantitaTotale)
  FROM (
    SELECT
      cat2.CategoryName,
      SUM(s2.Quantity) AS QuantitaTotale
    FROM Sale s2
    JOIN Product p2      ON s2.ProductID = p2.ProductID
    JOIN SubCategory sc2 ON p2.SubCategoryID = sc2.SubCategoryID
    JOIN Category cat2   ON sc2.CategoryID = cat2.CategoryID
    GROUP BY cat2.CategoryName
  ) t
);

SELECT                                                            -- 7) Primo approccio per esporre articoli invenduti con utilizzo di NULL
  p.ProductID,
  p.ProductName
FROM Product p
LEFT JOIN Sale s ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL
ORDER BY p.ProductID;

SELECT                                                             -- 7) Secondo approccio per esporre articoli invenduti con utillo di NOT EXISTS 
  p.ProductID,
  p.ProductName
FROM Product p
WHERE NOT EXISTS (
  SELECT 1
  FROM Sale s
  WHERE s.ProductID = p.ProductID
)
ORDER BY p.ProductID;

CREATE VIEW vw_Product_Denorm AS                                      -- 8) Creazione vista per visualizzazione prodotti
SELECT
  p.ProductID,
  p.ProductName,
  cat.CategoryName
FROM Product p
JOIN SubCategory sc ON p.SubCategoryID = sc.SubCategoryID
JOIN Category cat   ON sc.CategoryID = cat.CategoryID;

CREATE VIEW vw_Geography AS                                              -- 9) Creazione vista per visualizzazione Country/Region
SELECT
  co.CountryID,
  co.CountryName,
  r.RegionID,
  r.RegionName
FROM Country co
JOIN Region r ON co.RegionID = r.RegionID;