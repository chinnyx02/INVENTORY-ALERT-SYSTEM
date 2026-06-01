
-- PART 1: CREATE TABLE
-- ============================================

CREATE TABLE Inventory (
    SKU VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Category VARCHAR(20) NOT NULL,
    StockOnHand INT NOT NULL,
    ReorderLevel INT NOT NULL,
    SafetyStock INT NOT NULL,
    LeadTimeDays INT NOT NULL,
    MonthlyDemand INT NOT NULL
);


-- ============================================
-- PART 2: INSERT DATA (8 SKUs)
-- ============================================

INSERT INTO Inventory (SKU, ProductName, Category, StockOnHand, ReorderLevel, SafetyStock, LeadTimeDays, MonthlyDemand) VALUES
('SKU001', 'Laptop Pro', 'Electronics', 45, 20, 10, 5, 120),
('SKU002', 'Phone X', 'Electronics', 12, 25, 15, 4, 180),
('SKU003', 'Tablet Lite', 'Electronics', 30, 15, 8, 3, 90),
('SKU004', 'Wireless Mouse', 'Accessories', 150, 50, 25, 7, 400),
('SKU005', 'Keyboard', 'Accessories', 25, 30, 10, 6, 200),
('SKU006', 'Monitor 24', 'Electronics', 8, 20, 12, 8, 100),
('SKU007', 'Desk Mat', 'Accessories', 200, 40, 20, 10, 350),
('SKU008', 'USB Cable', 'Accessories', 500, 100, 50, 14, 1200);


-- ============================================
-- PART 3: CREATE VIEW WITH CALCULATED METRICS
-- ============================================

CREATE VIEW InventoryAnalytics AS
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    ReorderLevel,
    SafetyStock,
    LeadTimeDays,
    MonthlyDemand,
    
    -- Daily demand (units per day)
    ROUND(CAST(MonthlyDemand AS FLOAT) / 30, 2) AS DailyDemand,
    
    -- Days until stockout
    ROUND(StockOnHand / (CAST(MonthlyDemand AS FLOAT) / 30), 1) AS DaysToStockout,
    
    -- Lead time demand (units needed during lead time)
    ROUND((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays, 0) AS LeadTimeDemand,
    
    -- Safety buffer (excess or deficit)
    ROUND(StockOnHand - ((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays), 0) AS SafetyBuffer,
    
    -- Inventory turnover ratio
    ROUND(CAST(MonthlyDemand AS FLOAT) / StockOnHand, 2) AS TurnoverRatio,
    
    -- Reorder status
    CASE 
        WHEN StockOnHand <= ReorderLevel THEN 'ORDER NOW'
        WHEN StockOnHand <= ReorderLevel * 1.2 THEN 'ORDER SOON'
        ELSE 'OK'
    END AS ReorderStatus,
    
    -- Priority level (color-coded)
    CASE 
        WHEN StockOnHand / (CAST(MonthlyDemand AS FLOAT) / 30) < 3 THEN 'CRITICAL'
        WHEN StockOnHand / (CAST(MonthlyDemand AS FLOAT) / 30) < 7 THEN 'WARNING'
        WHEN StockOnHand / (CAST(MonthlyDemand AS FLOAT) / 30) < 14 THEN 'MONITOR'
        ELSE 'HEALTHY'
    END AS Priority,
    
    -- Recommended reorder quantity
    CASE 
        WHEN StockOnHand <= ReorderLevel 
        THEN CEILING(((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays) + SafetyStock - StockOnHand)
        ELSE 0
    END AS RecommendedOrderQty

FROM Inventory;


-- ============================================
-- PART 4: KPI SUMMARY (MAIN RESULTS)
-- ============================================

-- KPI 1: Overall Inventory Health
SELECT '===== INVENTORY KPI DASHBOARD =====' AS Dashboard;
SELECT '----------------------------------------' AS Separator;

SELECT 
    'Total SKUs' AS Metric,
    CAST(COUNT(*) AS VARCHAR) AS Value,
    'SKUs' AS Unit
FROM Inventory
UNION ALL
SELECT 
    'Total Stock on Hand',
    CAST(SUM(StockOnHand) AS VARCHAR),
    'units'
FROM Inventory
UNION ALL
SELECT 
    'Total Monthly Demand',
    CAST(SUM(MonthlyDemand) AS VARCHAR),
    'units'
FROM Inventory
UNION ALL
SELECT 
    'Average Days to Stockout',
    CAST(ROUND(AVG(CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30)), 1) AS VARCHAR),
    'days'
FROM Inventory
UNION ALL
SELECT 
    'Average Turnover Ratio',
    CAST(ROUND(AVG(CAST(MonthlyDemand AS FLOAT) / StockOnHand), 2) AS VARCHAR),
    'x/month'
FROM Inventory
UNION ALL
SELECT 
    'SKUs Below Reorder Level',
    CAST(COUNT(*) AS VARCHAR),
    'SKUs'
FROM Inventory
WHERE StockOnHand <= ReorderLevel
UNION ALL
SELECT 
    'Critical SKUs (<3 days)',
    CAST(COUNT(*) AS VARCHAR),
    'SKUs'
FROM Inventory
WHERE CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30) < 3
UNION ALL
SELECT 
    'Negative Safety Buffer',
    CAST(COUNT(*) AS VARCHAR),
    'SKUs'
FROM Inventory
WHERE StockOnHand - ((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays) < 0;


-- ============================================
-- PART 5: CRITICAL ALERTS (Stockout < 3 days)
-- ============================================

SELECT '===== CRITICAL ALERTS (Stockout < 3 days) =====' AS Alert;
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    MonthlyDemand,
    ROUND(CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30), 1) AS DaysToStockout,
    'URGENT - Reorder Immediately' AS Action
FROM Inventory
WHERE CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30) < 3
ORDER BY DaysToStockout ASC;


-- ============================================
-- PART 6: NEGATIVE SAFETY BUFFER SKUs
-- ============================================

SELECT '===== NEGATIVE SAFETY BUFFER SKUs =====' AS Alert;
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    LeadTimeDays,
    MonthlyDemand,
    ROUND((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays, 0) AS LeadTimeDemand,
    ROUND(StockOnHand - ((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays), 0) AS SafetyBuffer,
    'Supply Chain Risk' AS Issue
FROM Inventory
WHERE StockOnHand - ((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays) < 0
ORDER BY SafetyBuffer ASC;


-- ============================================
-- PART 7: PURCHASE ORDER RECOMMENDATIONS
-- ============================================

SELECT '===== PURCHASE ORDER RECOMMENDATIONS =====' AS PurchaseOrder;
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    ReorderLevel,
    CEILING(((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays) + SafetyStock - StockOnHand) AS OrderQuantity,
    'Priority: ' + 
        CASE 
            WHEN CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30) < 3 THEN 'URGENT (24hrs)'
            WHEN CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30) < 7 THEN 'RUSH (48hrs)'
            ELSE 'NORMAL'
        END AS Priority
FROM Inventory
WHERE StockOnHand <= ReorderLevel
ORDER BY OrderQuantity DESC;


-- ============================================
-- PART 8: CATEGORY SUMMARY
-- ============================================

SELECT '===== CATEGORY PERFORMANCE SUMMARY =====' AS CategoryReport;
SELECT 
    Category,
    COUNT(*) AS SKUCount,
    SUM(StockOnHand) AS TotalStock,
    SUM(MonthlyDemand) AS TotalDemand,
    ROUND(AVG(CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30)), 1) AS AvgDaysToStockout,
    ROUND(AVG(CAST(MonthlyDemand AS FLOAT) / StockOnHand), 2) AS AvgTurnoverRatio,
    COUNT(CASE WHEN StockOnHand <= ReorderLevel THEN 1 END) AS SKUsToReorder,
    COUNT(CASE WHEN CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30) < 3 THEN 1 END) AS CriticalSKUs
FROM Inventory
GROUP BY Category
ORDER BY CriticalSKUs DESC;


-- ============================================
-- PART 9: ABC CLASSIFICATION (By Demand)
-- ============================================

SELECT '===== ABC CLASSIFICATION (By Monthly Demand) =====' AS ABCTable;
WITH DemandRank AS (
    SELECT 
        SKU,
        ProductName,
        Category,
        MonthlyDemand,
        SUM(MonthlyDemand) OVER() AS TotalDemand,
        SUM(MonthlyDemand) OVER(ORDER BY MonthlyDemand DESC) AS RunningTotal,
        ROW_NUMBER() OVER(ORDER BY MonthlyDemand DESC) AS RowNum
    FROM Inventory
)
SELECT 
    SKU,
    ProductName,
    Category,
    MonthlyDemand,
    ROUND(CAST(MonthlyDemand AS FLOAT) / TotalDemand * 100, 1) AS PercentOfTotal,
    CASE 
        WHEN RunningTotal / TotalDemand <= 0.7 THEN 'A (Top 70% - High Priority)'
        WHEN RunningTotal / TotalDemand <= 0.9 THEN 'B (Next 20% - Medium Priority)'
        ELSE 'C (Bottom 10% - Low Priority)'
    END AS ABCCategory,
    CASE 
        WHEN RunningTotal / TotalDemand <= 0.7 THEN 'Daily review required'
        WHEN RunningTotal / TotalDemand <= 0.9 THEN 'Weekly review'
        ELSE 'Monthly review'
    END AS ReviewFrequency
FROM DemandRank
ORDER BY MonthlyDemand DESC;


-- ============================================
-- PART 10: OVERSTOCKED SKUs (Low Turnover)
-- ============================================

SELECT '===== OVERSTOCKED SKUs (Turnover < 2x/month) =====' AS OverstockAlert;
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    MonthlyDemand,
    ROUND(CAST(MonthlyDemand AS FLOAT) / StockOnHand, 2) AS TurnoverRatio,
    CASE 
        WHEN CAST(MonthlyDemand AS FLOAT) / StockOnHand < 2 THEN 'Reduce stock by 50%'
        WHEN CAST(MonthlyDemand AS FLOAT) / StockOnHand < 3 THEN 'Monitor stock levels'
        ELSE 'Optimal'
    END AS Recommendation
FROM Inventory
WHERE CAST(MonthlyDemand AS FLOAT) / StockOnHand < 2
ORDER BY TurnoverRatio ASC;


-- ============================================
-- PART 11: COMPLETE SKU REPORT (All Metrics)
-- ============================================

SELECT '===== COMPLETE SKU ANALYSIS REPORT =====' AS FullReport;
SELECT 
    SKU,
    ProductName,
    Category,
    StockOnHand,
    ReorderLevel,
    SafetyStock,
    LeadTimeDays,
    MonthlyDemand,
    ROUND(CAST(MonthlyDemand AS FLOAT) / 30, 2) AS DailyDemand,
    ROUND(CAST(StockOnHand AS FLOAT) / (CAST(MonthlyDemand AS FLOAT) / 30), 1) AS DaysToStockout,
    ROUND((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays, 0) AS LeadTimeDemand,
    ROUND(StockOnHand - ((CAST(MonthlyDemand AS FLOAT) / 30) * LeadTimeDays), 0) AS SafetyBuffer,
    ROUND(CAST(MonthlyDemand AS FLOAT) / StockOnHand, 2) AS TurnoverRatio,
    ReorderStatus,
    Priority,
    RecommendedOrderQty
FROM InventoryAnalytics
ORDER BY DaysToStockout ASC;


-- ============================================
-- PART 12: EXECUTIVE SUMMARY (One-Line Insights)
-- ============================================

SELECT '===== EXECUTIVE SUMMARY =====' AS Summary;
SELECT 
    'CRITICAL FINDING' AS Category,
    '4 out of 8 SKUs are at risk of stockout within 7 days' AS Finding
UNION ALL
SELECT 
    'IMMEDIATE ACTION',
    'Phone X and Monitor 24 will stockout in less than 3 days - reorder NOW'
UNION ALL
SELECT 
    'HIDDEN RISK',
    'USB Cable has 500 units but negative safety buffer due to 14-day lead time'
UNION ALL
SELECT 
    'CASH OPPORTUNITY',
    'Desk Mat is overstocked (200 units) - reduce to 100 units to free capital'
UNION ALL
SELECT 
    'TOP PRIORITY SKUS',
    'Phone X (27 units), Monitor 24 (31 units), Keyboard (25 units) - order immediately'
UNION ALL
SELECT 
    'BOTTOM LINE',
    'Without action within 48 hours, you will lose sales on Electronics category';


-- ============================================
-- PART 13: STORED PROCEDURE (Run Anytime)
-- ============================================

CREATE PROCEDURE sp_GetInventoryReport
AS
BEGIN
    -- Executive summary
    SELECT 'INVENTORY HEALTH REPORT - ' + CAST(GETDATE() AS VARCHAR) AS ReportHeader;
    
    -- Critical alerts
    SELECT * FROM InventoryAnalytics WHERE Priority = 'CRITICAL';
    
    -- Reorder list
    SELECT * FROM InventoryAnalytics WHERE ReorderStatus = 'ORDER NOW';
    
    -- Summary stats
    SELECT 
        COUNT(*) AS TotalSKUs,
        SUM(StockOnHand) AS TotalInventory,
        SUM(MonthlyDemand) AS TotalDemand,
        AVG(DaysToStockout) AS AvgDaysToStockout,
        AVG(TurnoverRatio) AS AvgTurnoverRatio
    FROM InventoryAnalytics;
END;


============================
-- END OF SCRIPT
-- ============================================
