-- добавьте в таблицу dbo.Employee поле Name типа nvarchar размерностью 60 символов;

ALTER TABLE [dbo].[Employee]
ADD [Name] NVARCHAR(60)
;

------------------------------------------------------------------------------------

-- объявите табличную переменную с такой же структурой как dbo.Employee
-- и заполните ее данными из dbo.Employee.
-- Поле Name заполните данными таблицы Person.Person, из полей Title и FirstName.
-- Если Title содержит null значение, замените его на ‘M.’;

DECLARE @Employee TABLE
(
    [BusinessEntityID] INT NOT NULL
,   [NationalIDNumber] NVARCHAR(15) NOT NULL
,   [LoginID] NVARCHAR(256) NOT NULL
,   [JobTitle] NVARCHAR(50) NOT NULL
,   [BirthDate] DATE NOT NULL
,   [MaritalStatus] NVARCHAR(1)
,   [Gender] NCHAR(1) NOT NULL
,   [HireDate] DATE NOT NULL
,   [VacationHours] SMALLINT NOT NULL
,   [SickLeaveHours] SMALLINT NOT NULL
,   [ModifiedDate] DATETIME NOT NULL
,   EmployeeID BIGINT PRIMARY KEY
,   [Name] NVARCHAR(60)
)
;

INSERT INTO @Employee
SELECT
    emp.[BusinessEntityID]
,   emp.[NationalIDNumber]
,   emp.[LoginID]
,   emp.[JobTitle]
,   emp.[BirthDate]
,   emp.[MaritalStatus]
,   emp.[Gender]
,   emp.[HireDate]
,   emp.[VacationHours]
,   emp.[SickLeaveHours]
,   emp.[ModifiedDate]
,   emp.EmployeeID
,   CASE
        WHEN pers.[Title] IS NULL THEN 'M.'
        ELSE pers.[FirstName]
    END as [Name]
FROM [dbo].[Employee] emp
JOIN [Person].[Person] pers
    ON emp.[BusinessEntityID] = pers.[BusinessEntityID]
;

SELECT * FROM @Employee
-------------------
-- обновите поле Name в dbo.Employee данными из табличной переменной;

UPDATE dbo.Employee
SET [Name] = empv.[Name]
FROM dbo.Employee as e
INNER JOIN @Employee as empv on empv.BusinessEntityID = e.BusinessEntityID

SELECT * FROM [dbo].[Employee]
------------------------------------------------------------------------------------

 --удалите из dbo.Employee сотрудников, которые хотя бы раз меняли отдел
 --(таблица HumanResources.EmployeeDepartmentHistory);

DELETE FROM [dbo].[Employee]
WHERE [BusinessEntityID] IN
(
    SELECT
        edh.[BusinessEntityID]
    FROM [HumanResources].[EmployeeDepartmentHistory] edh
    WHERE edh.[EndDate] IS NOT NULL
)
;

------------------------------------------------------------------------------------

-- удалите поле Name из таблицы, удалите все созданные ограничения и значения по умолчанию;

ALTER TABLE [dbo].[Employee]
DROP COLUMN [Name];

DECLARE @Command nvarchar(MAX) = N'' ;

SELECT 
	@Command += N'ALTER TABLE [dbo].[Employee]
	DROP CONSTRAINT ' + QUOTENAME([CONSTRAINT_NAME]) + ';'
FROM [INFORMATION_SCHEMA].[CONSTRAINT_TABLE_USAGE]
WHERE [TABLE_SCHEMA] = 'dbo'
    AND [TABLE_NAME] = 'Employee';

SELECT 
	@Command += 'ALTER TABLE [dbo].[Employee]
	DROP CONSTRAINT ' + d.[name] + ';'
FROM [sys].[tables] t
JOIN [sys].[schemas] s
	ON t.[schema_id] = s.[schema_id]
JOIN [sys].[default_constraints] d
	ON t.[object_id] = d.[parent_object_id]
WHERE s.[name] = 'dbo'
    AND t.[name] = 'Employee';

PRINT @Command;
EXECUTE (@Command);

------------------------------------------------------------------------------------
/**/
-- удалите таблицу dbo.Employee.

DROP TABLE [dbo].[Employee]
;
