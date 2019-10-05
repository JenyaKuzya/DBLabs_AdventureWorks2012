USE AdventureWorks2012
GO

--Task1
SELECT e.BusinessEntityID, e.JobTitle, ep.Rate, ROUND(ep.Rate, 0) AS RoundRate
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeePayHistory ep ON ep.BusinessEntityID = e.BusinessEntityID

--Task2
SELECT e.BusinessEntityID, JobTitle, Rate,
RANK() OVER (PARTITION BY e.[BusinessEntityID] ORDER BY eph.[RateChangeDate]) as [ChangeNumber]
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeePayHistory eph
ON e.BusinessEntityID = eph.BusinessEntityID
ORDER BY e.BusinessEntityID;

--Task3
SELECT d.Name, e.JobTitle, e.HireDate, e.BirthDate
FROM HumanResources.Department d
INNER JOIN HumanResources.EmployeeDepartmentHistory ed ON ed.DepartmentID = d.DepartmentID
INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = ed.BusinessEntityID
ORDER BY
e.JobTitle,
	CASE WHEN e.JobTitle NOT LIKE '%[ ]%' THEN e.HireDate
	ELSE e.BirthDate END DESC