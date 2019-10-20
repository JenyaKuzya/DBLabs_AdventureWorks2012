-- выполните код, созданный во втором задании второй лабораторной работы.
-- ƒобавьте в таблицу dbo.Employee поле SumSubTotal MONEY.
-- “акже создайте в таблице вычисл€емое поле LeaveHours,
-- вычисл€ющее сумму часов отпуска и больничных в пол€х VacationHours и SickLeaveHours;


ALTER TABLE [dbo].[Employee]
ADD [SumSubTotal] MONEY
,   [LeaveHours] AS ([VacationHours] + [SickLeaveHours])
;

------------------------------------------------------------------------------------------

-- создайте временную таблицу #Employee, с первичным ключом по полю ID.
-- ¬ременна€ таблица должна включать все пол€ таблицы dbo.Employee за исключением пол€ LeaveHours;

IF OBJECT_ID('tempdb..#Employee') IS NOT NULL DROP TABLE #Employee
GO

CREATE TABLE #Employee
(
	[BusinessEntityID] INT NOT NULL
,   [NationalIDNumber] NVARCHAR(15) NOT NULL
,   [LoginID] NVARCHAR(256) NOT NULL
,   [JobTitle] NVARCHAR(50) NOT NULL
,   [BirthDate] DATE NOT NULL
,   [MaritalStatus] NVARCHAR(1) NULL
,   [Gender] NCHAR(1) NOT NULL
,   [HireDate] DATE NOT NULL
,   [VacationHours] SMALLINT NOT NULL
,   [SickLeaveHours] SMALLINT NOT NULL
,   [ModifiedDate] DATETIME NOT NULL
,   [EmployeeID] BIGINT NOT NULL PRIMARY KEY
,   [SumSubTotal] MONEY NULL
)
;

------------------------------------------------------------------------------------------

-- заполните временную таблицу данными из dbo.Employee.
-- ѕосчитайте общую сумму без учета налогов и стоимости доставки (SubTotal),
-- на которую сотрудник (EmployeeID) оформил заказов в таблице Purchasing.PurchaseOrderHeader
-- и заполните этими значени€ми поле SumSubTotal.
-- ѕодсчет суммы осуществите в Common Table Expression (CTE);

WITH EMPLOYEES AS (
	SELECT		emp.[BusinessEntityID]
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
,   emp.[EmployeeID]
,   pp.[SumSubTotal]
	FROM [dbo].[Employee] AS [emp]
	INNER JOIN
	(
		SELECT
        poh.[EmployeeID]
    ,   SUM(poh.[SubTotal]) as [SumSubTotal]
    FROM [Purchasing].[PurchaseOrderHeader] poh
    GROUP BY poh.[EmployeeID]
	)pp  ON [emp].[EmployeeID] = [pp].[EmployeeID])
INSERT INTO [#Employee](
            	[BusinessEntityID]
,   [NationalIDNumber]
,   [LoginID]
,   [JobTitle]
,   [BirthDate]
,   [MaritalStatus] 
,   [Gender]
,   [HireDate]
,   [VacationHours] 
,   [SickLeaveHours]
,   [ModifiedDate]
,   [EmployeeID]
,   [SumSubTotal])
SELECT * FROM EMPLOYEES;

SELECT *
FROM #Employee

--------------------------------------------------------------------------------------------

---- удалите из таблицы dbo.Employee строки, где LeaveHours > 160;

DELETE FROM [dbo].[Employee]
WHERE [LeaveHours] > 160
;

SELECT * FROM [dbo].[Employee]
--------------------------------------------------------------------------------------------

---- напишите Merge выражение, использующее dbo.Employee как target,
---- а временную таблицу как source. ƒл€ св€зи target и source используйте ID.
---- ќбновите поле SumSubTotal, если запись присутствует в source и target.
---- ≈сли строка присутствует во временной таблице, но не существует в target,
---- добавьте строку в dbo.Employee.
---- ≈сли в dbo.Employee присутствует така€ строка, которой не существует во временной таблице,
---- удалите строку из dbo.Employee.

MERGE [dbo].[Employee] AS target  
USING #Employee AS source
ON (target.[EmployeeID] = source.[EmployeeID])  
WHEN MATCHED THEN   
    UPDATE SET target.[SumSubTotal] = source.[SumSubTotal]
WHEN NOT MATCHED BY TARGET THEN  
    INSERT
    (
    	[BusinessEntityID]
    ,   [NationalIDNumber]
    ,   [LoginID]
    ,   [JobTitle]
    ,   [BirthDate]
    ,   [MaritalStatus] 
    ,   [Gender]
    ,   [HireDate]
    ,   [VacationHours] 
    ,   [SickLeaveHours]
    ,   [ModifiedDate]
    ,   [SumSubTotal]
    )  
    VALUES
    (
    	source.[BusinessEntityID]
    ,   source.[NationalIDNumber]
    ,   source.[LoginID]
    ,   source.[JobTitle]
    ,   source.[BirthDate]
    ,   source.[MaritalStatus] 
    ,   source.[Gender]
    ,   source.[HireDate]
    ,   source.[VacationHours] 
    ,   source.[SickLeaveHours]
    ,   source.[ModifiedDate]
    ,   source.[SumSubTotal]
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
;
