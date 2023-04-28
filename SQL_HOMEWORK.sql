-- 找出和最貴的產品同類別的所有產品
SELECT
*
FROM Products
WHERE((SELECT TOP 1 CategoryID FROM Products ORDER BY UnitPrice DESC)
=CategoryID)
-- 找出和最貴的產品同類別最便宜的產品
SELECT TOP 1
*
FROM Products
WHERE((SELECT TOP 1 CategoryID FROM Products ORDER BY UnitPrice DESC)
=CategoryID)
ORDER BY UnitPrice ASC

-- 計算出上面類別最貴和最便宜的兩個產品的價差
SELECT
MAX(UnitPrice)-MIN(UnitPrice) AS Spread
FROM Products
WHERE((SELECT TOP 1 CategoryID FROM Products ORDER BY UnitPrice DESC)
=CategoryID)

-- 找出沒有訂過任何商品的客戶所在的城市的所有客戶
SELECT DISTINCT
CITY
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID =o.CustomerID
WHERE o.OrderID IS NULL

-- 找出第 5 貴跟第 8 便宜的產品的產品類別
SELECT DISTINCT
 p.CategoryID,c.CategoryName
FROM Categories c
LEFT JOIN Products p ON c.CategoryID=p.CategoryID
WHERE c.CategoryID IN
(
	SELECT
	CategoryID
	FROM Products
	ORDER BY UnitPrice DESC
	OFFSET 4 ROWS
	FETCH NEXT 1 ROWS ONLY
	UNION ALL
	SELECT 
	CategoryID
	FROM Products
	ORDER BY UnitPrice
	OFFSET 7 ROWS
	FETCH NEXT 1 ROWS ONLY
)

-- 找出誰買過第 5 貴跟第 8 便宜的產品
SELECT
ContactName
FROM Customers c
INNER JOIN Orders o ON o.CustomerID=c.CustomerID
INNER JOIN [Order Details]od ON o.OrderID=od.OrderID
INNER JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductID IN
(
	SELECT
	ProductID
	FROM Products
	ORDER BY UnitPrice DESC
	OFFSET 4 ROWS
	FETCH NEXT 1 ROWS ONLY
	UNION ALL
	SELECT 
	ProductID
	FROM Products
	ORDER BY UnitPrice
	OFFSET 7 ROWS
	FETCH NEXT 1 ROWS ONLY
)


-- 找出誰賣過第 5 貴跟第 8 便宜的產品
SELECT
e.EmployeeID,FirstName,LastName
FROM  Employees e
INNER JOIN Orders o ON o.EmployeeID = e.EmployeeID
INNER JOIN [Order Details]od ON o.OrderID=od.OrderID
INNER JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductID IN
(
	SELECT
	ProductID
	FROM Products
	ORDER BY UnitPrice DESC
	OFFSET 4 ROWS
	FETCH NEXT 1 ROWS ONLY
	UNION ALL
	SELECT 
	ProductID
	FROM Products
	ORDER BY UnitPrice
	OFFSET 7 ROWS
	FETCH NEXT 1 ROWS ONLY
)

-- 找出 13 號星期五的訂單 (惡魔的訂單)
SELECT
*
FROM Orders 
WHERE
DATEPART(DAY,OrderDate)=13 AND DATEPART(WEEKDAY,OrderDate)=6
-- 找出誰訂了惡魔的訂單
SELECT
c.CustomerID,ContactName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID =o.CustomerID
WHERE
DATEPART(DAY,OrderDate)=13 AND DATEPART(WEEKDAY,OrderDate)=6

-- 找出惡魔的訂單裡有什麼產品
SELECT
p.ProductID,ProductName
FROM Products p
INNER JOIN [Order Details]od ON od.ProductID=p.ProductID
INNER JOIN Orders o ON od.OrderID =o.OrderID
WHERE
DATEPART(DAY,OrderDate)=13 AND DATEPART(WEEKDAY,OrderDate)=6

-- 列出從來沒有打折 (Discount) 出售的產品
SELECT
p.ProductID,ProductName 
FROM [Order Details] od
INNER JOIN Products p ON P.ProductID=od.ProductID
WHERE(Discount<>0)

-- 列出購買非本國的產品的客戶
SELECT
c.ContactName ,c.Country
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID=p.SupplierID
INNER JOIN [Order Details] od ON od.ProductID=p.ProductID
INNER JOIN Orders o ON o.OrderID =od.OrderID
INNER JOIN Customers c ON c.CustomerID=o.CustomerID
WHERE(s.Country<>c.Country)


-- 列出在同個城市中有公司員工可以服務的客戶
SELECT
LastName,FirstName,e.Country 
FROM Employees e
INNER JOIN Orders o ON o.EmployeeID=e.EmployeeID
INNER JOIN Customers c ON c.CustomerID =o.CustomerID
WHERE(e.Country<>c.Country)

-- 列出那些產品沒有人買過
SELECT
p.ProductID,ProductName 
FROM Products p
INNER JOIN [Order Details]od ON p.ProductID =od.ProductID
INNER JOIN Orders o ON od.OrderID=o.OrderID
WHERE(od.OrderID<>o.OrderID)

----------------------------------------------------------------------------------------
-- 列出所有在每個月月底的訂單
SELECT
*
FROM Orders
WHERE eomonth(OrderDate) =OrderDate
-- 列出每個月月底售出的產品
SELECT DISTINCT
p.ProductName
FROM [Order Details] od
INNER JOIN Products p ON P.ProductID =OD.ProductID
WHERE OrderID IN(
SELECT
OrderID
FROM Orders
WHERE eomonth(OrderDate) =OrderDate
)
-- 找出有敗過最貴的三個產品中的任何一個的前三個大客戶
SELECT TOP 3
	od.ProductID
FROM [Order Details]od
GROUP BY od.ProductID
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount))DESC

-- 找出有敗過銷售金額前三高個產品的前三個大客戶
SELECT DISTINCT TOP 3
 c.CustomerID,
 SUM(od.UnitPrice*od.Quantity*(1-od.Discount))AS SalesAmount
FROM Customers c
INNER JOIN Orders o ON o.CustomerID =c.CustomerID
INNER JOIN [Order Details]od ON od.OrderID=o.OrderID
WHERE od.ProductID IN(
	SELECT TOP 3
	 od.ProductID
	FROM [Order Details]od
	GROUP BY od.ProductID
	ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount))DESC
)
GROUP BY c.CustomerID,c.CompanyName
ORDER BY SalesAmount
-- 找出有敗過銷售金額前三高個產品所屬類別的前三個大客戶
SELECT TOP 3
o.CustomerID, p.CategoryID
,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))
FROM [Order Details] od 
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Orders o ON od.OrderID = o.OrderID
WHERE(
p.CategoryID in (SELECT TOP 3
p.CategoryID
FROM [Order Details] od
INNER JOIN Products p ON p.ProductID =od.ProductID
GROUP BY p.ProductID,p.CategoryID
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC
)
)
GROUP BY o.CustomerID, p.CategoryID
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC

-- 列出消費總金額高於所有客戶平均消費總金額的客戶的名字，以及客戶的消費總金額
SELECT 
o.OrderID,
c.ContactName 
FROM Customers c 
INNER JOIN Orders o ON o.CustomerID = c.CustomerID 
WHERE o.OrderID IN (
  SELECT OrderID 
  FROM [Order Details] 
  GROUP BY OrderID 
  HAVING SUM(UnitPrice*Quantity*(1-Discount)) > (SELECT AVG(UnitPrice*Quantity*(1-Discount)) AS total FROM [Order Details])
) 
ORDER BY o.OrderID;



-- 列出最熱銷的產品，以及被購買的總金額
SELECT TOP 1
ProductID,
sum(UnitPrice*Quantity*(1-Discount)) as total_money,
sum(Quantity) as quantity
FROM [Order Details]
GROUP BY ProductID
ORDER BY quantity DESC
-- 列出最少人買的產品
SELECT TOP 1
od.ProductID,
p.ProductName,
SUM(Quantity) AS QUANTITY
FROM [Order Details]od
INNER JOIN Products p ON od.ProductID =p.ProductID
GROUP BY od.ProductID,p.ProductName
order by QUANTITY
-- 列出最沒人要買的產品類別 (Categories)
SELECT TOP 1
p.CategoryID,
SUM(Quantity) AS QUANTITY
FROM [Order Details]od
INNER JOIN Products p ON od.ProductID =p.ProductID
group by p.CategoryID
order by QUANTITY
-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (含購買其它供應商的產品)
SELECT 
c.ContactName,
SUM(UnitPrice*Quantity*(1-Discount)) AS total_money
FROM Orders o 
INNER JOIN Customers c ON o.CustomerID = c.CustomerID 
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID 
WHERE o.EmployeeID = (
	SELECT TOP 1 
	EmployeeID 
	FROM Orders
	GROUP BY EmployeeID 
	ORDER BY COUNT(OrderID) DESC) 
	GROUP BY c.ContactName 
	order by SUM(UnitPrice*Quantity*(1-Discount)

) desc

-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (不含購買其它供應商的產品)
SELECT
c.ContactName,
SUM(UnitPrice*Quantity*(1-Discount)) AS total_money
from Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.ContactName
ORDER BY total_money DESC
-- 列出那些產品沒有人買過
SELECT
p.ProductID
FROM Products p
-- 列出沒有傳真 (Fax) 的客戶和它的消費總金額
SELECT
o.CustomerID,
SUM(UnitPrice*Quantity*(1-Discount)) as total_money
FROM [Order Details]od
INNER JOIN Orders o ON od.OrderID =o.OrderID
WHERE o.CustomerID in(
 SELECT
 CustomerID
 FROM Customers
 WHERE fax is null
)
GROUP BY o.CustomerID
-- 列出每一個城市消費的產品種類數量
SELECT 
c.City,
p.CategoryID,
SUM(od.Quantity) AS QUANTITY
FROM Orders o
INNER JOIN [Order Details]od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON P.ProductID =od.ProductID
INNER JOIN Customers c  ON o.CustomerID =c.CustomerID
group by c.City, p.CategoryID 
order by c.City

-- 列出目前沒有庫存的產品在過去總共被訂購的數量
SELECT
od.ProductID,
 sum(od.Quantity) as QUANTITY
FROM [Order Details]od
INNER JOIN Products p ON P.ProductID =od.ProductID
WHERE (p.UnitsOnOrder =0)
GROUP BY od.ProductID
ORDER BY QUANTITY DESC
-- 列出目前沒有庫存的產品在過去曾經被那些客戶訂購過
SELECT
c.ContactName,
p.ProductName 
FROM [Order Details] od 
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID  
INNER JOIN Customers c ON o.CustomerID = c.CustomerID 
WHERE p.UnitsOnOrder = 0 
GROUP BY c.ContactName, p.ProductName 
ORDER BY p.ProductName;
-- 列出每位員工的下屬的業績總金額
SELECT 
EmployeeID, 
SUM(UnitPrice*Quantity*(1-Discount)) AS total_money 
FROM [Order Details] od 
INNER JOIN Orders o ON o.OrderID = od.OrderID 
GROUP BY EmployeeID 
ORDER BY EmployeeID
-- 列出每家貨運公司運送最多的那一種產品類別與總數量
WITH X_Table AS (
    SELECT s.ShipperID,
	c.CategoryName,
	SUM(od.Quantity) AS TotalQuantity,
        ROW_NUMBER() OVER (PARTITION BY s.ShipperID ORDER BY SUM(od.Quantity) DESC) AS Row_Numbers
    FROM [Order Details] od
    INNER JOIN Products p ON p.ProductID = od.ProductID
    INNER JOIN Categories c ON c.CategoryID = p.CategoryID
    INNER JOIN Orders o ON o.OrderID = od.OrderID
    INNER JOIN Shippers s ON s.ShipperID = o.ShipVia
    GROUP BY s.ShipperID, c.CategoryName
)
SELECT ShipperID, CategoryName, TotalQuantity
FROM X_Table
WHERE Row_Numbers = 1
-- 列出每一個客戶買最多的產品類別與金額
WITH X_Table AS (
	SELECT 
	c.ContactName,
	p.CategoryID, sum(Quantity) AS Quantity,
	sum(od.UnitPrice*Quantity*(1-Discount)) AS total,
	row_number() OVER(PARTITION BY ContactName ORDER BY sum(Quantity) DESC)AS Row_Numbers
	FROM [Order Details] od 
INNER join Orders o ON od.OrderID = o.OrderID 
INNER join Customers c ON c.CustomerID = o.CustomerID 
INNER join Products p ON od.ProductID = p.ProductID 
GROUP BY c.ContactName, p.CategoryID)
SELECT
* 
FROM X_Table 
WHERE Row_Numbers = 1;
-- 列出每一個客戶買最多的那一個產品與購買數量
WITH X_Table AS (
	SELECT 
	c.ContactName,
	p.ProductName,
	sum(Quantity) AS Quantity,
	row_number() OVER(PARTITION BY ContactName ORDER BY c.ContactName,
	sum(Quantity) DESC) AS Row_Numbers
	FROM [Order Details] od 
	INNER join Orders o ON od.OrderID = o.OrderID 
	INNER join Customers c ON c.CustomerID = o.CustomerID 
	INNER join Products p ON od.ProductID = p.ProductID 
	GROUP BY c.ContactName, p.ProductName)
SELECT
* 
FROM X_Table 
WHERE Row_Numbers = 1;
-- 按照城市分類，找出每一個城市最近一筆訂單的送貨時間
SELECT
ShipCity,MAX(ShippedDate) recentDate
FROM Orders
WHERE ShipCity IS NOT NULL
GROUP BY ShipCity;
-- 列出購買金額第五名與第十名的客戶，以及兩個客戶的金額差距
WITH X_Table AS(
SELECT c.CustomerID,
SUM((od.UnitPrice*od.Quantity)*(1-od.Discount)) Sum_Price,
	ROW_NUMBER() OVER (
		ORDER BY SUM((od.UnitPrice*od.Quantity)*(1-od.Discount)) DESC
	) AS NOS
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID
)
SELECT X_Table.CustomerID, X_Table.Sum_Price SumPrice1,  X_Table.CustomerID, X_Table.Sum_Price SumPrice2, ABS(X_Table.Sum_Price - X_Table.Sum_Price) gap
FROM X_Table
INNER JOIN X_Table X_Table2 ON X_Table.NOS = 5 AND X_Table2.NOS = 10
WHERE X_Table.NOS = 5 OR X_Table2.NOS = 10;