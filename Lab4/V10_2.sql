--������� 10

USE AdventureWorks2012;
GO

--a) �������� ������������� VIEW, ������������ ������ �� 
--������ Sales.SalesReason � Sales.SalesOrderHeaderSalesReason, 
--� ����� CustomerID �� ������� Sales.SalesOrderHeader. 
--�������� ���������� ���������� ������ � ������������� �� 
--����� SalesReasonID, SalesOrderID.

CREATE VIEW Sales.vSalesOrderReason
WITH SCHEMABINDING AS
SELECT 
    SOHSR.SalesOrderID
	, SOHSR.SalesReasonID
	, SR.Name
	, SR.ReasonType
	, SOH.CustomerID
FROM Sales.SalesOrderHeaderSalesReason AS SOHSR
INNER JOIN Sales.SalesReason AS SR
    ON (SR.SalesReasonID = SOHSR.SalesReasonID)
INNER JOIN Sales.SalesOrderHeader AS SOH
    ON (SOH.SalesOrderID = SOHSR.SalesOrderID);
GO

CREATE UNIQUE CLUSTERED INDEX IX_vSalesOrderReason
	ON Sales.vSalesOrderReason (SalesOrderID, SalesReasonID);
GO

--b) �������� ���� INSTEAD OF ������� ��� ������������� �� 
--��� �������� INSERT, UPDATE, DELETE. 
--������� ������ ��������� ��������������� �������� 
--� �������� Sales.SalesReason � Sales.SalesOrderHeaderSalesReason 
--��� ���������� CustomerID. 
--���������� �� ������ ����������� � ������� Sales.SalesOrderHeaderSalesReason. 
--�������� �� ������� Sales.SalesReason ����������� ������ � ��� ������, 
--���� ��������� ������ ������ �� ��������� �� 
--Sales.SalesOrderHeaderSalesReason.
CREATE TRIGGER TRG_vSalesOrderReason
ON Sales.vSalesOrderReason
INSTEAD OF UPDATE, INSERT, DELETE
AS
IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
    UPDATE Sales.SalesReason
    SET
    Name = I.Name,
    ReasonType = I.ReasonType,
    ModifiedDate = GETDATE()
    FROM Sales.SalesReason SR
    INNER JOIN inserted I
        ON I.SalesReasonId = SR.SalesReasonId;    
END

IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN
    INSERT INTO Sales.SalesReason (Name, ReasonType, ModifiedDate)
    SELECT Name, ReasonType, GETDATE()
    FROM inserted
    
    INSERT INTO Sales.SalesOrderHeaderSalesReason (SalesOrderId, SalesReasonID, ModifiedDate)
    SELECT I.SalesOrderID, I.SalesReasonID, GETDATE()
    FROM inserted I;
END

IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
    DELETE FROM Sales.SalesOrderHeaderSalesReason
	WHERE SalesOrderID IN (SELECT SalesOrderID FROM deleted)
	    AND SalesReasonID IN (SELECT SalesReasonId FROM deleted)

    DELETE FROM Sales.SalesReason 
    WHERE SalesReasonId = (SELECT SalesReasonId FROM deleted)
        AND SalesReasonId NOT IN (SELECT SalesReasonId FROM Sales.SalesOrderHeaderSalesReason)
END;
GO

--c) �������� ����� ������ � �������������, ������ ����� ������ 
--SalesReason ��� ������������� CustomerID (�������� ��� 11000). 
--������� ������ �������� ����� ������ � ������� Sales.SalesReason 
--� Sales.SalesOrderHeaderSalesReason. �������� ����������� ������ 
--����� �������������. ������� ������.
SELECT * FROM Sales.SalesOrderHeaderSalesReason
WHERE SalesOrderID = 57418
SELECT * FROM Sales.SalesReason 
WHERE SalesReasonID = 2
SELECT * FROM Sales.vSalesOrderReason
WHERE CustomerID = 11000

INSERT INTO Sales.vSalesOrderReason (SalesOrderID, SalesReasonID, Name, ReasonType, CustomerID)
VALUES (57418, 2, 'On Promotion', 'Promotion', 11000)

UPDATE Sales.vSalesOrderReason 
SET Name = 'Magazine Advertisement', 
	ReasonType = 'Marketing'
WHERE SalesOrderID = 57418
    AND SalesReasonID = 2
	AND CustomerID = 11000

DELETE FROM Sales.vSalesOrderReason 
WHERE SalesOrderID = 57418
    AND SalesReasonID = 2
	AND CustomerID = 11000

