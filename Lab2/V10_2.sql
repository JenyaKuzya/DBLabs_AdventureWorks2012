-- ������� �)

--DROP TABLE [dbo].[Employee]


CREATE TABLE [dbo].[Employee](								
	[BusinessEntityID] [int] NOT NULL,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar] NOT NULL,
	[Gender] [nchar] NOT NULL,
	[HireDate] [date] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL)

-- ������� �)

ALTER TABLE [dbo].[Employee] ADD [EmployeeID] [BIGINT] IDENTITY(0,2) PRIMARY KEY; 


-- ������� �)

ALTER TABLE [dbo].[Employee] ADD CONSTRAINT birth_date_check CHECK (BirthDate >= '1900-01-01' AND BirthDate <= GetDate())

-- ������� d)

ALTER TABLE [dbo].[Employee] ADD CONSTRAINT default_type DEFAULT GETDATE() FOR [HireDate];

-- ������� �)

INSERT INTO [dbo].[Employee]
           ([BusinessEntityID]
           ,[NationalIDNumber]
           ,[LoginID]
           ,[JobTitle]
		   ,[BirthDate]
		   ,[MaritalStatus]
		   ,[Gender]
		   ,[VacationHours]
		   ,[SickLeaveHours]
		   ,[ModifiedDate])
SELECT [e].[BusinessEntityID]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[JobTitle]
	  ,[BirthDate]
	  ,[MaritalStatus]
	  ,[Gender]
	  ,[VacationHours]
	  ,[SickLeaveHours]
	  ,[e].[ModifiedDate]
FROM [HumanResources].[Employee] AS [e]
INNER JOIN Person.Person AS [p] ON e.BusinessEntityID = p.BusinessEntityID
WHERE [p].[EmailPromotion] = '0';

SELECT *
FROM dbo.Employee

-- ������� f)
ALTER TABLE [dbo].[Employee] ALTER COLUMN [MaritalStatus] [NVARCHAR](1) NULL; 