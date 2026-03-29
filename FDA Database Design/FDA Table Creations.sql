USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. USER Schema tables
-----------------------------------------------------------

-- Table 1: Profiles
CREATE TABLE Users.Profiles (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(15) UNIQUE,
    Email NVARCHAR(100) UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 2: MembershipPlans
CREATE TABLE Users.MembershipPlans (
    PlanID INT PRIMARY KEY IDENTITY(1,1),
    PlanName NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2),
    DurationDays INT,
    DiscountOnDelivery DECIMAL(5,2),
    DiscountOnDining DECIMAL(5,2),
    IsActive BIT DEFAULT 1
);


-- Table 3: Cart
CREATE TABLE Users.Cart (
    CartID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT UNIQUE FOREIGN KEY REFERENCES Users.Profiles(UserID),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Table 4: UserWallets
CREATE TABLE Users.UserWallets (
    WalletID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT UNIQUE FOREIGN KEY REFERENCES Users.Profiles(UserID),
    Balance DECIMAL(18,2) DEFAULT 0.00,
    LastUpdated DATETIME DEFAULT GETDATE(),
    IsBlocked BIT DEFAULT 0
);

-- Table 5: UserSessions
CREATE TABLE Users.UserSessions (
    SessionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    DeviceType NVARCHAR(50),
    IPAddress NVARCHAR(45),
    LoginTimestamp DATETIME DEFAULT GETDATE(),
    LogoutTimestamp DATETIME,
    SessionDuration INT, -- In seconds
    IsActive BIT DEFAULT 1
);

-- Table 6: UserSubscriptions
CREATE TABLE Users.UserSubscriptions (
    SubscriptionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    PlanID INT FOREIGN KEY REFERENCES Users.MembershipPlans(PlanID),
    StartDate DATETIME DEFAULT GETDATE(),
    EndDate DATETIME,
    AutoRenew BIT DEFAULT 1,
    SubStatus NVARCHAR(20) -- Active, Expired, Cancelled
);

-- Table 7: UserAddressBook
CREATE TABLE Users.UserAddressBook (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    AddressLabel NVARCHAR(50), -- Home, Work, Other
    FullAddress NVARCHAR(MAX),
    Landmark NVARCHAR(100),
    FloorNumber NVARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 8: UserCollections
CREATE TABLE Users.UserCollections (
    CollectionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    CollectionName NVARCHAR(100),
    [Description] NVARCHAR(MAX),
    IsPublic BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 9: LoginAttempts
CREATE TABLE Users.LoginAttempts (
    AttemptID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    AttemptedEmail NVARCHAR(100),
    IPAddress NVARCHAR(45),
    AttemptStatus NVARCHAR(20), -- Success, Failed
    DeviceIdentifier NVARCHAR(MAX),
    AttemptTime DATETIME DEFAULT GETDATE()
);

-- Table 10: BlockedUsers
CREATE TABLE Users.BlockedUsers (
    BlockID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    BlockedReason NVARCHAR(MAX),
    BlockedBy INT, -- Admin ID
    IsPermanent BIT DEFAULT 0,
    ExpiryDate DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 11: DeviceLogs
CREATE TABLE Users.DeviceLogs (
    DeviceLogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    DeviceName NVARCHAR(100),
    DeviceOS NVARCHAR(50),
    UniqueDeviceID NVARCHAR(100),
    LastLoginLocation NVARCHAR(255),
    IsTrusted BIT DEFAULT 0,
    LastUsedAt DATETIME DEFAULT GETDATE()
);

-- Table 12: UserMealPreferences
CREATE TABLE Users.UserMealPreferences (
    PreferenceID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT UNIQUE FOREIGN KEY REFERENCES Users.Profiles(UserID),
    DietaryType NVARCHAR(50), -- Vegan, Keto, etc.
    Allergies NVARCHAR(MAX),
    DailyCalorieGoal INT,
    CuisineDislikes NVARCHAR(MAX),
    PreferredMealTime TIME,
    UpdatedAt DATETIME DEFAULT GETDATE()
);


-- Table 13: CartItems
CREATE TABLE Users.CartItems (
    CartItemID INT PRIMARY KEY IDENTITY(1,1),
    CartID INT FOREIGN KEY REFERENCES Users.Cart(CartID),
    ItemID INT, -- Will link to Restaurant.MenuItems later
    Quantity INT DEFAULT 1
);

-- Linking ItemID to ItemID in Menu Items
ALTER TABLE Users.CartItems
ADD CONSTRAINT FK_CartItems_MenuItems 
FOREIGN KEY (ItemID) REFERENCES Restaurant.MenuItems(ItemID);

-- Table 14: UserActivityLogs
CREATE TABLE Users.UserActivityLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    SessionID INT FOREIGN KEY REFERENCES Users.UserSessions(SessionID),
    ActionTaken NVARCHAR(100),
    ActionTime DATETIME DEFAULT GETDATE()
);

-- Table 15: UserReferrals
CREATE TABLE Users.UserReferrals (
    ReferralID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID), -- The Referrer
    ReferredUserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID), -- The New User
    CouponID INT, -- link to Marketing.Coupons
    SharedDate DATETIME DEFAULT GETDATE(),
    IsConverted BIT DEFAULT 0,
    ReferrerBonusCredited BIT DEFAULT 0
);

-- Linking UserReferrals to the Marketing Coupons table
ALTER TABLE Users.UserReferrals
ADD CONSTRAINT FK_UserReferrals_Coupons 
FOREIGN KEY (CouponID) REFERENCES Marketing.Coupons(CouponID);

-- Table 16: MembershipSavings
CREATE TABLE Users.MembershipSavings (
    SavingID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    OrderID INT, -- Will link to Order.Transactions later
    BookingID INT, -- Will link to Dining.Bookings later
    AmountSaved DECIMAL(10,2),
    SavedAt DATETIME DEFAULT GETDATE()
);

-- Link to the Order Transactions table
ALTER TABLE Users.MembershipSavings
ADD CONSTRAINT FK_MembershipSavings_Order 
FOREIGN KEY (OrderID) REFERENCES [Order].Transactions(OrderID);

-- Link to the Dining Booking table (from the System schema)
ALTER TABLE Users.MembershipSavings
ADD CONSTRAINT FK_MembershipSavings_Booking 
FOREIGN KEY (BookingID) REFERENCES System.DiningBooking(BookingID);

-- Table 17: UserSavedMethods
CREATE TABLE Users.UserSavedMethods (
    SavedMethodID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    MethodID INT, -- Will link to Finance.PaymentMethods later
    ProviderToken NVARCHAR(MAX),
    MaskedIdentifier NVARCHAR(50), -- e.g. **** 1234
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- linking methodID
ALTER TABLE Users.UserSavedMethods
ADD CONSTRAINT FK_UserSavedMethods_PaymentMethods 
FOREIGN KEY (MethodID) REFERENCES Finance.PaymentMethods(MethodID);

-- Table 18: UserFavorites
CREATE TABLE Users.UserFavorites (
    FavoriteID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT, -- Will link to Restaurant.Profiles later
    AddedAt DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key to link UserFavorites to Restaurant.Profiles
ALTER TABLE Users.UserFavorites
ADD CONSTRAINT FK_UserFavorites_Restaurant 
FOREIGN KEY (RestaurantID) REFERENCES Restaurant.Profiles(RestaurantID);

-- Table 19: RecentlyViewed
CREATE TABLE Users.RecentlyViewed (
    ViewID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT,
    ItemID INT,
    ViewedAt DATETIME DEFAULT GETDATE()
);

-- Table 20: UserRecommendations
CREATE TABLE Users.UserRecommendations (
    RecID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ItemID INT,
    Score DECIMAL(5,2),
    RecommendationReason NVARCHAR(MAX),
    IsDismissed BIT DEFAULT 0,
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key to link UserRecommendations to MenuItems
ALTER TABLE Users.UserRecommendations
ADD CONSTRAINT FK_UserRecommendations_MenuItems 
FOREIGN KEY (ItemID) REFERENCES Restaurant.MenuItems(ItemID);

-- Table 21: UserBehaviorTracking
CREATE TABLE Users.UserBehaviorTracking (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    SessionID INT FOREIGN KEY REFERENCES Users.UserSessions(SessionID),
    EventType NVARCHAR(50), -- Click, Scroll, View
    TargetElement NVARCHAR(100),
    PageURL NVARCHAR(MAX),
    DurationSeconds INT,
    DeviceType NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 22: UserMoodLogs
CREATE TABLE Users.UserMoodLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    MoodTagID INT, -- Will link to System.MoodTags later
    LoggedAt DATETIME DEFAULT GETDATE(),
    ResultingOrderID INT 
);

-- 1. Link MoodTagID to the System.MoodTags table
ALTER TABLE Users.UserMoodLogs
ADD CONSTRAINT FK_UserMoodLogs_MoodTags 
FOREIGN KEY (MoodTagID) REFERENCES System.MoodTags(MoodTagID);

-- 2. Link ResultingOrderID to the Order.Transactions table
ALTER TABLE Users.UserMoodLogs
ADD CONSTRAINT FK_UserMoodLogs_Orders 
FOREIGN KEY (ResultingOrderID) REFERENCES [Order].Transactions(OrderID);



-----------------------------------------------------------
-- 2. Restaurant schema tables
-----------------------------------------------------------


-- Table 23: CloudKitchenHubs
CREATE TABLE Restaurant.CloudKitchenHubs (
    HubID INT PRIMARY KEY IDENTITY(1,1),
    HubName NVARCHAR(100) NOT NULL,
    PhysicalAddress NVARCHAR(MAX),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    ManagerName NVARCHAR(100),
    TotalKitchenBays INT,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 24: StaffRoles
CREATE TABLE Restaurant.StaffRoles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL, -- Admin, Chef, Manager, Waiter
    CanEditMenu BIT DEFAULT 0,
    CanViewPayouts BIT DEFAULT 0,
    CanProcessOrders BIT DEFAULT 0
);

-- Table 25: Categories
CREATE TABLE Restaurant.Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL -- Starters, Main Course, Beverages
);

-- Table 26: Profiles (Primary Restaurant Table)
CREATE TABLE Restaurant.Profiles (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(15),
    Rating DECIMAL(2,1) CHECK (Rating <= 5.0),
    IsOpen BIT DEFAULT 1,
    LicenceNo NVARCHAR(50),
    IsVeg BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 27: VirtualBrands
CREATE TABLE Restaurant.VirtualBrands (
    BrandID INT PRIMARY KEY IDENTITY(1,1),
    HubID INT FOREIGN KEY REFERENCES Restaurant.CloudKitchenHubs(HubID),
    BrandName NVARCHAR(100) NOT NULL,
    CuisineType NVARCHAR(50),
    BrandLogoURL NVARCHAR(MAX),
    BaseCommissionRate DECIMAL(5,2),
    IsActive BIT DEFAULT 1
);

-- Table 28: RestaurantAddresses
CREATE TABLE Restaurant.RestaurantAddresses (
    ResAddressID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    AddressLine NVARCHAR(MAX),
    City NVARCHAR(100),
    [State] NVARCHAR(100),
    Pincode NVARCHAR(10)
);

-- Table 29: MenuItems
CREATE TABLE Restaurant.MenuItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    CategoryID INT FOREIGN KEY REFERENCES Restaurant.Categories(CategoryID),
    [Name] NVARCHAR(150) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    [Description] NVARCHAR(MAX),
    IsVeg BIT DEFAULT 0
);

-- Table 30: RestaurantSchedule
CREATE TABLE Restaurant.RestaurantSchedule (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    [DayOfWeek] INT, -- 1 (Sun) to 7 (Sat)
    OpenTime TIME,
    CloseTime TIME
);

-- Table 31: Addons
CREATE TABLE Restaurant.Addons (
    AddonID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    AddonName NVARCHAR(100),
    AddonPrice DECIMAL(10,2)
);

-- Table 32: RestaurantStaff
CREATE TABLE Restaurant.RestaurantStaff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    [Password] NVARCHAR(MAX),
    Phone NVARCHAR(15),
    [Role] NVARCHAR(50), -- Descriptive role
    IsActive BIT DEFAULT 1
);

-- Table 33: StaffRestaurantMapping
CREATE TABLE Restaurant.StaffRestaurantMapping (
    MappingID INT PRIMARY KEY IDENTITY(1,1),
    StaffID INT FOREIGN KEY REFERENCES Restaurant.RestaurantStaff(StaffID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID)
);

-- Table 34: Dining (Tables/Layout)
CREATE TABLE Restaurant.Dining (
    DiningID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    TableNumber NVARCHAR(20),
    Capacity INT,
    TableLocation NVARCHAR(50), -- Window, Rooftop, Indoor
    IsAvailable BIT DEFAULT 1
);

-- Table 35: CollectionRestaurants
CREATE TABLE Restaurant.CollectionRestaurants (
    MappingID INT PRIMARY KEY IDENTITY(1,1),
    CollectionID INT, -- Links to Users.UserCollections later
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    AddedAt DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key link to UserCollections
ALTER TABLE Restaurant.CollectionRestaurants
ADD CONSTRAINT FK_CollectionRestaurants_UserCollections
FOREIGN KEY (CollectionID) REFERENCES Users.UserCollections(CollectionID);

-- Table 36: HiddenRestaurants
CREATE TABLE Restaurant.HiddenRestaurants (
    HideID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    UserID INT, -- Links to Users.Profiles
    Reason NVARCHAR(MAX),
    HiddenAt DATETIME DEFAULT GETDATE()
);

-- Linking UserID Foreign key
ALTER TABLE Restaurant.HiddenRestaurants
ADD CONSTRAINT FK_HiddenRestaurants_Users
FOREIGN KEY (UserID) REFERENCES Users.Profiles(UserID);

-- Table 37: Employees (HR focus)
CREATE TABLE Restaurant.Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    RoleID INT FOREIGN KEY REFERENCES Restaurant.StaffRoles(RoleID),
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(15),
    DateOfJoining DATE,
    IsActive BIT DEFAULT 1
);

-- Table 38: CloudKitchenDetails
CREATE TABLE Restaurant.CloudKitchenDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    BrandID INT FOREIGN KEY REFERENCES Restaurant.VirtualBrands(BrandID),
    EstimatedPrepTime INT, -- In minutes
    PackagingSpeciality NVARCHAR(100),
    PartnerPickupPoint NVARCHAR(100),
    SafetyCertifications NVARCHAR(MAX)
);

-- Table 39: RestaurantPackagingSupport
CREATE TABLE Restaurant.RestaurantPackagingSupport (
    SupportID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    PackagingID INT, -- Will link to System.PackagingTypes later
    IsDefault BIT DEFAULT 0
);

-- Linking PackagingID
ALTER TABLE Restaurant.RestaurantPackagingSupport
ADD CONSTRAINT FK_RestaurantPackaging_SystemTypes 
FOREIGN KEY (PackagingID) REFERENCES System.PackagingTypes(PackagingID);





-----------------------------------------------------------
-- 3. Order schema tables
-----------------------------------------------------------

-- Table 40: Orders
CREATE TABLE [Order].Transactions (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    PartnerID INT, -- Will link to Logistics.Partners later
    [Status] NVARCHAR(50) DEFAULT 'Pending', -- Pending, Confirmed, Preparing, OutForDelivery, Delivered
    TotalAmount DECIMAL(18,2) NOT NULL,
    OrderTime DATETIME DEFAULT GETDATE()
);

-- 1. Adding the Foreign Key constraint for PartnerID
ALTER TABLE [Order].Transactions
ADD CONSTRAINT FK_Orders_DeliveryPartners 
FOREIGN KEY (PartnerID) REFERENCES Logistics.Partners(PartnerID);

-- Table 41: OrderItem
CREATE TABLE [Order].OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    ItemID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    Quantity INT DEFAULT 1,
    PriceAtTimeOfOrder DECIMAL(18,2) NOT NULL -- Historical price snapshot
);

-- Table 42: OrderAddons
CREATE TABLE [Order].OrderAddons (
    OrderAddonID INT PRIMARY KEY IDENTITY(1,1),
    OrderDetailID INT NOT NULL FOREIGN KEY REFERENCES [Order].OrderItems(OrderItemID),
    AddonID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.Addons(AddonID),
    PriceAtTimeOfOrder DECIMAL(10,2)
);

-- Table 43: TrainOrderDetails (Special Logistics)
CREATE TABLE [Order].TrainOrderDetails (
    TrainOrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    TrainID INT, -- Will link to Logistics.Trains
    StationID INT, -- Will link to Logistics.RailwayStations
    PNRNumber NVARCHAR(20),
    CoachNumber NVARCHAR(10),
    SeatNumber NVARCHAR(10),
    ExpectedArrivalTime DATETIME,
    HaltDurationMinutes INT
);

-- 1. Link TrainID to Logistics.Trains
ALTER TABLE [Order].TrainOrderDetails
ADD CONSTRAINT FK_TrainOrderDetails_Trains 
FOREIGN KEY (TrainID) REFERENCES Logistics.Trains(TrainID);

-- 2. Link StationID to Logistics.RailwayStations
ALTER TABLE [Order].TrainOrderDetails
ADD CONSTRAINT FK_TrainOrderDetails_Stations 
FOREIGN KEY (StationID) REFERENCES Logistics.RailwayStations(StationID);

-- Table 44: SplitInvoices
CREATE TABLE [Order].SplitInvoices (
    SplitInvoiceID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    HostUserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    TotalBillAmount DECIMAL(18,2),
    NumberOfSplits INT,
    SplitType NVARCHAR(20), -- Equal, Custom, Item-wise
    [Status] NVARCHAR(20), -- Pending, Paid
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 45: OrderMilestones (Tracking status history)
CREATE TABLE [Order].OrderMilestones (
    MilestoneID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    MilestoneName NVARCHAR(100), -- Order Placed, Kitchen Accepted, Picked Up, etc.
    ReachedAt DATETIME DEFAULT GETDATE()
);

-- Table 46: CustomerFeedback
CREATE TABLE [Order].CustomerFeedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    Reason NVARCHAR(100),
    [Description] NVARCHAR(MAX),
    [Status] NVARCHAR(20), -- Resolved, Pending
    RestaurantComment NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 47: OrderCancellations
CREATE TABLE [Order].OrderCancellations (
    CancellationID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    CancelledBy NVARCHAR(50), -- User, Restaurant, System, Partner
    ReasonId INT, 
    CancellationTime DATETIME DEFAULT GETDATE(),
    RefundAmount DECIMAL(18,2) DEFAULT 0.00,
    CancellationFee DECIMAL(18,2) DEFAULT 0.00
);

-- Table 48: AbandonedCarts (Marketing/Retention)
CREATE TABLE [Order].AbandonedCarts (
    CartID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    TotalItems INT,
    CartValue DECIMAL(18,2),
    LastInteractionAt DATETIME DEFAULT GETDATE(),
    IsRecovered BIT DEFAULT 0,
    ReminderSentCount INT DEFAULT 0
);

-- Table 49: ReorderPatterns
CREATE TABLE [Order].ReorderPatterns (
    PatternID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    TimesOrdered INT DEFAULT 1,
    AvgIntervalDays INT,
    LastOrderedAt DATETIME
);

-- Table 50: MealPlans (Subscriptions)
CREATE TABLE [Order].MealPlans (
    PlanID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    PlanDate DATE,
    MealType NVARCHAR(20), -- Breakfast, Lunch, Dinner
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    IsOrdered BIT DEFAULT 0,
    [Status] NVARCHAR(20)
);






-----------------------------------------------------------
-- 4. Logistics Schema tables
-----------------------------------------------------------

-- Table 51: ServiceArea
CREATE TABLE Logistics.ServiceArea (
    AreaID INT PRIMARY KEY IDENTITY(1,1),
    AreaName NVARCHAR(100) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    CentralLatitude DECIMAL(9,6),
    CentralLongitude DECIMAL(9,6),
    RadiusInKM DECIMAL(5,2),
    IsActive BIT DEFAULT 1
);

-- Table 52: RailwayStations
CREATE TABLE Logistics.RailwayStations (
    StationID INT PRIMARY KEY IDENTITY(1,1),
    StationCode NVARCHAR(10) UNIQUE NOT NULL, -- e.g., SBC, TK
    StationName NVARCHAR(100) NOT NULL,
    City NVARCHAR(100),
    IsDeliveryEnabled BIT DEFAULT 1
);

-- Table 53: Trains
CREATE TABLE Logistics.Trains (
    TrainID INT PRIMARY KEY IDENTITY(1,1),
    TrainNumber NVARCHAR(10) UNIQUE NOT NULL,
    TrainName NVARCHAR(100),
    RouteDescription NVARCHAR(MAX)
);

-- Table 54: DeliveryPartners (Core Profile)
CREATE TABLE Logistics.Partners (
    PartnerID INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(15) UNIQUE,
    VehicleType NVARCHAR(50), -- Bike, Cycle, Electric
    Rating DECIMAL(2,1) DEFAULT 0.0,
    AvailabilityStatus NVARCHAR(20) DEFAULT 'Offline' -- Online, Busy, Offline
);

-- Table 55: PartnerDetails (Documentation/Sensitive Info)
CREATE TABLE Logistics.PartnerDetails (
    PartnerID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Logistics.Partners(PartnerID),
    VehicleNumber NVARCHAR(20),
    LicenseNumber NVARCHAR(50),
    IdentityProofURL NVARCHAR(MAX),
    BankAccNumber NVARCHAR(30),
    IFSCCode NVARCHAR(20)
);

-- Table 56: RestaurantServiceMapping
CREATE TABLE Logistics.RestaurantServiceMapping (
    MappingID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    AreaID INT NOT NULL FOREIGN KEY REFERENCES Logistics.ServiceArea(AreaID),
    BaseDeliveryCharge DECIMAL(10,2) DEFAULT 0.00
);

-- Table 57: DeliveryTracking (Real-time Logs)
CREATE TABLE Logistics.DeliveryTracking (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    StatusUpdate NVARCHAR(100), -- Picked up, Near Location, etc.
    CurrentLat DECIMAL(9,6),
    CurrentLong DECIMAL(9,6),
    UpdateTime DATETIME DEFAULT GETDATE()
);

-- Table 58: PartnerShifts
CREATE TABLE Logistics.PartnerShifts (
    ShiftID INT PRIMARY KEY IDENTITY(1,1),
    PartnerID INT NOT NULL FOREIGN KEY REFERENCES Logistics.Partners(PartnerID),
    LoginTime DATETIME DEFAULT GETDATE(),
    LogoutTime DATETIME,
    TotalHoursWorked DECIMAL(5,2),
    IsOnline BIT DEFAULT 0
);

-- Table 59: SurgePricing
CREATE TABLE Logistics.SurgePricing (
    SurgeID INT PRIMARY KEY IDENTITY(1,1),
    AreaID INT NOT NULL FOREIGN KEY REFERENCES Logistics.ServiceArea(AreaID),
    SurgeMultiplier DECIMAL(3,2) DEFAULT 1.0, -- e.g., 1.5x
    Reason NVARCHAR(100), -- Rain, Peak Hour, Festival
    IsActive BIT DEFAULT 1,
    StartAt DATETIME,
    EndAt DATETIME
);




-----------------------------------------------------------
-- 5. Finance Schema Tables
-----------------------------------------------------------

-- Table 60: Tax
CREATE TABLE Finance.Tax (
    TaxID INT PRIMARY KEY IDENTITY(1,1),
    TaxName NVARCHAR(50) NOT NULL, -- GST, VAT, Service Tax
    [Percentage] DECIMAL(5,2) NOT NULL
);

-- Table 61: PaymentMethods
CREATE TABLE Finance.PaymentMethods (
    MethodID INT PRIMARY KEY IDENTITY(1,1),
    MethodName NVARCHAR(50) NOT NULL, -- UPI, Credit Card, NetBanking
    ProviderName NVARCHAR(100), -- Razorpay, Stripe, Paytm
    IsActive BIT DEFAULT 1
);

-- Table 62: GiftCardTemplates
CREATE TABLE Finance.GiftCardTemplates (
    TemplateID INT PRIMARY KEY IDENTITY(1,1),
    CardName NVARCHAR(100),
    InitialValue DECIMAL(10,2),
    ExpiryMonths INT,
    IsActive BIT DEFAULT 1
);

-- Table 63: Wallets
CREATE TABLE Finance.Wallets (
    WalletID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Users.Profiles(UserID),
    CurrentBalance DECIMAL(18,2) DEFAULT 0.00,
    LastUpdated DATETIME DEFAULT GETDATE(),
    IsBlocked BIT DEFAULT 0
);

-- Table 64: IssuedGiftCards
CREATE TABLE Finance.IssuedGiftCards (
    CardID INT PRIMARY KEY IDENTITY(1,1),
    TemplateID INT FOREIGN KEY REFERENCES Finance.GiftCardTemplates(TemplateID),
    CardCode NVARCHAR(20) UNIQUE NOT NULL,
    CurrentBalance DECIMAL(10,2),
    PurchaserUserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ExpiryDate DATETIME,
    IsRedeemed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 65: Payments
CREATE TABLE Finance.Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    PaymentMode NVARCHAR(50), -- Links logically to PaymentMethods
    TransactionStatus NVARCHAR(20), -- Success, Pending, Failed
    TaxAmount DECIMAL(18,2),
    DeliveryFee DECIMAL(10,2),
    TaxID INT FOREIGN KEY REFERENCES Finance.Tax(TaxID)
);

-- Table 66: TransactionDetails (Gateway Response)
CREATE TABLE Finance.TransactionDetails (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    PaymentID INT FOREIGN KEY REFERENCES Finance.Payments(PaymentID),
    GatewayTransactionID NVARCHAR(100),
    ResponseCode NVARCHAR(20),
    ResponseMessage NVARCHAR(MAX),
    BankReferenceNo NVARCHAR(100),
    CardType NVARCHAR(20),
    ProcessedAt DATETIME DEFAULT GETDATE()
);

-- Table 67: Refunds
CREATE TABLE Finance.Refunds (
    RefundID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users.Profiles(UserID),
    Amount DECIMAL(18,2) NOT NULL,
    RefundStatus NVARCHAR(20), -- Initiated, Processed, Failed
    TransactionReference NVARCHAR(100),
    ProcessedAt DATETIME
);

-- Table 68: WalletTransactions
CREATE TABLE Finance.WalletTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    WalletID INT FOREIGN KEY REFERENCES Finance.Wallets(WalletID),
    OrderID INT, -- Can be NULL if it's a top-up
    RefundID INT, -- Links if the refund went to wallet
    GiftCardID INT, -- Links if gift card was redeemed to wallet
    Amount DECIMAL(18,2),
    TransactionType NVARCHAR(20), -- Debit, Credit
    TransactionStatus NVARCHAR(20),
    Remarks NVARCHAR(MAX),
    TransactionDate DATETIME DEFAULT GETDATE()
);

-- Link to Order Transactions (Table #7)
ALTER TABLE Finance.WalletTransactions
ADD CONSTRAINT FK_WalletTransactions_Orders 
FOREIGN KEY (OrderID) REFERENCES [Order].Transactions(OrderID);

-- Link to Refunds (Table #30)
ALTER TABLE Finance.WalletTransactions
ADD CONSTRAINT FK_WalletTransactions_Refunds 
FOREIGN KEY (RefundID) REFERENCES Finance.Refunds(RefundID);

-- Link to Issued Gift Cards (Table #42)
ALTER TABLE Finance.WalletTransactions
ADD CONSTRAINT FK_WalletTransactions_GiftCards 
FOREIGN KEY (GiftCardID) REFERENCES Finance.IssuedGiftCards(CardID);

-- Table 69: PaymentSplits (Linking to SplitInvoices)
CREATE TABLE Finance.PaymentSplits (
    PaymentSplitID INT PRIMARY KEY IDENTITY(1,1),
    SplitInvoiceID INT FOREIGN KEY REFERENCES [Order].SplitInvoices(SplitInvoiceID),
    FriendUserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ShareAmount DECIMAL(18,2),
    UPITransactionRef NVARCHAR(100),
    UPILinkGenerated NVARCHAR(MAX),
    PaymentStatus NVARCHAR(20),
    PaidAt DATETIME
);

-- Table 70: GiftCardTransactions
CREATE TABLE Finance.GiftCardTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CardID INT FOREIGN KEY REFERENCES Finance.IssuedGiftCards(CardID),
    OrderID INT FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    AmountUsed DECIMAL(10,2),
    TransactionTime DATETIME DEFAULT GETDATE()
);

-- Table 71: RestaurantPayouts
CREATE TABLE Finance.RestaurantPayouts (
    PayoutID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    PeriodStart DATE,
    PeriodEnd DATE,
    TotalSales DECIMAL(18,2),
    PlatformCommission DECIMAL(18,2),
    TaxDeducted DECIMAL(18,2),
    FinalPayout DECIMAL(18,2),
    PayoutStatus NVARCHAR(20),
    ProcessedAt DATETIME
);

-- Table 72: PartnerEarnings
CREATE TABLE Finance.PartnerEarnings (
    EarningID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES [Order].Transactions(OrderID),
    PartnerID INT FOREIGN KEY REFERENCES Logistics.Partners(PartnerID),
    TripDistance DECIMAL(5,2),
    BasePay DECIMAL(10,2),
    IncentivePay DECIMAL(10,2),
    TipAmount DECIMAL(10,2),
    TotalEarned DECIMAL(10,2)
);





-----------------------------------------------------------
-- 6. Marketing Schema tables
-----------------------------------------------------------

-- Table 73: MarketingCampaigns
CREATE TABLE Marketing.Campaigns (
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName NVARCHAR(100) NOT NULL,
    StartDate DATETIME,
    EndDate DATETIME,
    Budget DECIMAL(18,2),
    CampaignStatus NVARCHAR(20) -- Active, Paused, Completed
);

-- Table 74 (Note: Numbered 12 in list, 73 in your text): Offers
CREATE TABLE Marketing.Offers (
    OfferID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    OfferCode NVARCHAR(20) UNIQUE,
    DiscountPercentage DECIMAL(5,2),
    ValidFrom DATETIME,
    ValidTo DATETIME,
    MinOrderValue DECIMAL(10,2)
);

-- Table 75: Coupons
CREATE TABLE Marketing.Coupons (
    CouponID INT PRIMARY KEY IDENTITY(1,1),
    CouponCode NVARCHAR(20) UNIQUE NOT NULL,
    DiscountType NVARCHAR(20), -- Percentage, Flat
    MinOrderValue DECIMAL(10,2),
    MaxDiscount DECIMAL(10,2),
    ExpiryDate DATETIME,
    UsageLimitPerUser INT DEFAULT 1,
    IsReferralCode BIT DEFAULT 0
);

-- Table 76: LoyaltyPoints
CREATE TABLE Marketing.LoyaltyPoints (
    PointID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT UNIQUE FOREIGN KEY REFERENCES Users.Profiles(UserID),
    TotalPointsAccumulated INT DEFAULT 0,
    CurrentBalance INT DEFAULT 0,
    MembershipTier NVARCHAR(20), -- Silver, Gold, Platinum
    PointsToNextTier INT,
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- Table 77: InfluencerReferrals
CREATE TABLE Marketing.InfluencerReferrals (
    InfluencerID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    SocialHandle NVARCHAR(100),
    UniquePromoCode NVARCHAR(20) UNIQUE,
    CommissionPerOrder DECIMAL(10,2),
    TotalReferralCount INT DEFAULT 0,
    TotalEarnings DECIMAL(18,2) DEFAULT 0.00
);

-- Table 78: AdBanners
CREATE TABLE Marketing.AdBanners (
    BannerID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    BannerImageURL NVARCHAR(MAX),
    TargetURL NVARCHAR(MAX),
    PositionSlot NVARCHAR(50), -- HomeTop, SearchSidebar
    PriorityOrder INT,
    IsActive BIT DEFAULT 1
);

-- Table 79: AdImpressions (Views)
CREATE TABLE Marketing.AdImpressions (
    ImpressionID INT PRIMARY KEY IDENTITY(1,1),
    BannerID INT FOREIGN KEY REFERENCES Marketing.AdBanners(BannerID),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ViewedAt DATETIME DEFAULT GETDATE(),
    DeviceType NVARCHAR(50)
);

-- Table 80: CampaignClicks
CREATE TABLE Marketing.CampaignClicks (
    ClickID INT PRIMARY KEY IDENTITY(1,1),
    CampaignID INT FOREIGN KEY REFERENCES Marketing.Campaigns(CampaignID),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    ClickedAt DATETIME DEFAULT GETDATE(),
    SourceChannel NVARCHAR(50) -- Email, SMS, Push
);

-- Table 81: PromoUsage
CREATE TABLE Marketing.PromoUsage (
    UsageID INT PRIMARY KEY IDENTITY(1,1),
    OfferID INT FOREIGN KEY REFERENCES Marketing.Offers(OfferID),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    UsedOn DATETIME DEFAULT GETDATE(),
    OrderID INT FOREIGN KEY REFERENCES [Order].Transactions(OrderID)
);

-- Table 82: TrendingItems
CREATE TABLE Marketing.TrendingItems (
    TrendID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    AreaID INT, -- Links to Logistics.ServiceArea
    OrderCountLast24Hours INT,
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key to link TrendingItems to ServiceArea
ALTER TABLE Marketing.TrendingItems
ADD CONSTRAINT FK_TrendingItems_ServiceArea
FOREIGN KEY (AreaID) REFERENCES Logistics.ServiceArea(AreaID);

-- Table 83: AreaTrendingItemsToday
CREATE TABLE Marketing.AreaTrendingItemsToday (
    TrendID INT PRIMARY KEY IDENTITY(1,1),
    AreaID INT, -- Links to Logistics.ServiceArea
    ItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    OrderCountToday INT,
    GrowthPercentage DECIMAL(5,2),
    LastCalculatedAt DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key to link Marketing to Logistics
ALTER TABLE Marketing.AreaTrendingItemsToday
ADD CONSTRAINT FK_AreaTrending_ServiceArea
FOREIGN KEY (AreaID) REFERENCES Logistics.ServiceArea(AreaID);





-----------------------------------------------------------
-- 7. Interaction Schema Tables
-----------------------------------------------------------

-- Table 84: NGOs
CREATE TABLE Interaction.NGOs (
    NGOID INT PRIMARY KEY IDENTITY(1,1),
    NGOName NVARCHAR(150) NOT NULL,
    RegistrationNumber NVARCHAR(100) UNIQUE,
    ContactPerson NVARCHAR(100),
    Phone NVARCHAR(15),
    CityOfOperation NVARCHAR(100),
    IsVerified BIT DEFAULT 0
);

-- Table 85: CSRCampaigns
CREATE TABLE Interaction.CSRCampaigns (
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName NVARCHAR(150) NOT NULL,
    [Description] NVARCHAR(MAX),
    TargetAmount DECIMAL(18,2),
    CurrentRaised DECIMAL(18,2) DEFAULT 0.00,
    StartDate DATETIME,
    EndDate DATETIME,
    IsActive BIT DEFAULT 1
);

-- Table 86: Donations
CREATE TABLE Interaction.Donations (
    DonationID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    CampaignID INT FOREIGN KEY REFERENCES Interaction.CSRCampaigns(CampaignID),
    OrderID INT FOREIGN KEY REFERENCES [Order].Transactions(OrderID), -- "Round up for charity"
    Amount DECIMAL(10,2) NOT NULL,
    DonationDate DATETIME DEFAULT GETDATE(),
    IsTaxReceiptGenerated BIT DEFAULT 0
);

-- Table 87: DonationImpact
CREATE TABLE Interaction.DonationImpact (
    ImpactID INT PRIMARY KEY IDENTITY(1,1),
    CampaignID INT FOREIGN KEY REFERENCES Interaction.CSRCampaigns(CampaignID),
    NGOID INT FOREIGN KEY REFERENCES Interaction.NGOs(NGOID),
    AmountDisbursed DECIMAL(18,2),
    MealsProvided INT,
    EvidenceURL NVARCHAR(MAX), -- Photos of the drive
    DisbursedDate DATETIME
);

-- Table 88: AppFeedbackCategories
CREATE TABLE Interaction.AppFeedbackCategories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL, -- UI/UX, Delivery Issue, Payment Bug
    DepartmentResponsibility NVARCHAR(100)
);

-- Table 89: AppFeedback
CREATE TABLE Interaction.AppFeedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID), -- Optional
    PartnerID INT FOREIGN KEY REFERENCES Logistics.Partners(PartnerID), -- Optional
    SourceRole NVARCHAR(20), -- User, Partner, Restaurant
    CategoryID INT FOREIGN KEY REFERENCES Interaction.AppFeedbackCategories(CategoryID),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments NVARCHAR(MAX),
    DeviceModel NVARCHAR(100),
    AppVersion NVARCHAR(20),
    AttachmentURL NVARCHAR(MAX), -- Screenshot of bug
    [Status] NVARCHAR(20) DEFAULT 'Open', -- Open, In Progress, Resolved
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table 90: AppFeedbackResponses
CREATE TABLE Interaction.AppFeedbackResponses (
    ResponseID INT PRIMARY KEY IDENTITY(1,1),
    FeedbackID INT FOREIGN KEY REFERENCES Interaction.AppFeedback(FeedbackID),
    AdminID INT, -- The support agent
    ResponseText NVARCHAR(MAX),
    RespondedAt DATETIME DEFAULT GETDATE()
);






-----------------------------------------------------------
-- 8. Analytics Schema Tables
-----------------------------------------------------------

-- Table 91: ItemPriceHistory
CREATE TABLE Analytics.ItemPriceHistory (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID),
    OldPrice DECIMAL(18,2),
    NewPrice DECIMAL(18,2) NOT NULL,
    ChangedBy INT, -- Links to Restaurant.StaffStaff
    ChangeDate DATETIME DEFAULT GETDATE()
);

-- Adding the Foreign Key to link Price History to the Staff member who made the change
ALTER TABLE Analytics.ItemPriceHistory
ADD CONSTRAINT FK_ItemPriceHistory_Staff 
FOREIGN KEY (ChangedBy) REFERENCES Restaurant.RestaurantStaff(StaffID);

-- Table 92: OrderAnalytics
CREATE TABLE Analytics.OrderAnalytics (
    AnalyticID INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATE NOT NULL,
    ServiceAreaID INT, -- Links to Logistics.ServiceArea
    TotalOrders INT DEFAULT 0,
    TotalRevenue DECIMAL(18,2) DEFAULT 0.00,
    TotalCancellations INT DEFAULT 0,
    AvgOrderValue DECIMAL(18,2),
    PopularCategory NVARCHAR(100),
    PeakOrderTime TIME -- e.g., 8:00 PM
);

-- Adding the Foreign Key constraint to link Analytics to ServiceArea
ALTER TABLE Analytics.OrderAnalytics
ADD CONSTRAINT FK_OrderAnalytics_ServiceArea
FOREIGN KEY (ServiceAreaID) REFERENCES Logistics.ServiceArea(AreaID);

-- Table 93: RestaurantPerformance
CREATE TABLE Analytics.RestaurantPerformance (
    PerfID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    ReportingMonth DATE, -- e.g., '2026-03-01'
    TotalOrdersServed INT DEFAULT 0,
    GrossRevenue DECIMAL(18,2) DEFAULT 0.00,
    AvgPreparationTimeMinutes INT,
    CancellationRate DECIMAL(5,2),
    CustomerSatisfactionScore DECIMAL(3,2), -- 1.0 to 5.0
    TopSellingItemID INT FOREIGN KEY REFERENCES Restaurant.MenuItems(ItemID)
);

-- Table 94: DeliveryPerformance
CREATE TABLE Analytics.DeliveryPerformance (
    DPerfID INT PRIMARY KEY IDENTITY(1,1),
    PartnerID INT NOT NULL FOREIGN KEY REFERENCES Logistics.Partners(PartnerID),
    TotalTripsCompleted INT DEFAULT 0,
    AvgDeliveryTimeMinutes INT,
    OnTimeDeliveryPercentage DECIMAL(5,2),
    TotalEarnings DECIMAL(18,2),
    FuelEfficiencyBonus DECIMAL(10,2),
    RatingsReceived INT,
    AvgPartnerRating DECIMAL(3,2)
);





-----------------------------------------------------------
-- 9. System Schema Tables
-----------------------------------------------------------

-- Table 95: Addresses (Master Table for generic locations)
CREATE TABLE System.Addresses (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    AddressLine NVARCHAR(MAX),
    City NVARCHAR(100),
    [State] NVARCHAR(100),
    Pincode NVARCHAR(10),
    LatLong GEOGRAPHY -- SSMS specific type for spatial data
);

-- Table 96: MoodTags (For personalized discovery)
CREATE TABLE System.MoodTags (
    MoodTagID INT PRIMARY KEY IDENTITY(1,1),
    MoodName NVARCHAR(50), -- e.g., 'Comfort Food', 'Party Vibes'
    CuisineCategory NVARCHAR(50),
    HealthScoreRequirement INT -- Filter for mood-based health goals
);

-- Table 97: PackagingTypes (Sustainability/Eco-friendly)
CREATE TABLE System.PackagingTypes (
    PackagingID INT PRIMARY KEY IDENTITY(1,1),
    MaterialName NVARCHAR(100), -- Plastic, Paper, Compostable
    CarbonFootprintPerUnit DECIMAL(10,4),
    ExtraCost DECIMAL(10,2) DEFAULT 0.00,
    IsActive BIT DEFAULT 1
);

-- Table 98: DiningBooking
CREATE TABLE System.DiningBooking (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    DiningID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID), 
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    BookingTime DATETIME,
    BookedAt DATETIME DEFAULT GETDATE(),
    SessionType NVARCHAR(20), -- Lunch, Dinner, Event
    SlotStartTime TIME,
    SlotEndTime TIME,
    GuestCount INT,
    BookingStatus NVARCHAR(20) -- Confirmed, Cancelled, Completed
);

-- Table 99: BookingSpecialRequests
CREATE TABLE System.BookingSpecialRequests (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT FOREIGN KEY REFERENCES System.DiningBooking(BookingID),
    RequestType NVARCHAR(50), -- Anniversary, Birthday, Highchair
    [Description] NVARCHAR(MAX),
    IsPaid BIT DEFAULT 0,
    AdditionalCharge DECIMAL(10,2)
);

-- Table 100: NotificationTemplates
CREATE TABLE System.NotificationTemplates (
    TemplateID INT PRIMARY KEY IDENTITY(1,1),
    TriggerEvent NVARCHAR(100), -- OrderPlaced, PaymentFailed, Promo
    TitleTemplate NVARCHAR(200),
    BodyTemplate NVARCHAR(MAX),
    RecipientRole NVARCHAR(20) -- User, Partner, Restaurant
);

-- Table 101: Notifications 
CREATE TABLE System.Notifications (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users.Profiles(UserID),
    RestaurantID INT, -- Optional link
    PartnerID INT, -- Optional link
    Title NVARCHAR(200),
    MessageBody NVARCHAR(MAX),
    Channel NVARCHAR(20), -- SMS, Email, Push
    CreatedAt DATETIME DEFAULT GETDATE(),
    ReadAt DATETIME
);

-- Link to the Restaurant Profiles
ALTER TABLE System.Notifications
ADD CONSTRAINT FK_Notifications_Restaurant 
FOREIGN KEY (RestaurantID) REFERENCES Restaurant.Profiles(RestaurantID);

-- Link to the Delivery Partners
ALTER TABLE System.Notifications
ADD CONSTRAINT FK_Notifications_Partner 
FOREIGN KEY (PartnerID) REFERENCES Logistics.Partners(PartnerID);

-- Table 102: RegulatoryCompliance 
CREATE TABLE System.RegulatoryCompliance (
    DocID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurant.Profiles(RestaurantID),
    PartnerID INT FOREIGN KEY REFERENCES Logistics.Partners(PartnerID),
    HubID INT, -- Links to CloudKitchenHubs
    DocumentType NVARCHAR(100), -- FSSAI, Insurance, PUC
    DocumentNumber NVARCHAR(100),
    DocumentImageURL NVARCHAR(MAX),
    IssueDate DATE,
    ExpiryDate DATE,
    VerificationStatus NVARCHAR(20), -- Pending, Verified, Rejected
    VerifiedBy INT, -- Admin ID
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME
);

-- Add the Foreign Key for HubID (Linking System to Restaurant schema)
ALTER TABLE System.RegulatoryCompliance
ADD CONSTRAINT FK_RegulatoryCompliance_CloudKitchenHubs 
FOREIGN KEY (HubID) REFERENCES Restaurant.CloudKitchenHubs(HubID);


GO