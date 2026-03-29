USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. Order.Transactions (Note #7) - 25 Rows
-- Linking Users.Profiles to Restaurant.Profiles
-----------------------------------------------------------
INSERT INTO [Order].Transactions (UserID, RestaurantID, PartnerID, Status, TotalAmount, OrderTime)
SELECT TOP 25 
    U.UserID, 
    (U.UserID % 20) + 1, -- Cycles through your 20 restaurants
    (U.UserID % 5) + 1,  -- Temporary Partner IDs
    CASE WHEN U.UserID % 5 = 0 THEN 'Cancelled' ELSE 'Delivered' END,
    250.00 + (U.UserID * 10), 
    GETDATE()
FROM Users.Profiles U;

-----------------------------------------------------------
-- 2. Order.OrderItem (Note #8) - 25+ Rows
-----------------------------------------------------------
INSERT INTO [Order].OrderItems(OrderID, ItemID, Quantity, PriceAtTimeOfOrder)
SELECT 
    OrderID, 
    (OrderID % 10) + 1, -- Linking to MenuItems
    2, 
    150.00
FROM [Order].Transactions;

-----------------------------------------------------------
-- 3. Order.OrderMilestones (Note #18) - 20+ Rows
-----------------------------------------------------------
INSERT INTO [Order].OrderMilestones (OrderID, MilestoneName, ReachedAt)
SELECT TOP 20 OrderID, 'Order Placed', GETDATE() FROM [Order].Transactions;

-----------------------------------------------------------
-- 4. Order.OrderAddons (Note #21) - 20+ Rows
-----------------------------------------------------------
-- Assuming AddonID 1 exists in Restaurant.Addons
INSERT INTO [Order].OrderAddons (OrderDetailID, AddonID, PriceAtTimeOfOrder)
SELECT TOP 20 OrderItemID, 1, 30.00 FROM [Order].OrderItems;

-----------------------------------------------------------
-- 5. Order.OrderCancellations (Note #29) - 20 Rows
-----------------------------------------------------------
--Insert into OrderCancellations
INSERT INTO [Order].OrderCancellations (
    OrderID, 
    CancelledBy, 
    ReasonId, 
    CancellationTime, 
    RefundAmount, 
    CancellationFee
)
SELECT TOP 20 
    OrderID, 
    'User',         -- CancelledBy
    (OrderID % 5) + 1, -- ReasonId (Assuming 1-5 are valid reason codes)
    GETDATE(),      -- CancellationTime
    200.00,         -- RefundAmount
    50.00           -- CancellationFee
FROM [Order].Transactions 
WHERE Status = 'Cancelled';

-----------------------------------------------------------
-- 6. Order.TrainOrderDetails (Note #59) - 20 Rows
-- For your unique feature of delivery to trains!
-----------------------------------------------------------
INSERT INTO [Order].TrainOrderDetails (OrderID, TrainID, PNRNumber, CoachNumber, SeatNumber)
SELECT TOP 20 OrderID, 1, 'PNR'+CAST(OrderID AS VARCHAR), 'B1', OrderID + 10 
FROM [Order].Transactions;

-----------------------------------------------------------
-- 7. Order.MealPlans (Note #95) & SplitInvoices (Note #98)
-----------------------------------------------------------
-- MealPlans (20 Rows)
INSERT INTO [Order].MealPlans (UserID, PlanDate, MealType, ItemID, Status)
SELECT TOP 20 UserID, GETDATE(), 'Lunch', 1, 'Confirmed' FROM Users.Profiles;

-- SplitInvoices (20 Rows)
INSERT INTO [Order].SplitInvoices (OrderID, HostUserID, TotalBillAmount, Status)
SELECT TOP 20 OrderID, UserID, TotalAmount, 'Pending' FROM [Order].Transactions;

-----------------------------------------------------------
-- 8. Order.ReorderPatterns (Note #85) & AbandonedCarts (Note #84)
-----------------------------------------------------------
-- AbandonedCarts (20 Rows)
INSERT INTO [Order].AbandonedCarts (UserID, RestaurantID, TotalItems, CartValue)
SELECT TOP 20 UserID, 1, 3, 450.00 FROM Users.Profiles WHERE UserID > 5;

-- ReorderPatterns (20 Rows)
INSERT INTO [Order].ReorderPatterns (UserID, ItemID, TimesOrdered)
SELECT TOP 20 UserID, 101, 5 FROM Users.Profiles;