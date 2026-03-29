USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. Categories (Note #5) - 20 Rows
-----------------------------------------------------------
INSERT INTO Restaurant.Categories (CategoryName) VALUES 
('Biryani'), ('Burgers'), ('South Indian'), ('North Indian'), ('Chinese'), 
('Pizza'), ('Desserts'), ('Beverages'), ('Salads'), ('Sea Food'),
('Bakery'), ('Street Food'), ('Italian'), ('Mexican'), ('Thai'),
('Continental'), ('Healthy Food'), ('Sandwiches'), ('Ice Cream'), ('Kebabs');

-----------------------------------------------------------
-- 2. Restaurants (Note #4) - 20 Rows
-----------------------------------------------------------
INSERT INTO Restaurant.Profiles (Name, Phone, Rating, IsOpen, LicenceNo, IsVeg) VALUES 
('Empire Restaurant', '9111111101', 4.5, 1, 'LINC1001', 0),
('Sagar Ratna', '9111111102', 4.2, 1, 'LINC1002', 1),
('Corner House', '9111111103', 4.8, 1, 'LINC1003', 1),
('Leon Grill', '9111111104', 4.3, 1, 'LINC1004', 0),
('Truffles', '9111111105', 4.6, 1, 'LINC1005', 0),
('MTR 1924', '9111111106', 4.7, 1, 'LINC1006', 1),
('Pizza Hut', '9111111107', 4.0, 1, 'LINC1007', 0),
('Burger King', '9111111108', 4.1, 1, 'LINC1008', 0),
('Wow! Momo', '9111111109', 3.9, 1, 'LINC1009', 0),
('Nandhini Deluxe', '9111111110', 4.4, 1, 'LINC1010', 0),
('Udupi Grand', '9111111111', 4.2, 1, 'LINC1011', 1),
('Beijing Bites', '9111111112', 4.1, 1, 'LINC1012', 0),
('Polar Bear', '9111111113', 4.5, 1, 'LINC1013', 1),
('Subway', '9111111114', 4.0, 1, 'LINC1014', 0),
('Domino''s', '9111111115', 4.3, 1, 'LINC1015', 0),
('KFC', '9111111116', 4.1, 1, 'LINC1016', 0),
('A2B', '9111111117', 4.4, 1, 'LINC1017', 1),
('Pista House', '9111111118', 4.6, 1, 'LINC1018', 0),
('Thalassery Kitchen', '9111111119', 4.3, 1, 'LINC1019', 0),
('Ammi''s Biryani', '9111111120', 3.8, 1, 'LINC1020', 0);

-----------------------------------------------------------
-- 3. MenuItems (Note #6) - 20 Rows
-----------------------------------------------------------
INSERT INTO Restaurant.MenuItems (RestaurantID, CategoryID, Name, Price, Description, IsVeg)
SELECT TOP 20 RestaurantID, (RestaurantID % 5) + 1, 'Signature Dish ' + CAST(RestaurantID AS VARCHAR), 250.00, 'Best seller', IsVeg 
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 4. RestaurantSchedule (Note #16) - 20 Rows
-----------------------------------------------------------
INSERT INTO Restaurant.RestaurantSchedule (RestaurantID, DayOfWeek, OpenTime, CloseTime)
SELECT TOP 20 RestaurantID, 'Monday', '09:00:00', '23:00:00' FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 5. RestaurantAddresses (Note #11) - 20 Rows
-----------------------------------------------------------
INSERT INTO Restaurant.RestaurantAddresses (RestaurantID, AddressLine, City, State, Pincode)
SELECT TOP 20 RestaurantID, 'Road No ' + CAST(RestaurantID AS VARCHAR), 'Bangalore', 'Karnataka', '560001' 
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 6. RestaurantStaff & Roles (Notes #24, #60, #61)
-----------------------------------------------------------
INSERT INTO Restaurant.StaffRoles (RoleName, CanEditMenu) VALUES ('Manager', 1), ('Chef', 1), ('Waiter', 0), ('Admin', 1);

INSERT INTO Restaurant.RestaurantStaff (FullName, Email, Password, Role, IsActive)
VALUES ('Staff One', 'staff1@food.com', 'pwd123', 'Manager', 1), ('Staff Two', 'staff2@food.com', 'pwd123', 'Chef', 1);

-- Mapping 20 staff members to restaurants
INSERT INTO Restaurant.Employees (RestaurantID, RoleID, FullName, Email, IsActive)
SELECT TOP 20 (EmployeeID % 20) + 1, 1, 'Employee ' + CAST(EmployeeID AS VARCHAR), 'emp'+CAST(EmployeeID AS VARCHAR)+'@food.com', 1 
FROM (SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS EmployeeID FROM sys.objects) AS T;

-----------------------------------------------------------
-- 7. Advanced Restaurant Features (Cloud Kitchens, Brands, Dining)
-----------------------------------------------------------
-- CloudKitchenHubs (Note #86)
INSERT INTO Restaurant.CloudKitchenHubs (HubName, PhysicalAddress, IsActive)
VALUES ('Central Hub', 'Majestic, Blr', 1), ('North Hub', 'Hebbal, Blr', 1), ('West Hub', 'Kengeri, Blr', 1);

-- VirtualBrands (Note #87)
INSERT INTO Restaurant.VirtualBrands (HubID, BrandName, CuisineType, IsActive)
SELECT TOP 20 1, 'Brand ' + CAST(RestaurantID AS VARCHAR), 'Fusion', 1 FROM Restaurant.Profiles;

-- Dining (Note #31) - Tables for restaurants
INSERT INTO Restaurant.Dining (RestaurantID, TableNumber, Capacity, IsAvailable)
SELECT TOP 20 RestaurantID, 1, 4, 1 FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 8. Logistics/Mapping (Note #23, #102)
-----------------------------------------------------------

-- RestaurantPackagingSupport (Note #102)
INSERT INTO Restaurant.RestaurantPackagingSupport (RestaurantID, PackagingID, IsDefault)
SELECT TOP 20 RestaurantID, 1, 1 FROM Restaurant.Profiles;