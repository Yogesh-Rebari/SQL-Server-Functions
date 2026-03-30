
-- 01. Connect identity, finance, and engagement.
-- Users.Profiles → Users.UserWallets → Marketing.LoyaltyPoints → Users.UserSubscriptions
SELECT 
    U.Name, 
    W.Balance AS WalletBalance, 
    L.CurrentBalance AS LoyaltyPoints, 
    S.SubStatus AS Subscription,
    P.PlanName
FROM Users.Profiles U
JOIN Users.UserWallets W ON U.UserID = W.UserID
JOIN Marketing.LoyaltyPoints L ON U.UserID = L.UserID
LEFT JOIN Users.UserSubscriptions S ON U.UserID = S.UserID
LEFT JOIN Users.MembershipPlans P ON S.PlanID = P.PlanID;

-- 02. See how pricing changes affect the current menu.
SELECT 
    M.Name AS ItemName, 
    C.CategoryName, 
    M.Price AS CurrentPrice, 
    H.OldPrice, 
    H.ChangeDate
FROM Restaurant.MenuItems M
JOIN Restaurant.Categories C ON M.CategoryID = C.CategoryID
LEFT JOIN Analytics.ItemPriceHistory H ON M.ItemID = H.ItemID
ORDER BY H.ChangeDate DESC;

-- 03. Trace a physical order to its delivery tracking.
-- [Order].Transactions → Logistics.DeliveryPartners → Logistics.DeliveryTracking
SELECT 
    O.OrderID, 
    O.Status AS OrderStatus, 
    P.Name AS PartnerName, 
    T.StatusUpdate AS LastTrackingPoint, 
    T.UpdateTime
FROM [Order].Transactions O
JOIN Logistics.Partners P ON O.PartnerID = P.PartnerID
JOIN Logistics.DeliveryTracking T ON O.OrderID = T.OrderID;

-- 04. high-level view of railway delivery feature.
-- Logistics.Trains → Logistics.RailwayStations → [Order].TrainOrderDetails
SELECT 
    T.TrainName, 
    RS.StationName, 
    TOD.PNRNumber, 
    TOD.CoachNumber, 
    O.Status AS DeliveryStatus
FROM Logistics.Trains T
JOIN Logistics.RailwayStations RS ON RS.IsDeliveryEnabled = 1
JOIN [Order].TrainOrderDetails TOD ON T.TrainID = TOD.TrainID
JOIN [Order].Transactions O ON TOD.OrderID = O.OrderID;




