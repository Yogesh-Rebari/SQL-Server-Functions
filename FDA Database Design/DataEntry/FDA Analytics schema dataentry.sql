USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. ItemPriceHistory (Note #26) - 20 Rows
-- Tracking how prices changed over time for MenuItems
-----------------------------------------------------------
INSERT INTO Analytics.ItemPriceHistory (ItemID, OldPrice, NewPrice, ChangedBy, ChangeDate)
SELECT TOP 20 
    ItemID, 
    Price - 20.00, 
    Price, 
    101, 
    DATEADD(MONTH, -1, GETDATE())
FROM Restaurant.MenuItems;

-----------------------------------------------------------
-- 2. OrderAnalytics (Note #71) - 20 Rows
-- Daily snapshots of revenue and order volume
-----------------------------------------------------------
INSERT INTO Analytics.OrderAnalytics (OrderDate, ServiceAreaID, TotalOrders, TotalRevenue, TotalCancellations, PeakOrderTime)
SELECT TOP 20 
    CAST(DATEADD(DAY, -AreaID, GETDATE()) AS DATE), 
    AreaID, 
    150 + (AreaID * 5), 
    45000.00 + (AreaID * 1000), 
    12, 
    '20:30:00'
FROM Logistics.ServiceArea;

-----------------------------------------------------------
-- 3. RestaurantPerformance (Note #72) - 20 Rows
-- Monthly reporting for restaurant owners
-----------------------------------------------------------
INSERT INTO Analytics.RestaurantPerformance (RestaurantID, ReportingMonth, TotalOrdersServed, GrossRevenue, AvgPreparationTimeMinutes, CustomerSatisfactionScore)
SELECT TOP 20 
    RestaurantID, 
    'March 2026', 
    500 + (RestaurantID * 10), 
    125000.00, 
    18, 
    4.5
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 4. DeliveryPerformance (Note #73) - 25 Rows
-- Tracking the efficiency of your 25 Delivery Partners
-----------------------------------------------------------
INSERT INTO Analytics.DeliveryPerformance (PartnerID, TotalTripsCompleted, AvgDeliveryTimeMinutes, OnTimeDeliveryPercentage, TotalEarnings, AvgPartnerRating)
SELECT TOP 25 
    PartnerID, 
    120, 
    28, 
    94.5, 
    15000.00, 
    4.7
FROM Logistics.Partners;