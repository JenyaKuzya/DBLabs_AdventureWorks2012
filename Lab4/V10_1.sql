--¬ариант 10
USE AdventureWorks2012;
GO
--a) —оздайте таблицу Sales.SalesReasonHst, котора€ будет хранить информацию 
--об изменени€х в таблице Sales.SalesReason.
--ќб€зательные пол€, которые должны присутствовать в таблице: 
--ID Ч первичный ключ IDENTITY(1,1); 
--Action Ч совершенное действие (insert, update или delete); 
--ModifiedDate Ч дата и врем€, когда была совершена операци€; 
--SourceID Ч первичный ключ исходной таблицы; 
--UserName Ч им€ пользовател€, совершившего операцию. 
--—оздайте другие пол€, если считаете их нужными.

CREATE TABLE Sales.SalesReasonHst (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    ModifiedDate DateTime NOT NULL,
    SourceID NVARCHAR(10) NOT NULL,
    UserName NVARCHAR(120)
);
GO

--b) —оздайте три AFTER триггера дл€ трех операций 
--INSERT, UPDATE, DELETE дл€ таблицы Sales.SalesReason. 
-- аждый триггер должен заполн€ть таблицу Sales.SalesReasonHst 
--с указанием типа операции в поле Action.
DROP TRIGGER Sales.I_TRG_SalesReason;
GO

CREATE TRIGGER I_TRG_SalesReason
ON Sales.SalesReason
AFTER INSERT
AS
    INSERT INTO Sales.SalesReasonHst (
	        [Action]
           ,[ModifiedDate]
           ,[SourceID]
           ,[UserName])
    SELECT 
        'INSERT' 
        , GETDATE() 
        , SalesReasonID
        , SYSTEM_USER
    FROM inserted;
GO

DROP TRIGGER Sales.U_TRG_SalesReason;
GO

CREATE TRIGGER U_TRG_SalesReason
ON Sales.SalesReason
AFTER UPDATE
AS
    INSERT INTO Sales.SalesReasonHst (
	        [Action]
            ,[ModifiedDate]
            ,[SourceID]
            ,[UserName])
    SELECT
            'UPDATE' 
            , GETDATE() 
            , SalesReasonID
            , SYSTEM_USER
FROM inserted;
GO

DROP TRIGGER Sales.D_TRG_SalesReason;
GO

CREATE TRIGGER D_TRG_SalesReason
ON Sales.SalesReason
AFTER DELETE
AS
    INSERT INTO Sales.SalesReasonHst (
            [Action]
            ,[ModifiedDate]
            ,[SourceID]
            ,[UserName])
    SELECT 
    	    'DELETE' 
    	    , GETDATE()
    	    , SalesReasonID
    	    , SYSTEM_USER
FROM deleted;
GO

--c) —оздайте представление VIEW, 
--отображающее все пол€ таблицы Sales.SalesReason. 
--—делайте невозможным просмотр исходного кода представлени€.

CREATE VIEW Sales.vSalesReason 
WITH ENCRYPTION AS
SELECT * 
FROM Sales.SalesReason;
GO

SELECT *
FROM Sales.vSalesReason;

--d) ¬ставьте новую строку в Sales.SalesReason через представление.
--ќбновите вставленную строку. 
--”далите вставленную строку. 
--”бедитесь, что все три операции отображены в Sales.SalesReasonHst.

INSERT INTO Sales.vSalesReason (Name, ReasonType, ModifiedDate)
VALUES ('MyName', 'Other', GETDATE())

SELECT *
FROM Sales.vSalesReason

UPDATE Sales.vSalesReason 
SET Name = 'Name'
WHERE SalesReasonID = 11

DELETE FROM Sales.vSalesReason
WHERE SalesReasonID = 11

SELECT *
FROM Sales.SalesReasonHst
