USE AdventureWorks2012;
GO

--DROP PROCEDURE dbo.SalesByRegions;  

CREATE PROCEDURE dbo.SalesByRegions (@Region NVARCHAR(200)) AS
BEGIN 
	DECLARE @SQL NVARCHAR(1000);
	SET @SQL = 'SELECT *
				FROM (
						SELECT 
						    YEAR(SOH.OrderDate) AS Year,
							ST.CountryRegionCode AS Region,
							SOH.TotalDue
						FROM Sales.SalesOrderHeader SOH
						INNER JOIN Sales.SalesTerritory ST
						    ON SOH.TerritoryID = ST.TerritoryID
					) AS T
					PIVOT
					(
						SUM(TotalDue)
						FOR Region IN (' + @Region + ')
					) as pivotT
				ORDER BY 1;'
	EXEC(@sql);
END
GO

EXEC dbo.SalesByRegions '[AU],[CA],[DE],[FR],[GB],[US]';

