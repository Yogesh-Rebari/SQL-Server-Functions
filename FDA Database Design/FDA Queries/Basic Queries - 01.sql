
-- 01. Find which user is the most active and how much they have spent.
SELECT 
    U.[Name], 
    U.Email, 
    COUNT(O.OrderID) AS TotalOrders, 
    SUM(O.TotalAmount) AS TotalSpent,
    AVG(O.TotalAmount) AS AvgOrderValue
FROM Users.Profiles U
JOIN [Order].Transactions O ON U.UserID = O.UserID
GROUP BY U.Name, U.Email
ORDER BY TotalSpent DESC;


-- 02. Identify the top-performing restaurants and see if their high ratings correlate with high sales.
SELECT 
    R.Name AS RestaurantName, 
    R.Rating AS AppRating, 
    COUNT(T.OrderID) AS TotalOrdersServed, 
    SUM(T.TotalAmount) AS GrossRevenue,
    AP.AvgPreparationTimeMinutes
FROM Restaurant.Profiles R
JOIN [Order].Transactions T ON R.RestaurantID = T.RestaurantID
LEFT JOIN Analytics.RestaurantPerformance AP ON R.RestaurantID = AP.RestaurantID
GROUP BY R.Name, R.Rating, AP.AvgPreparationTimeMinutes
ORDER BY GrossRevenue DESC;


-- 03. Check if logistics partners are getting their fair share of earnings and tips.
SELECT 
    DP.Name AS PartnerName, 
    DP.VehicleType, 
    COUNT(PE.EarningID) AS TripsCompleted, 
    SUM(PE.BasePay) AS TotalBasePay, 
    SUM(PE.TipAmount) AS TotalTips,
    SUM(PE.TotalEarned) AS GrandTotal
FROM Logistics.Partners DP
JOIN Finance.PartnerEarnings PE ON DP.PartnerID = PE.PartnerID
GROUP BY DP.Name, DP.VehicleType
ORDER BY GrandTotal DESC;

-- 04. See which marketing coupons (like CITSTUDENT) are actually being used by users.
SELECT 
    C.CouponCode, 
    C.DiscountType, 
    COUNT(PU.UsageID) AS TimesUsed, 
    U.Name AS LastUserToUseIt
FROM Marketing.Coupons C
LEFT JOIN Marketing.PromoUsage PU ON C.CouponID = PU.OfferID
LEFT JOIN Users.Profiles U ON PU.UserID = U.UserID
GROUP BY C.CouponCode, C.DiscountType, U.Name
ORDER BY TimesUsed DESC;


-- 05. Verify unique feature—orders being delivered to specific trains and coaches.
SELECT 
    T.TrainName, 
    T.TrainNumber, 
    TOD.PNRNumber, 
    TOD.CoachNumber, 
    TOD.SeatNumber, 
    OT.Status AS OrderStatus,
    OT.TotalAmount
FROM [Order].Transactions OT
JOIN [Order].TrainOrderDetails TOD ON OT.OrderID = TOD.OrderID
JOIN Logistics.Trains T ON TOD.TrainID = T.TrainID;


-- JOINS

-- 06. This query joins the User, the Order, and the Restaurant to see who ordered from where.
SELECT 
    U.Name AS CustomerName,
    O.OrderID,
    R.Name AS RestaurantName,
    O.TotalAmount,
    O.Status
FROM Users.Profiles U
JOIN [Order].Transactions O ON U.UserID = O.UserID
JOIN Restaurant.Profiles R ON O.RestaurantID = R.RestaurantID;

-- 08. This query checks which delivery partner is handling which order and what vehicle they are using.
SELECT 
    O.OrderID,
    O.Status AS OrderStatus,
    P.Name AS PartnerName,
    P.Phone AS PartnerContact,
    P.VehicleType
FROM [Order].Transactions O
JOIN Logistics.Partners P ON O.PartnerID = P.PartnerID;

-- 09. This is used to verify that the money paid for an order matches the records in the Finance schema.
SELECT 
    O.OrderID,
    O.TotalAmount,
    P.PaymentMode,
    P.TransactionStatus,
    T.TaxName,
    T.Percentage AS TaxRate
FROM [Order].Transactions O
JOIN Finance.Payments P ON O.OrderID = P.OrderID
JOIN Finance.Tax T ON P.TaxID = T.TaxID;

-- 10. This joins the user with their saved address book to see where the food needs to be delivered.
SELECT 
    U.[Name],
    U.Phone,
    A.AddressLabel,
    A.FullAddress
FROM Users.Profiles U
JOIN Users.UserAddressBook A ON U.UserID = A.UserID
WHERE A.IsDefault = 1;

-- 11. The "Loyalty & Rewards" Check
SELECT 
    U.Name, 
    L.MembershipTier, 
    L.TotalPointsAccumulated, 
    L.CurrentBalance
FROM Users.Profiles U
JOIN Marketing.LoyaltyPoints L ON U.UserID = L.UserID
ORDER BY L.TotalPointsAccumulated DESC;

-- 12. Menu Popularity
SELECT 
    R.Name AS RestaurantName, 
    C.CategoryName, 
    M.Name AS DishName, 
    M.Price
FROM Restaurant.Profiles R
JOIN Restaurant.MenuItems M ON R.RestaurantID = M.RestaurantID
JOIN Restaurant.Categories C ON M.CategoryID = C.CategoryID
ORDER BY R.Name;

-- 13. Verify if a customer's order is correctly assigned to a delivery partner and showing the correct status.
-- Users → Orders → Logistics
SELECT 
    U.Name AS Customer,
    O.OrderID,
    R.Name AS Restaurant,
    P.Name AS DeliveryPartner,
    P.VehicleType,
    DT.StatusUpdate AS LiveTrackingStatus,
    O.TotalAmount
FROM Users.Profiles U
JOIN [Order].Transactions O ON U.UserID = O.UserID
JOIN Restaurant.Profiles R ON O.RestaurantID = R.RestaurantID
JOIN Logistics.Partners P ON O.PartnerID = P.PartnerID
JOIN Logistics.DeliveryTracking DT ON O.OrderID = DT.OrderID;


-- 14. Ensure that for every order, a payment record exists and the correct tax is being applied.
-- Orders → Finance → Tax
SELECT 
    O.OrderID,
    O.TotalAmount AS OrderValue,
    PM.PaymentMode,
    PM.TransactionStatus,
    T.TaxName,
    (O.TotalAmount * T.Percentage / 100) AS CalculatedTaxAmount,
    P.FinalPayout AS RestaurantEarnings
FROM [Order].Transactions O
JOIN Finance.Payments PM ON O.OrderID = PM.OrderID
JOIN Finance.Tax T ON PM.TaxID = T.TaxID
JOIN Finance.RestaurantPayouts P ON O.RestaurantID = P.RestaurantID;


-- 15. Verify that your menu hierarchy is correct and that items are mapped to the right categories.
-- Restaurant → Menu → Categories
SELECT 
    R.[Name] AS Restaurant,
    C.CategoryName,
    M.[Name] AS FoodItem,
    M.Price,
    CASE WHEN M.IsVeg = 1 THEN 'Veg' ELSE 'Non-Veg' END AS DietType
FROM Restaurant.Profiles R
JOIN Restaurant.MenuItems M ON R.RestaurantID = M.RestaurantID
JOIN Restaurant.Categories C ON M.CategoryID = C.CategoryID
ORDER BY R.Name, C.CategoryName;

