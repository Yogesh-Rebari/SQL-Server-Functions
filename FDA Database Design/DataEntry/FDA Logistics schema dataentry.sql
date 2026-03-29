
USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. ServiceArea (Note #22) - 20 Rows
-----------------------------------------------------------
INSERT INTO Logistics.ServiceArea (AreaName, City, CentralLatitude, CentralLongitude, RadiusInKM, IsActive)
VALUES 
('Koramangala', 'Bangalore', 12.9352, 77.6245, 5.0, 1),
('Indiranagar', 'Bangalore', 12.9719, 77.6412, 4.5, 1),
('Jayanagar', 'Bangalore', 12.9250, 77.5938, 5.5, 1),
('Whitefield', 'Bangalore', 12.9698, 77.7499, 8.0, 1),
('HSR Layout', 'Bangalore', 12.9121, 77.6446, 5.0, 1),
('Electronic City', 'Bangalore', 12.8452, 77.6635, 10.0, 1),
('Malleshwaram', 'Bangalore', 12.9984, 77.5712, 4.0, 1),
('Rajajinagar', 'Bangalore', 12.9847, 77.5562, 4.0, 1),
('Hebbal', 'Bangalore', 13.0354, 77.5988, 6.0, 1),
('Marathahalli', 'Bangalore', 12.9569, 77.7011, 5.0, 1),
('Tumkur Central', 'Tumkur', 13.3392, 77.1140, 7.0, 1),
('Sira Road', 'Tumkur', 13.3550, 77.0980, 5.0, 1),
('Batawadi', 'Tumkur', 13.3280, 77.1250, 4.0, 1),
('Kyatsandra', 'Tumkur', 13.3150, 77.1500, 6.0, 1),
('Siddhartha Nagar', 'Tumkur', 13.3300, 77.1400, 3.5, 1),
('Gubbi Gate', 'Tumkur', 13.3450, 77.1000, 3.0, 1),
('MG Road', 'Bangalore', 12.9756, 77.6067, 3.0, 1),
('BTM Layout', 'Bangalore', 12.9166, 77.6101, 4.5, 1),
('JP Nagar', 'Bangalore', 12.9063, 77.5857, 5.0, 1),
('Bannerghatta', 'Bangalore', 12.8391, 77.5765, 12.0, 1);

-----------------------------------------------------------
-- 2. DeliveryPartners (Note #3) - 25 Rows
-----------------------------------------------------------
-- Using generic names to reach 25 partners
INSERT INTO Logistics.Partners (Name, Phone, VehicleType, Rating, AvailabilityStatus)
SELECT 
    'Partner ' + CAST(T.N AS VARCHAR),
    '99000000' + RIGHT('00' + CAST(T.N AS VARCHAR), 2),
    CASE WHEN T.N % 3 = 0 THEN 'Electric Bike' ELSE 'Petrol Bike' END,
    4.0 + (T.N % 10) * 0.1,
    'Online'
FROM (SELECT TOP 25 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-----------------------------------------------------------
-- 3. PartnerDetails (Note #34) - 25 Rows
-----------------------------------------------------------
INSERT INTO Logistics.PartnerDetails (PartnerID, VehicleNumber, LicenseNumber, IdentityProofURL)
SELECT PartnerID, 'KA-01-EE-' + CAST(1000+PartnerID AS VARCHAR), 'DL' + CAST(5000+PartnerID AS VARCHAR), 'http://docs.com/id'+CAST(PartnerID AS VARCHAR)
FROM Logistics.Partners;

-----------------------------------------------------------
-- 4. PartnerShifts (Note #35) - 20 Rows
-----------------------------------------------------------
INSERT INTO Logistics.PartnerShifts (PartnerID, LoginTime, LogoutTime, TotalHoursWorked, IsOnline)
SELECT TOP 20 PartnerID, DATEADD(HOUR, -8, GETDATE()), GETDATE(), 8.0, 1 
FROM Logistics.Partners;

-----------------------------------------------------------
-- 5. DeliveryTracking (Note #15) - 20 Rows
-----------------------------------------------------------
INSERT INTO Logistics.DeliveryTracking (OrderID, StatusUpdate, CurrentLat, CurrentLong, UpdateTime)
SELECT TOP 20 OrderID, 'Out for Delivery', 12.9352, 77.6245, GETDATE() 
FROM [Order].Transactions;

-----------------------------------------------------------
-- 6. SurgePricing (Note #81) - 20 Rows
-----------------------------------------------------------
INSERT INTO Logistics.SurgePricing (AreaID, SurgeMultiplier, Reason, IsActive, StartAt, EndAt)
SELECT TOP 20 AreaID, 1.5, 'Heavy Rain', 1, GETDATE(), DATEADD(HOUR, 2, GETDATE()) 
FROM Logistics.ServiceArea;

-----------------------------------------------------------
-- 7. Railway Logistics (Notes #57, #58) - 20 Rows
-----------------------------------------------------------
-- RailwayStations
INSERT INTO Logistics.RailwayStations (StationCode, StationName, City, IsDeliveryEnabled)
VALUES ('SBC', 'KSR Bengaluru', 'Bangalore', 1), ('TK', 'Tumakuru', 'Tumkur', 1), ('YPR', 'Yesvantpur', 'Bangalore', 1);

-- Adding more stations to reach 20 if needed, or repeating codes
INSERT INTO Logistics.RailwayStations (StationCode, StationName, City, IsDeliveryEnabled)
SELECT 'STN'+CAST(N AS VARCHAR), 'Station '+CAST(N AS VARCHAR), 'City X', 1 
FROM (SELECT TOP 17 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 3 AS N FROM sys.objects) AS T;

-- Trains
INSERT INTO Logistics.Trains (TrainNumber, TrainName, RouteDescription)
SELECT '126'+CAST(N AS VARCHAR), 'Express '+CAST(N AS VARCHAR), 'Route Details' 
FROM (SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;