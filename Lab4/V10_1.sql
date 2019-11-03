--������� 10
USE AdventureWorks2012;
GO
--a) �������� ������� Sales.SalesReasonHst, ������� ����� ������� ���������� 
--�� ���������� � ������� Sales.SalesReason.
--������������ ����, ������� ������ �������������� � �������: 
--ID � ��������� ���� IDENTITY(1,1); 
--Action � ����������� �������� (insert, update ��� delete); 
--ModifiedDate � ���� � �����, ����� ���� ��������� ��������; 
--SourceID � ��������� ���� �������� �������; 
--UserName � ��� ������������, ������������ ��������. 
--�������� ������ ����, ���� �������� �� �������.

CREATE TABLE Sales.SalesReasonHst (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    ModifiedDate DateTime NOT NULL,
    SourceID NVARCHAR(10) NOT NULL,
    UserName NVARCHAR(120)
);
GO

--b) �������� ��� AFTER �������� ��� ���� �������� 
--INSERT, UPDATE, DELETE ��� ������� Sales.SalesReason. 
--������ ������� ������ ��������� ������� Sales.SalesReasonHst 
--� ��������� ���� �������� � ���� Action.
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

--c) �������� ������������� VIEW, 
--������������ ��� ���� ������� Sales.SalesReason. 
--�������� ����������� �������� ��������� ���� �������������.

CREATE VIEW Sales.vSalesReason 
WITH ENCRYPTION AS
SELECT * 
FROM Sales.SalesReason;
GO

SELECT *
FROM Sales.vSalesReason;

--d) �������� ����� ������ � Sales.SalesReason ����� �������������.
--�������� ����������� ������. 
--������� ����������� ������. 
--���������, ��� ��� ��� �������� ���������� � Sales.SalesReasonHst.

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
