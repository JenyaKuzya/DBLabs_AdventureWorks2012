--������� 10

USE AdventureWorks2012;
GO

--�������� scalar-valued �������, ������� ����� ��������� � �������� �������� ��������� id
-- ��� ���� ����������� ������ (Person.PhoneNumberType.PhoneNumberTypeID) � 
--���������� ���������� ��������� ���������� ���� (Person.PersonPhone).

CREATE FUNCTION dbo.fPhohesCount (@PhoneNumberTypeID INT)
RETURNS INT AS
BEGIN
	DECLARE @PhonesCount INT;

	SELECT @PhonesCount = COUNT(BusinessEntityID)
	FROM Person.PersonPhone
	WHERE PhoneNumberTypeID = @PhoneNumberTypeID
	
	RETURN @PhonesCount;
END;
GO

SELECT dbo.fPhohesCount(3) AS PhonesCount;
GO

--�������� inline table-valued �������, ������� ����� ��������� � �������� �������� 
--��������� id ��� ���� ����������� ������ (Person.PhoneNumberType.PhoneNumberTypeID), 
--� ���������� ������ ����������� �� Person.Person 
--(���������� ���������� ��� PersonType = �EM�), ���������� ����� ������� 
--����������� � ���������� ����.

CREATE FUNCTION dbo.fPersonsList (@PhoneNumberTypeID INT)
RETURNS TABLE AS
RETURN (
	SELECT p.BusinessEntityID, P.FirstName, P.MiddleName, P.LastName
	FROM Person.Person P
	INNER JOIN Person.PersonPhone PPh
	    ON P.BusinessEntityID = PPh.BusinessEntityID
	WHERE PPh.PhoneNumberTypeID = @PhoneNumberTypeID
	    AND P.PersonType = 'EM'
);
GO

SELECT * 
FROM dbo.fPersonsList(3);
GO

--�������� ������� ��� ������� ���� ����������� ������, �������� �������� CROSS APPLY. 
--�������� ������� ��� ������� ���� ����������� ������, �������� �������� OUTER APPLY.
SELECT PT.PhoneNumberTypeID, F.BusinessEntityId
FROM Person.PhoneNumberType PT
CROSS APPLY dbo.fPersonsList(PT.PhoneNumberTypeID) F
ORDER BY PT.PhoneNumberTypeID, F.BusinessEntityId;

SELECT PT.PhoneNumberTypeID, F.BusinessEntityId
FROM Person.PhoneNumberType PT
OUTER APPLY dbo.fPersonsList(PT.PhoneNumberTypeID) F
ORDER BY PT.PhoneNumberTypeID, F.BusinessEntityId;

GO
--�������� ��������� inline table-valued �������, ������ �� multistatement table-valued 
--(�������������� �������� ��� �������� ��� �������� inline table-valued �������).

CREATE FUNCTION dbo.fPersonsListMSTV (@PhoneNumberTypeID INT)
RETURNS @Result TABLE (
    BusinessEntityID INT,
	FirstName NVARCHAR(50),
	MiddleName NVARCHAR(50),
	LastName NVARCHAR(50)
) AS
BEGIN
    INSERT INTO @Result (BusinessEntityID, FirstName, MiddleName, LastName)
	SELECT p.BusinessEntityID, P.FirstName, P.MiddleName, P.LastName
	FROM Person.Person P
	INNER JOIN Person.PersonPhone PPh
	    ON P.BusinessEntityID = PPh.BusinessEntityID
	WHERE PPh.PhoneNumberTypeID = @PhoneNumberTypeID
	    AND P.PersonType = 'EM'
    RETURN
END;
GO

SELECT * FROM dbo.fPersonsListMSTV (3);
GO




