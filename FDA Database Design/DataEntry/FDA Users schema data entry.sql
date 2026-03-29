
USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. Users (The Foundation: 25 Records)
-----------------------------------------------------------
INSERT INTO Users.Profiles([Name], Phone, Email, PasswordHash, CreatedAt) VALUES 
('Sanath B', '9000000001', 'sanath.b@cit.edu', 'pass123', GETDATE()),
('Amith A N', '9000000002', 'amith.an@cit.edu', 'pass123', GETDATE()),
('Yogesh Rebari', '9000000003', 'yogesh.r@cit.edu', 'pass123', GETDATE()),
('Paartha K', '9000000004', 'paartha.k@cit.edu', 'pass123', GETDATE()),
('Prajwal S', '9000000005', 'prajwal.s@cit.edu', 'pass123', GETDATE()),
('Sathvika H M', '9000000006', 'sathvika.hm@cit.edu', 'pass123', GETDATE()),
('Rahul H', '9000000007', 'rahul.h@cit.edu', 'pass123', GETDATE()),
('Nagabhushana L', '9000000008', 'naga.l@cit.edu', 'pass123', GETDATE()),
('Deepasree R', '9000000009', 'deepasree.r@cit.edu', 'pass123', GETDATE()),
('Omkar Reddy T H', '9000000010', 'omkar.r@cit.edu', 'pass123', GETDATE()),
('Sinchana S Y', '9000000011', 'sinchana.sy@cit.edu', 'pass123', GETDATE()),
('Darshan Dayanand Naik', '9000000012', 'darshan.dn@cit.edu', 'pass123', GETDATE()),
('H R Shamanth', '9000000013', 'shamanth.hr@cit.edu', 'pass123', GETDATE()),
('Samyakthva Jain D', '9000000014', 'samyakthva.j@cit.edu', 'pass123', GETDATE()),
('Ananya Rao', '9000000015', 'ananya.r@cit.edu', 'pass123', GETDATE()),
('Karthik M', '9000000016', 'karthik.m@cit.edu', 'pass123', GETDATE()),
('Sneha Patil', '9000000017', 'sneha.p@cit.edu', 'pass123', GETDATE()),
('Vikram Singh', '9000000018', 'vikram.s@cit.edu', 'pass123', GETDATE()),
('Priya Sharma', '9000000019', 'priya.s@cit.edu', 'pass123', GETDATE()),
('Arjun V', '9000000020', 'arjun.v@cit.edu', 'pass123', GETDATE()),
('Meghana K', '9000000021', 'meghana.k@cit.edu', 'pass123', GETDATE()),
('Rohit Kumar', '9000000022', 'rohit.k@cit.edu', 'pass123', GETDATE()),
('Shiva Prasad', '9000000023', 'shiva.p@cit.edu', 'pass123', GETDATE()),
('Tanvi Hegde', '9000000024', 'tanvi.h@cit.edu', 'pass123', GETDATE()),
('Abhishek G', '9000000025', 'abhishek.g@cit.edu', 'pass123', GETDATE());

-----------------------------------------------------------
-- 2. Bulk Insert for Tables with 1-to-1 or Simple Logic
-----------------------------------------------------------
-- UserWallets (25 rows), UserAddressBook (25 rows), UserSavedMethods (25 rows)
INSERT INTO Users.UserWallets (UserID, Balance, LastUpdated, IsBlocked) SELECT UserID, 1000.00, GETDATE(), 0 FROM Users.Profiles;
INSERT INTO Users.UserAddressBook (UserID, AddressLabel, FullAddress, IsDefault, CreatedAt) SELECT UserID, 'Home', 'Tumkur Main Road, Bangalore', 1, GETDATE() FROM Users.Profiles;
INSERT INTO Users.UserSavedMethods (UserID, MethodID, ProviderToken, IsDefault, CreatedAt) SELECT UserID, 1, 'TOK_XYZ_'+CAST(UserID AS VARCHAR), 1, GETDATE() FROM Users.Profiles;

-- Cart (25 rows) & CartItems (25 rows)
INSERT INTO Users.Cart (UserID, CreatedAt, UpdatedAt) SELECT UserID, GETDATE(), GETDATE() FROM Users.Profiles;
INSERT INTO Users.CartItems (CartID, ItemID, Quantity) SELECT CartID, (CartID % 10) + 1, 2 FROM Users.Cart;

-- UserSessions (25 rows), DeviceLogs (25 rows), UserActivityLogs (25 rows)
INSERT INTO Users.UserSessions (UserID, DeviceType, IPAddress, IsActive) SELECT UserID, 'Android', '192.168.1.'+CAST(UserID AS VARCHAR), 1 FROM Users.Profiles;
INSERT INTO Users.DeviceLogs (UserID, DeviceName, DeviceOS, IsTrusted) SELECT UserID, 'Samsung M34', 'Android 14', 1 FROM Users.Profiles;
INSERT INTO Users.UserActivityLogs (SessionID, ActionTaken, ActionTime) SELECT SessionID, 'Login', GETDATE() FROM Users.UserSessions;

-----------------------------------------------------------
-- 3. Membership & Subscriptions (20+ Rows)
-----------------------------------------------------------
INSERT INTO Users.MembershipPlans (PlanName, Price, DurationDays, IsActive) VALUES 
('Free', 0, 30, 1), ('Gold', 199, 30, 1), ('Platinum', 499, 90, 1), ('Student', 99, 30, 1), ('Yearly', 1500, 365, 1),
('Trial', 0, 7, 1), ('Family', 799, 30, 1), ('Weekend', 49, 2, 1), ('NightOwl', 89, 30, 1), ('Corporate', 250, 30, 1),
('BogoPlan', 150, 30, 1), ('Elite', 2000, 365, 1), ('Foodie', 120, 30, 1), ('Gourmet', 350, 30, 1), ('Budget', 50, 30, 1),
('Premium', 599, 60, 1), ('Ultra', 899, 90, 1), ('Basic', 100, 30, 1), ('Plus', 150, 30, 1), ('Infinite', 5000, 999, 1);

INSERT INTO Users.UserSubscriptions (UserID, PlanID, StartDate, EndDate, SubStatus) 
SELECT TOP 25 UserID, (UserID % 19) + 1, GETDATE(), DATEADD(DAY, 30, GETDATE()), 'Active' FROM Users.Users;

INSERT INTO Users.MembershipSavings (UserID, OrderID, AmountSaved, SavedAt) 
SELECT TOP 25 UserID, UserID, 45.50, GETDATE() FROM Users.Profiles;

-----------------------------------------------------------
-- 4. Social & Personalization (25 Rows Each)
-----------------------------------------------------------
-- Favorites, Collections, Recommendations, Viewed, Referrals
INSERT INTO Users.UserFavorites (UserID, RestaurantID, AddedAt) SELECT UserID, (UserID % 5) + 1, GETDATE() FROM Users.Profiles;
INSERT INTO Users.UserCollections (UserID, CollectionName, IsPublic, CreatedAt) SELECT UserID, 'My Fav Biryani', 1, GETDATE() FROM Users.Profiles;
INSERT INTO Users.RecentlyViewed (UserID, RestaurantID, ViewedAt) SELECT UserID, (UserID % 8) + 1, GETDATE() FROM Users.Profiles;
INSERT INTO Users.UserRecommendations (UserID, ItemID, Score, IsDismissed) SELECT UserID, 101, 0.95, 0 FROM Users.Profiles;
INSERT INTO Users.UserReferrals (UserID, RefereeUserID, SharedDate, IsConverted) SELECT UserID, (UserID % 20) + 1, GETDATE(), 1 FROM Users.Profiles WHERE UserID < 21;

-----------------------------------------------------------
-- 5. Behavior & Security (25 Rows Each)
-----------------------------------------------------------
-- LoginAttempts, BlockedUsers, BehaviorTracking, MealPreferences, MoodLogs
INSERT INTO Users.LoginAttempts (UserID, AttemptedEmail, IPAddress, AttemptStatus) SELECT UserID, Email, '10.0.0.1', 'Success' FROM Users.Profiles;
INSERT INTO Users.BlockedUsers (UserID, BlockedReason, IsPermanent) SELECT TOP 20 UserID, 'Fraud detected', 0 FROM Users.Profiles;
INSERT INTO Users.UserBehaviorTracking (UserID, EventType, PageURL) SELECT UserID, 'Click', '/home' FROM Users.Profiles;
INSERT INTO Users.UserMealPreferences (UserID, DietaryType, DailyCalorieGoal) SELECT UserID, 'Veg', 2000 FROM Users.Profiles;
INSERT INTO Users.UserMoodLogs (UserID, MoodTagID, LoggedAt) SELECT UserID, 1, GETDATE() FROM Users.Profiles;