USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. Tax (Note #10) - 20 Rows
-----------------------------------------------------------
INSERT INTO Finance.Tax (TaxName, Percentage)
VALUES 
('GST - Food', 5.00), ('GST - Drinks', 18.00), ('Service Tax', 2.50),
('Swachh Bharat Cess', 0.50), ('Krishi Kalyan Cess', 0.50), ('Packaging Tax', 1.00),
('TCS', 1.00), ('TDS', 1.00), ('Luxury Tax', 10.00), ('VAT - Liquor', 20.00),
('Municipal Tax', 1.50), ('State Cess', 0.75), ('Central Cess', 0.75), ('Health Cess', 2.00),
('Green Tax', 0.50), ('Entry Tax', 1.00), ('Octroi', 2.00), ('Service Charge', 5.00),
('Delivery Tax', 2.00), ('Platform Fee Tax', 1.00);

-----------------------------------------------------------
-- 2. Payments (Note #9) - 25 Rows
-----------------------------------------------------------
INSERT INTO Finance.Payments (OrderID, PaymentMode, TransactionStatus, TaxAmount, DeliveryFee, TaxID)
SELECT TOP 25 
    OrderID, 
    CASE WHEN OrderID % 2 = 0 THEN 'UPI' ELSE 'Credit Card' END,
    'Success',
    15.50,
    30.00,
    1 -- Linking to 'GST - Food'
FROM [Order].Transactions;

-----------------------------------------------------------
-- 3. Refunds (Note #30) - 20 Rows
-----------------------------------------------------------
INSERT INTO Finance.Refunds (OrderID, UserID, Amount, RefundStatus, TransactionReference)
SELECT TOP 20 
    OrderID, 
    UserID, 
    200.00, 
    'Processed', 
    'REF_'+CAST(OrderID AS VARCHAR)
FROM [Order].Transactions 
WHERE Status = 'Cancelled';

-----------------------------------------------------------
-- 4. PartnerEarnings (Note #36) - 20 Rows
-----------------------------------------------------------
INSERT INTO Finance.PartnerEarnings (OrderID, PartnerID, TripDistance, BasePay, IncentivePay, TipAmount, TotalEarned)
SELECT TOP 20 
    OrderID, 
    PartnerID, 
    3.5, 
    25.00, 
    10.00, 
    20.00, 
    55.00
FROM [Order].Transactions 
WHERE PartnerID IS NOT NULL;

-----------------------------------------------------------
-- 5. RestaurantPayouts (Note #27) - 20 Rows
-----------------------------------------------------------
INSERT INTO Finance.RestaurantPayouts (RestaurantID, PeriodStart, PeriodEnd, TotalSales, PlatformCommission, TaxDeducted, FinalPayout, PayoutStatus)
SELECT TOP 20 
    RestaurantID, 
    DATEADD(DAY, -7, GETDATE()), 
    GETDATE(), 
    5000.00, 
    500.00, 
    250.00, 
    4250.00, 
    'Paid'
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 6. Gift Cards (Notes #41, #42, #43) - 20 Rows Each
-----------------------------------------------------------
-- Templates
INSERT INTO Finance.GiftCardTemplates (CardName, InitialValue, ExpiryMonths, IsActive)
VALUES ('Birthday Special', 500, 12, 1), ('Corporate Gift', 1000, 6, 1), ('Festive Voucher', 200, 3, 1);
-- Add dummy rows to hit 20
INSERT INTO Finance.GiftCardTemplates (CardName, InitialValue, ExpiryMonths, IsActive)
SELECT 'Promo Card '+CAST(N AS VARCHAR), 100, 1, 1 FROM (SELECT TOP 17 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-- Issued Gift Cards
INSERT INTO Finance.IssuedGiftCards (TemplateID, CardCode, CurrentBalance, ExpiryDate, IsRedeemed)
SELECT TOP 20 (TemplateID), 'GIFT'+CAST(TemplateID AS VARCHAR)+CAST(GETDATE() AS VARCHAR), 500.00, DATEADD(YEAR, 1, GETDATE()), 0 FROM Finance.GiftCardTemplates;

-----------------------------------------------------------
-- 7. Wallet Transactions (Note #70) - 20 Rows
-----------------------------------------------------------
-- Assuming WalletID exists from the Users.Wallets script
INSERT INTO Finance.WalletTransactions (WalletID, OrderID, Amount, TransactionType, TransactionStatus)
SELECT TOP 20 (UserID), OrderID, 150.00, 'Debit', 'Success' FROM [Order].Transactions;

-----------------------------------------------------------
-- 8. Payment Splits (Note #99) - 20 Rows
-----------------------------------------------------------
INSERT INTO Finance.PaymentSplits (SplitInvoiceID, FriendUserID, ShareAmount, PaymentStatus)
SELECT TOP 20 (OrderID), (UserID % 25) + 1, 125.00, 'Paid' FROM [Order].Transactions;