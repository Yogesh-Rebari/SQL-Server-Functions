USE FoodDeliveryDB;
GO

-----------------------------------------------------------
-- 1. MarketingCampaigns (Note #89) - 20 Rows
-----------------------------------------------------------
INSERT INTO Marketing.Campaigns (CampaignName, StartDate, EndDate, Budget, CampaignStatus)
VALUES 
('Summer Splash', GETDATE(), DATEADD(MONTH, 1, GETDATE()), 50000.00, 'Active'),
('IPL 2026 Special', GETDATE(), DATEADD(MONTH, 2, GETDATE()), 150000.00, 'Active'),
('Midnight Craving', GETDATE(), DATEADD(MONTH, 1, GETDATE()), 30000.00, 'Active'),
('Healthy Start', GETDATE(), DATEADD(MONTH, 1, GETDATE()), 25000.00, 'Active'),
('Weekend Feast', GETDATE(), DATEADD(DAY, 3, GETDATE()), 10000.00, 'Active');
-- Adding 15 more generic campaigns
INSERT INTO Marketing.Campaigns (CampaignName, StartDate, EndDate, Budget, CampaignStatus)
SELECT 'Campaign '+CAST(N AS VARCHAR), GETDATE(), DATEADD(MONTH, 1, GETDATE()), 5000.00, 'Planned' 
FROM (SELECT TOP 15 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-----------------------------------------------------------
-- 2. Coupons & Offers (Notes #39, #12) - 20 Rows Each
-----------------------------------------------------------
-- Coupons
INSERT INTO Marketing.Coupons (CouponCode, DiscountType, MinOrderValue, MaxDiscount, ExpiryDate, UsageLimitPerUser)
VALUES 
('WELCOME100', 'Fixed', 300, 100, '2026-12-31', 1),
('CITSTUDENT', 'Percentage', 200, 50, '2026-06-30', 5),
('FREEDEL', 'Free Delivery', 150, 40, '2026-05-30', 10);
-- Fill to 20
INSERT INTO Marketing.Coupons (CouponCode, DiscountType, MinOrderValue, MaxDiscount, ExpiryDate, UsageLimitPerUser)
SELECT 'PROMO'+CAST(N AS VARCHAR), 'Percentage', 100, 20, '2026-12-31', 1 
FROM (SELECT TOP 17 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM sys.objects) AS T;

-- Offers (Linked to MenuItems)
INSERT INTO Marketing.Offers (ItemID, OfferCode, DiscountPercentage, ValidFrom, ValidTo)
SELECT TOP 20 (RestaurantID % 10) + 1, 'OFFER'+CAST(RestaurantID AS VARCHAR), 15.00, GETDATE(), DATEADD(DAY, 30, GETDATE()) 
FROM Restaurant.Profiles;

-----------------------------------------------------------
-- 3. LoyaltyPoints & PromoUsage (Notes #80, #17) - 25 Rows
-----------------------------------------------------------
-- Loyalty Points for your 25 Users
INSERT INTO Marketing.LoyaltyPoints (UserID, TotalPointsAccumulated, CurrentBalance, MembershipTier)
SELECT UserID, 500, 150, CASE WHEN UserID % 5 = 0 THEN 'Gold' ELSE 'Silver' END FROM Users.Profiles;

-- Promo Usage (Tracking which users used which coupons)
INSERT INTO Marketing.PromoUsage (OfferID, UserID, UsedOn, OrderID)
SELECT TOP 20 1, UserID, GETDATE(), UserID FROM Users.Profiles WHERE UserID < 21;

-----------------------------------------------------------
-- 4. Ads & Impressions (Notes #91, #92, #90) - 20+ Rows
-----------------------------------------------------------
-- AdBanners
INSERT INTO Marketing.AdBanners (RestaurantID, BannerImageURL, TargetURL, PriorityOrder, IsActive)
SELECT TOP 20 RestaurantID, 'http://cdn.foodapp.com/banner'+CAST(RestaurantID AS VARCHAR)+'.jpg', '/rest/'+CAST(RestaurantID AS VARCHAR), 1, 1 
FROM Restaurant.Profiles;

-- AdImpressions & Clicks
INSERT INTO Marketing.AdImpressions (BannerID, UserID, ViewedAt, DeviceType)
SELECT TOP 20 BannerID, (BannerID % 25) + 1, GETDATE(), 'Mobile' FROM Marketing.AdBanners;

INSERT INTO Marketing.CampaignClicks (CampaignID, UserID, ClickedAt, SourceChannel)
SELECT TOP 20 CampaignID, (CampaignID % 25) + 1, GETDATE(), 'Instagram' FROM Marketing.Campaigns;

-----------------------------------------------------------
-- 5. Trending & Referrals (Notes #76, #82, #93) - 20+ Rows
-----------------------------------------------------------
-- Trending Items (In specific Service Areas)
INSERT INTO Marketing.TrendingItems (ItemID, AreaID, OrderCountLast24Hours, LastUpdated)
SELECT TOP 20 (AreaID % 10) + 1, AreaID, 50 + AreaID, GETDATE() FROM Logistics.ServiceArea;

-- Area Trending Today
INSERT INTO Marketing.AreaTrendingItemsToday (AreaID, ItemID, OrderCountToday, GrowthPercentage)
SELECT TOP 20 AreaID, (AreaID % 5) + 1, 100, 15.5 FROM Logistics.ServiceArea;

-- Influencer Referrals
INSERT INTO Marketing.InfluencerReferrals (UserID, SocialHandle, UniquePromoCode, TotalEarnings)
SELECT TOP 20 UserID, '@influencer_'+CAST(UserID AS VARCHAR), 'INF'+CAST(UserID AS VARCHAR), 1500.00 FROM Users.Profiles WHERE UserID < 21;