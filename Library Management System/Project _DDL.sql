--================================================
		---- Create Database 
--================================================

USE Master
DROP DATABASE IF EXISTS LMSDB 
GO

USE Master
GO

DECLARE @data_path Nvarchar (256);

SET @data_path = (SELECT SUBSTRING(physical_name,1,CHARINDEX(N'master.mdf',LOWER(physical_name))-1)
					FROM master.sys.master_files
					WHERE database_id=1 And file_id=1);

EXEC
('Create Database LMSDB
	On Primary
	(Name= LMSDB_Data, Filename= '''+ @data_path +'LMSDB_Data.mdf'', Size=20mb, MaxSize=120mb, FileGrowth=4%)
	Log On
	(Name= LMSDB_Log, Filename= '''+ @data_path +'LMSDB_Log.ldf'', Size=2mb, MaxSize=50mb, FileGrowth=2mb)
')
GO

USE LMSDB
GO

ALTER DATABASE LMSDB MODIFY FILE 
(Name=N'LMSDB_Data', Size=25MB, MaxSize=100MB, FileGrowth=5% )
GO

ALTER DATABASE LMSDB MODIFY FILE 
(Name=N'LMSDB_Log', Size = 10MB, MaxSize = 100MB, FileGrowth = 1MB)
GO

---===============
---Drop Database
---===============
USE Master
DROP DATABASE LMSDB
GO

--================================================
	---Create Schema, Drop Schema
--================================================
USE LMSDB
GO

CREATE SCHEMA LIB
GO

DROP SCHEMA LIB
GO
--================================================
	---Create Table
--================================================


CREATE TABLE Roles
(
	Roles_ID Int Identity Primary Key,
	Role_Name Varchar(30) not null
);
GO


CREATE TABLE Category 
(
	Category_Id Int Identity Primary Key,
	Book_Category Varchar(30) not null
);
GO


CREATE TABLE Users
(
	User_Id Int Identity(1,1) Primary Key,
	Roles_ID Int Foreign Key References Roles(Roles_ID),
	Name Varchar(20) not null,
	Degree_Program Varchar(25) not null,
	Contact Varchar(15) not null CHECK ((Contact like'[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]')),
	Address Varchar(50) not null,
	Year Int
);
GO


CREATE TABLE Books
(
	Book_Id Int Identity Primary Key,
	Book_Serial_Num Int,
	Book_Name Varchar(30),
	Author_Name Varchar(30),
	Book_Edition Varchar(30),
	Category_Id Int Foreign Key References Category(Category_Id) ON UPDATE CASCADE
);
GO


CREATE TABLE Book_Issues
(
	Bk_Issue_Id Int Identity Primary Key,
	Date_Of_Issue Date not null Default (Getdate()),
	Date_Of_Return Date not null,
	Price Money not null,
	Vat AS (Price*.15),
	Total As (Price+(Price*.15)),
	Book_Id Int Foreign Key References Books(Book_Id),
	[User_Id] Int Foreign Key References Users([User_Id]),
	Category_Id Int Foreign Key References Category(Category_Id),
);
GO


CREATE TABLE Stocks
(
	Stock_ID int primary key identity(1,1),
	Stock Int,
	Book_Id Int Foreign Key References Books(Book_Id)
);
GO

--==================================================
-- Local Temporaray Table & Global Table
--==================================================

CREATE TABLE #BookAgent
(
	BookAgentID INT PRIMARY KEY,
	BookAgentName Varchar(20) not null
);
GO

CREATE TABLE ##GlobalStock
(
	StockID INT,
	BookAgentID Int Foreign Key References #BookAgent(BookAgentID)
);
GO

--============================================================
--- View
--============================================================

CREATE VIEW Vw__Stocks
AS
(
	Select *
	From Stocks
);
GO
--===========================================================
--View WITH Schemabinding
--===========================================================

CREATE VIEW vw_Books
WITH SCHEMABINDING
AS
SELECT *
FROM Books
JOIN Book_Issues
ON Books.Book_Id = Book_Issues.Bk_Issue_Id
JOIN Stocks
ON Stocks.Stock_ID = Book_Issues.Bk_Issue_Id
GO

--==============================================
--View With Encryption
--==============================================

CREATE VIEW Vw_Books02
WITH ENCRYPTION
AS
SELECT Book_Id, Book_Name, Book_Serial_Num, Author_Name, Book_Edition
FROM Books
GO

--=================================================
--CREATE NONCLUSTERED INDEX
--=================================================

CREATE NONCLUSTERED INDEX booksindecx ON Books(Author_Name)
GO

--================================================
--Create Clustered Index
--================================================

CREATE CLUSTERED INDEX stockindex ON ##GlobalStock(StockID)
GO

--===============================================
--Function Create Scalar
--===============================================
Create Function fn_TotalVat
(
@book_id int
)
RETURNS int
As
BEGIN
	RETURN
	(Select SUM(Vat) From Book_Issues Where Book_Id=@book_id)
END
GO

PRINT dbo.fn_TotalVat(1)
GO

--===================================
--Tabular Function
--===================================
Create Function dbo.fn_Table(@book_author varchar(30))
Returns Table 
As
Return
(Select Books.Book_Id, Author_Name, Price, Vat, Total
From Books
Join Book_Issues
On Books.Book_Id=Book_Issues.Book_Id
Where Author_Name=@book_author
)
GO

Select * From dbo.fn_Table('Qadri')
Go

--=================================================
--Create Store Procedure
--=================================================
Create PROC sp_book_stocks
@bookid int,
@bookserialnum int,
@bookname varchar(30),
@bookauther varchar(30),
@bookedition varchar(30),
@stockid int,
@stock int,
@tablename varchar(20),
@operationname varchar(20)
AS
BEGIN

		IF @tablename='Books' and @operationname='Insert'
		Begin
		Insert into Books values(@bookserialnum,@bookname,@bookauther,@bookedition,@stock)
		End
		IF @tablename='Books' and @operationname='Update'
		Begin
		update Books set Book_Name=@bookname where Book_ID=@bookid
		End
		IF @tablename='Books' and @operationname='Delete'
		Begin
		Delete Books where Book_ID=@bookid
		End
		IF @tablename='Books' and @operationname='Select'
		Begin
		select * from Books
		End
		IF @tablename='Stocks' and @operationname='Insert'
		Begin
		Insert into Stocks values(@stock)
		End
		IF @tablename='Stocks' and @operationname='Update'
		Begin
		Update Stocks set Stock=@stock where Stock_ID=@stockid
		End
		IF @tablename='Stocks' and @operationname='Delete'
		Begin
		delete Stocks where Stock_ID=@stockid
		End
		IF @tablename='Stocks' and @operationname='Select'
		Begin
		select * from Stocks
		End
End
GO
----======================================================================
--Store Procedure(Commit,Rollbac,Try,Catch)
--======================================================================
Create proc sp_Category
@categoryid int,
@bookcategory varchar(30),
@message varchar(30) output	 
As
Begin
	Set Nocount On
	Begin Try
		Begin Transaction
			Insert Into Category(Category_Id, Book_Category)
			values (@categoryid,@bookcategory)
			set @message='Data Inserted Successfully'
			print @message
		Commit Transaction	
	End Try
	Begin Catch
		Rollback transaction	
		Print 'Something goes wrong'
	End Catch
End
Go

--===============================================
---CREATE INSTEAD TRIGGER
--===============================================
CREATE TRIGGER tr_insteadOftriger ON Books
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @rowcount int
	SET @rowcount =@@ROWCOUNT 
	IF(@rowcount > 5)
		BEGIN
			RAISERROR( 'You can not insert more then 5 Books', 16, 1)
		END
	ELSE 
		PRINT 'Insert is successful'
END
GO

--UPDATE FOR TRIGGER
CREATE TRIGGER tr_CheckingInsertUpdate ON Book_Issues
FOR INSERT, UPDATE
AS
	If EXISTS
	(
	SELECT 'True'
	FROM Inserted i
	JOIN Book_Issues AS s
	ON i.Book_ID = s.Book_ID
	)
Begin
	 RAISERROR('Data Insertion is not Allowed', 16, 1)
	 PRINT 'Insertion Error'
	 ROLLBACK TRAN
END
GO

--UPDATE FOR TRIGGER
UPDATE Book_Issues
SET Price = 300
WHERE Bk_Issue_Id = 4
GO

SELECT * FROM Book_Issues
GO

--DELETE FOR TRIGGER
CREATE TRIGGER tr_CheckingDelete On Book_Issues
FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM Deleted d)
		BEGIN
			RAISERROR('Data Deletion is not Allowed', 16, 1)
			PRINT 'Deletion Error'
			ROLLBACK TRAN
		END
END
GO

DELETE Book_Issues WHERE Bk_Issue_Id = 4
GO

----=======================================================================================================