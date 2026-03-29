USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. NotificationTemplates (Note #44) - 20 Rows
-----------------------------------------------------------
INSERT INTO System.NotificationTemplates (TriggerEvent, TitleTemplate, BodyTemplate, RecipientRole)
VALUES 
('Order_Placed', 'Order Confirmed!', 'Hi {User}, your order #{ID} is being prepared.', 'Customer'),
('Out_For_Delivery', 'Food is on the way!', 'Partner {Partner} is arriving soon.', 'Customer'),
('Order_Delivered', 'Enjoy your meal!', 'Rate your experience with {Restaurant}.', 'Customer'),
('Payment_Failed', 'Action Required', 'Payment for order #{ID} failed.', 'Customer'),
('Promo_Alert', 'Special Offer!', 'Get {Disc}% off on your next order.', 'Customer'),
('New_Login', 'Security Alert', 'New login detected from {Device}.', 'Customer'),
('Low_Wallet', 'Balance Low', 'Top up your wallet for faster checkout.', 'Customer'),
('Payout_Processed', 'Payment Sent', 'Your weekly payout is on the way.', 'Restaurant'),
('Shift_Start', 'Welcome Online', 'You are now active for deliveries.', 'Partner');

-- Adding 11 more templates to reach 20
INSERT INTO System.NotificationTemplates (TriggerEvent, TitleTemplate, BodyTemplate, RecipientRole)
SELECT 'Event_'+CAST(N AS VARCHAR), 'Title '+CAST(N AS VARCHAR), 'Body...', 'Customer' 
FROM (SELECT TOP 11 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-----------------------------------------------------------
-- 2. Notifications (Note #45) - 25 Rows
-- Linking to your 25 User Profiles
-----------------------------------------------------------
INSERT INTO System.Notifications (UserID, Title, MessageBody, Channel, CreatedAt, ReadAt)
SELECT UserID, 'Welcome!', 'Welcome to NoteZ Food Delivery, ' + Name, 'In-App', GETDATE(), NULL 
FROM Users.Profiles;

-----------------------------------------------------------
-- 3. PackagingTypes (Note #101) - 20 Rows
-----------------------------------------------------------
INSERT INTO System.PackagingTypes (MaterialName, CarbonFootprintPerUnit, ExtraCost, IsActive)
VALUES 
('Recycled Paper Bag', 0.05, 5.00, 1),
('Biodegradable Plastic', 0.12, 10.00, 1),
('Reusable Cloth Bag', 0.01, 25.00, 1),
('Standard Cardboard', 0.08, 2.00, 1),
('Eco-friendly Box', 0.03, 15.00, 1);

-- Adding 15 more types to reach 20
INSERT INTO System.PackagingTypes (MaterialName, CarbonFootprintPerUnit, ExtraCost, IsActive)
SELECT 'Package Type '+CAST(N AS VARCHAR), 0.10, 2.00, 1 
FROM (SELECT TOP 15 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-----------------------------------------------------------
-- 4. RegulatoryCompliance (Note #100) - 20 Rows
-- Tracking FSSAI and Health Permits
-----------------------------------------------------------
INSERT INTO System.RegulatoryCompliance (RestaurantID, DocumentType, DocumentNumber, ExpiryDate, VerificationStatus)
SELECT TOP 20 
    RestaurantID, 
    'FSSAI License', 
    'FSSAI-'+CAST(1000+RestaurantID AS VARCHAR), 
    DATEADD(YEAR, 2, GETDATE()), 
    'Verified'
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 5. System Master Data (Addresses & Booking)
-----------------------------------------------------------
-- Master Addresses (Note #2) - Generic storage
INSERT INTO System.Addresses (AddressLine, City, State, Pincode)
SELECT TOP 20 'Street ' + CAST(N AS VARCHAR), 'Bangalore', 'Karnataka', '560001'
FROM (SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-- Booking Special Requests (Note #33)
INSERT INTO System.BookingSpecialRequests (RequestType, Description, IsPaid, AdditionalCharge)
VALUES 
('Birthday Decoration', 'Balloons and banners', 1, 500.00),
('Candle Light', 'Romantic setup', 1, 300.00),
('Wheelchair Access', 'Priority seating', 0, 0.00),
('Quiet Zone', 'Seating away from music', 0, 0.00),
('Extra Large Table', 'For groups > 10', 0, 0.00);
-- Adding 15 more generic request types
INSERT INTO System.BookingSpecialRequests (RequestType, Description, IsPaid, AdditionalCharge)
SELECT 'Request '+CAST(N AS VARCHAR), 'Details...', 0, 0.00 
FROM (SELECT TOP 15 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;