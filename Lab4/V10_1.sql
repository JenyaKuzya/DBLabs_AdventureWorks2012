--Вариант 10
USE AdventureWorks2012;
GO
--a) Создайте таблицу Sales.SalesReasonHst, которая будет хранить информацию 
--об изменениях в таблице Sales.SalesReason.
--Обязательные поля, которые должны присутствовать в таблице: 
--ID — первичный ключ IDENTITY(1,1); 
--Action — совершенное действие (insert, update или delete); 
--ModifiedDate — дата и время, когда была совершена операция; 
--SourceID — первичный ключ исходной таблицы; 
--UserName — имя пользователя, совершившего операцию. 
--Создайте другие поля, если считаете их нужными.

CREATE TABLE Sales.SalesReasonHst (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    ModifiedDate DateTime NOT NULL,
    SourceID NVARCHAR(10) NOT NULL,
    UserName NVARCHAR(120)
);
GO

--b) Создайте три AFTER триггера для трех операций 
--INSERT, UPDATE, DELETE для таблицы Sales.SalesReason. 
--Каждый триггер должен заполнять таблицу Sales.SalesReasonHst 
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

--c) Создайте представление VIEW, 
--отображающее все поля таблицы Sales.SalesReason. 
--Сделайте невозможным просмотр исходного кода представления.

CREATE VIEW Sales.vSalesReason 
WITH ENCRYPTION AS
SELECT * 
FROM Sales.SalesReason;
GO

SELECT *
FROM Sales.vSalesReason;

--d) Вставьте новую строку в Sales.SalesReason через представление.
--Обновите вставленную строку. 
--Удалите вставленную строку. 
--Убедитесь, что все три операции отображены в Sales.SalesReasonHst.

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
