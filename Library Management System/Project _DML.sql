


USE LMSDB
GO

--==============================================
--INSERT VALUES
--==============================================

SELECT * FROM Roles
INSERT INTO Roles VALUES ('Admin'),('Student'),('Teacher')
GO


SELECT * FROM Category

INSERT INTO Category VALUES ('BSCS')
INSERT INTO Category VALUES ('BSCS')
INSERT INTO Category VALUES ('BBA')
INSERT INTO Category VALUES ('BBA')
INSERT INTO Category VALUES ('BBA')
GO



SELECT * FROM Users

INSERT INTO [Users] VALUES (1,  'Zainab',   'BSCS',  '01877 377 576',  'Chatoogram',   2020)
INSERT INTO [Users] VALUES (3,  'Owais',   'BBA',  '01843 585 092',  'Dhaka',   2020)
INSERT INTO [Users] VALUES (2,  'Shafiq',   'BSCS',  '01743 585 092',  'Dhaka', 2021)
INSERT INTO [Users] VALUES (3,  'Farhan',   'BBA',  '01921 234 567',  'Chattogram', 2021)
INSERT INTO [Users] VALUES (2,  'Adnan',   'BSCS',  '01727 654 321',  'Dhaka',  2022)
GO


SELECT * FROM Books

INSERT INTO Books VALUES (101,  'English',   'Shely',  '1st',  1)
INSERT INTO Books VALUES (102,  'Islamiyat',  'Sana',   '1st',  2)
INSERT INTO Books VALUES (103,  'Accounting', 'Imran',  '1st',  3)
INSERT INTO Books VALUES (104,  'Algebra',    'Ali',   '1st',  4)
INSERT INTO Books VALUES (105,  'Calculus',  'Qadri',  '1st',  5)
GO


SELECT * FROM Stocks

INSERT INTO Stocks VALUES(1,1),(2,2),(3,3)
GO

SELECT * FROM Book_Issues

INSERT INTO Book_Issues  VALUES ('2020-02-08','2020-02-10', 550, 2, 1, 1)
INSERT INTO Book_Issues  VALUES ('2020-01-02','2010-01-10',450, 3, 2, 3)
INSERT INTO Book_Issues  VALUES ('2021-03-03','2021-03-10',300, 4, 3, 3)
INSERT INTO Book_Issues  VALUES ('2022-01-02','2022-01-10',550, 5, 2, 3)
INSERT INTO Book_Issues  VALUES ('2020-04-02','2020-04-10',4500, 5, 2, 3)
GO

--================================================
--SELECT STATEMENT
--================================================
SELECT * FROM Users
SELECT * FROM Books
SELECT * FROM Category
SELECT * FROM Roles
SELECT * FROM Book_Issues
SELECT * FROM Stocks
GO
--====================================================
--UPDATE AND DELETE
--====================================================
UPDATE Users
SET Name= 'Mostofa', Contact='01728 664 421'
WHERE User_Id= 5
GO

SELECT * FROM Users
GO

DELETE FROM Users WHERE User_Id= 5
GO

 --==============================================
 --SELECT INTO AND Copy Data From Another Table
 --=============================================
SELECT * INTO User02
FROM Users;
GO

SELECT * FROM User02
GO

--==============================================
--Truncate Table
--==============================================  
 TRUNCATE TABLE User02
 GO

 --==============================================
 --Six Clouse
 --==============================================
SELECT *
FROM Books
WHERE Book_Name ='Accounting'
GO

--Group by
SELECT Book_Name,COUNT(Book_Id) AS [No. Of Books]
FROM Books
GROUP BY Book_Name
GO

--HAVING
SELECT COUNT(Book_Id) AS [No. Of Books], Book_Name
FROM Books
GROUP BY Book_Name
HAVING COUNT(Book_Id)<3

-- ORDER BY
SELECT COUNT(Book_Id) AS [No. Of Books], Book_Name
FROM Books
GROUP BY Book_Name
HAVING COUNT(Book_Id)<3
ORDER BY Book_Name DESC
Go

--=================================================
	--DISTINCT
--================================================
SELECT DISTINCT Book_Id, Book_Name, Book_Edition
FROM Books
GO

--=================================================
	--BETWEEN
--================================================
SELECT * FROM Book_Issues
WHERE Vat BETWEEN 0 AND 5
GO

--=================================================
	--TOP
--================================================
SELECT TOP 3 * FROM Books
GO

SELECT TOP 3 WITH TIES * FROM Books
ORDER  BY Book_Name
GO

SELECT TOP  3 PERCENT * FROM Books
ORDER  BY Book_Name
GO

--=======================================
--Create Sub Query 
--=======================================
SELECT SUM(Vat) AS TotalVat
FROM Book_Issues
WHERE Vat in (SELECT Vat FROM Book_Issues WHERE Book_ID=4)
GO

--=================================================
--With CUBE, ROLLUP, GROUPING SETS 
--=================================================
--CUBE
SELECT Book_Name,Author_Name, SUM(Book_ID) AS [SUM]
FROM Books
GROUP BY Book_Name,Author_Name WITH CUBE

---ROLL UP
SELECT Book_Name, Author_Name, SUM(Book_ID) AS [SUM]
FROM Books
GROUP BY Book_Name,Author_Name WITH ROLLUP

--GROUPING SETS
SELECT Book_Name, Author_Name, SUM(Book_ID) AS [SUM]
FROM Books
GROUP BY GROUPING SETS(
  ( Book_Name, Author_Name)
  ,(Book_Name)
  )
GO

 --=============================================
 --Inner JOIN
 --=============================================
 SELECT *
 FROM Books
 INNER JOIN Book_Issues
 ON Book_Issues.Book_ID =Books.Book_ID 
 GO

 --=============================================
 -- Left Outer JOIN
 --=============================================
SELECT *
FROM Books
LEFT OUTER JOIN Book_Issues
ON Book_Issues.Book_ID =Books.Book_ID 
GO
 --===============================================
 --Right Outer Join 
 --===============================================
SELECT *
FROM Books
RIGHT OUTER JOIN Book_Issues
ON Books.Book_ID=Book_Issues.Book_ID
GO

 --===============================================
 --Full Join
 --===============================================
SELECT *
FROM Books
FULL JOIN Book_Issues
ON Books.Book_ID=Book_Issues.Book_ID
GO

 --===============================================
 --Cross Join
 --===============================================
SELECT Book_Name,Author_Name,Book_Edition,Book_Serial_Num,Bk_Issue_Id,Vat,Total
FROM Books
CROSS JOIN Book_Issues
GO
 --==============================================
 --Self Join
 --==============================================
SELECT x.Author_Name,y.Author_Name
FROM Books as x, Books as y
WHERE x.Book_ID<>y.Book_ID
GO
--=================================================
--UNION, LOGICALL
--=================================================
 --UNION 
 SELECT Book_ID FROM Books
 UNION
 SELECT User_Id FROM Users

 --UNION ALL OPERATOR
 SELECT Book_ID FROM Books
 UNION ALL
 SELECT User_Id FROM Users

 --LOGICALL
 IF (2=3)
	PRINT'yes, you are right'
ELSE
	PRINT'no, you are wrong'
GO

--========================================================
	--CREATE SEQUENCE
--=========================================================
CREATE SEQUENCE sq_books 
AS BIGINT 
START WITH 1
Increment BY 2
Minvalue 1
Maxvalue 99
Cycle 
Cache 10
GO
--=================================================
	--CTE
--=================================================
WITH Book_CTE (Book_Id,Book_Serial_Num,Book_Name,Author_Name,Book_Edition,Category_Id)
AS 
(
SELECT Book_Id,Book_Serial_Num,Book_Name,Author_Name,Book_Edition,Category_Id
FROM Books 
WHERE Book_Name= 'Accounting'
)

SELECT * FROM Book_CTE
GO

--=================================================
	--@TempTableVariable
--=================================================

DECLARE @TempTableVariable TABLE(
UserID int,
UserName varchar(50), 
UserAddress varchar(150))

INSERT INTO   @TempTableVariable VALUES ( 1, 'MINHAJ','CTG'),( 2, 'RAIHAN','CTG'),( 3, 'YASIN','CTG');

SELECT * FROM @TempTableVariable

--===============================================
--Cast And Convert
--===============================================
SELECT 'Today :'+ CAST(GETDATE() AS Varchar) [Date & Time];
SELECT 'Today :'+ CONVERT(Varchar, GETDATE()) [Date & Time];
GO

Select DATEDIFF (yy,CAST('03/26/1993' as datetime ) , GETDATE ()) AS YEARS,
	   DATEDIFF (MM,CAST('03/26/1993' as datetime ) , GETDATE ())%12 AS MONTHS,
	   DATEDIFF (DD,CAST('03/26/1993' as datetime ) , GETDATE ())%30 AS DAYS
GO

--=========================================================
--Arethmetic Operator
--=========================================================
SELECT 23+2 AS [Sum]
GO
SELECT 24-4 AS [Substraction]
GO
SELECT 50*3 AS [Multiplication]
GO
SELECT 15/2 AS [Divide]
GO
SELECT 16%3 AS [Remainder]
GO

--========================================
--Case Function
--==========================================
SELECT Roles_ID,Role_Name,
	CASE
		When Role_Name ='Admin' then 'Correct Insert' 
		When Role_Name='Student' then 'Correct Insert'
		When Role_Name='Teacher' then 'Correct Insert'
		Else 'Not in Roles' 
	END	As Status
FROM Roles
GO

--=================================================
--While Loop
--==================================================
DECLARE @x Int
SET @x=5
WHILE @x<=10
BEGIN
	PRINT 'Your Provided Value:'+ CAST(@x AS Varchar)
	SET @x=@x+1
END
GO

--===============================================
--WILDCARD
--=================================================
SELECT *
FROM Books
WHERE Book_Name LIKE'A%'
GO


SELECT *
FROM Books
WHERE Book_Name LIKE'%T'
GO

--======================================================
--FLOOR, CEILING, ROUND
--======================================================
DECLARE @x Money =15.49;
SELECT FLOOR(@x) AS [FLOOR RESULT], CEILING(@x) AS [CEILING RESULT], ROUND(@x,0) AS [ROUND RESULT]
GO

DECLARE @value Decimal(10,2)
SET @value =21.06
SELECT ROUND(@value,0) [ROUND RESULT]
SELECT ROUND(@value,1) [ROUND RESULT]
SELECT ROUND(@value,-1) [ROUND RESULT]
GO
--==========================================================
-- And,OR,AVG
--========================================================
SELECT AVG(DISTINCT Book_Id)  
FROM Book_Issues
GO

SELECT *   
FROM Book_Issues  
WHERE Book_Id=5
OR Book_Id=2   
AND Price > 100
ORDER BY Book_Id DESC
GO
--=========================================================
-- IIF, Choose, Coalesce, Isnull, Grouping
--=========================================================

---IIF,Choose
SELECT IIF(Stock>12, '2','3') As IIF_Function,
		CHOOSE(Stock, '2','1') As Choose_Function
FROM Stocks
GO

---Coalesce, Isnull
SELECT Stock_Id, Coalesce(Stock, '6','12')  Stock,
				Isnull('1','3') Stock_Status

FROM Stocks
GO

---Grouping
SELECT Stock_Id, Stock, Grouping(Stock) As Grouping
FROM Stocks
GROUP BY Stock_Id, Stock
GO

--=========================================================
-- ROW_NUMBER,Rank, Dense_Rank,Ntile
--=========================================================
SELECT Book_Id,Book_Name,Author_Name, Book_Edition,
		ROW_NUMBER() Over (Order by Book_Id) As [Row],
		Rank() Over (Partition By Book_Id Order by Book_Name) As [Rank],
		Dense_Rank() Over (Partition By Book_Id Order by Book_Name) As [Dense_Rank]
FROM Books
GO


SELECT Book_Id, Book_Name, NTILE(1) OVER (PARTITION BY Book_Name ORDER BY Book_Name) As Tire1,
						NTILE(2) OVER (PARTITION BY Book_Name ORDER BY Book_Name) As Tire2
FROM Books
GO

--=========================================================
-- First_Value, Last_Value, PERCENT_RANK, CUME_DIST
--=========================================================


SELECT Book_Id, Book_Name, First_Value(Book_Name) OVER (PARTITION BY Book_Id ORDER BY Book_Name) As First_Value		
FROM Books
GO

SELECT Book_Id, Book_Name, Last_Value(Book_Name) OVER (PARTITION BY Book_Id ORDER BY Book_Name) As Last_Value
FROM Books
GO

SELECT Book_Id, Book_Name, PERCENT_RANK() OVER (PARTITION BY Book_Id ORDER BY Book_Name) As [PERCENT_RANK],
						CUME_DIST() OVER (PARTITION BY Book_Id ORDER BY Book_Name) As [CUME_DIST]
FROM Books
GO

--================================
--Store Procedure Insert
--================================
EXEC sp_book_stocks 6,106,'Netwoking','Saddf Malik','2nd',6,4,'Stock','Insert'
EXEC sp_book_stocks 6,106,'Netwoking','Saddf Malik','2nd',6,4,'Books','Update'
GO

Declare @mess varchar(30)
EXEC sp_Category 5,'BBA',@mess output
GO


--===================================================
--				RAISERROR
--===================================================
---USER ERROR MESSAGE

EXEC sp_addmessage
@msgnum = 60000,
@severity = 10,
@msgtext = '%OUT OF STOCK.';

------FIND ERROR MESSAGE------------

SELECT * FROM sys.messages WHERE message_id=60000

----DROP ERROR MESSAGE-------------

EXEC sp_dropmessage 60000

-----========================================================================================================