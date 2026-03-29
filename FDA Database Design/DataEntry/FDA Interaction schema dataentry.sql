USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. NGOs & CSR Campaigns (Notes #62, #63) - 20 Rows
-----------------------------------------------------------
INSERT INTO Interaction.NGOs (NGOName, RegistrationNumber, ContactPerson, Phone, CityOfOperation, IsVerified)
VALUES 
('Akshaya Patra', 'REG1001', 'Madhu Pandit', '9123456781', 'Bangalore', 1),
('Feeding India', 'REG1002', 'Vikas Khanna', '9123456782', 'Bangalore', 1),
('Robin Hood Army', 'REG1003', 'Neel Ghose', '9123456783', 'Tumkur', 1),
('No Kid Hungry', 'REG1004', 'Sarah Smith', '9123456784', 'Bangalore', 1);

-- Adding 16 more generic NGOs to reach 20
INSERT INTO Interaction.NGOs (NGOName, RegistrationNumber, ContactPerson, Phone, CityOfOperation, IsVerified)
SELECT 'NGO '+CAST(N AS VARCHAR), 'REG'+CAST(2000+N AS VARCHAR), 'Person '+CAST(N AS VARCHAR), '9123456'+CAST(N AS VARCHAR), 'Bangalore', 1 
FROM (SELECT TOP 16 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-- CSR Campaigns
INSERT INTO Interaction.CSRCampaigns (CampaignName, Description, TargetAmount, CurrentRaised, IsActive)
SELECT 'Feed '+CityOfOperation, 'Providing meals for the needy', 500000.00, 150000.00, 1 FROM Interaction.NGOs;

-----------------------------------------------------------
-- 2. Donations & Impact (Notes #64, #65) - 20+ Rows
-----------------------------------------------------------
-- Donations (Linked to Users and CSR Campaigns)
INSERT INTO Interaction.Donations (UserID, CampaignID, OrderID, Amount, DonationDate)
SELECT TOP 20 UserID, (UserID % 5) + 1, UserID, 10.00, GETDATE() FROM Users.Profiles;

-- Donation Impact (Meals provided by the NGO)
INSERT INTO Interaction.DonationImpact (CampaignID, NGOID, AmountDisbursed, MealsProvided, DisbursedDate)
SELECT TOP 20 CampaignID, (CampaignID % 20) + 1, 5000.00, 250, GETDATE() FROM Interaction.CSRCampaigns;

-----------------------------------------------------------
-- 3. App Feedback Categories (Note #66) - 20 Rows
-----------------------------------------------------------
INSERT INTO Interaction.AppFeedbackCategories (CategoryName, DepartmentResponsibility)
VALUES 
('App Crash', 'Technical'), ('Slow Loading', 'Technical'), ('Payment Failed', 'Finance'),
('Wrong Item', 'Operations'), ('Delivery Delay', 'Logistics'), ('Poor Food Quality', 'Restaurant'),
('Rude Partner', 'Logistics'), ('Refund Issues', 'Finance'), ('UI Improvement', 'Product'),
('GPS Inaccuracy', 'Technical'), ('Offer Not Applied', 'Marketing'), ('Sign-up Issues', 'Technical'),
('Notification Spam', 'Product'), ('In-app Chat', 'Support'), ('Address Issues', 'Operations'),
('Order History', 'Product'), ('Subscription Query', 'Finance'), ('Gift Card Error', 'Finance'),
('CSR Query', 'Community'), ('General Praise', 'Marketing');

-----------------------------------------------------------
-- 4. App Feedback & Responses (Notes #67, #68) - 20+ Rows
-----------------------------------------------------------
-- App Feedback (Linked to Users and Categories)
INSERT INTO Interaction.AppFeedback (UserID, CategoryID, Rating, Comments, DeviceModel, AppVersion, CreatedAt)
SELECT TOP 20 
    UserID, 
    (UserID % 20) + 1, 
    (UserID % 5) + 1, 
    'Feedback from ' + Name, 
    'Android 14', 
    'v2.4.1', 
    GETDATE() 
FROM Users.Profiles;

-- App Feedback Responses (Support Team replying)
INSERT INTO Interaction.AppFeedbackResponses (FeedbackID, AdminID, ResponseText, RespondedAt)
SELECT TOP 20 FeedbackID, 101, 'Thank you for your feedback. We are looking into it.', GETDATE() 
FROM Interaction.AppFeedback;