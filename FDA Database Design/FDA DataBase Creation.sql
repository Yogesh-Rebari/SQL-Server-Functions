CREATE DATABASE FoodDeliveryDB;
USE FoodDeliveryDB;

GO
-- Identity and User data
CREATE SCHEMA Users;
GO
-- Vendor and Menu data
CREATE SCHEMA Restaurant;
GO
-- Transactional data (Note: 'Order' is a reserved word, so we use brackets)
CREATE SCHEMA [Order];
GO
-- Delivery and Maps
CREATE SCHEMA Logistics;
GO
-- Payments and Taxes
CREATE SCHEMA Finance;
GO
-- Promotions and Ads
CREATE SCHEMA Marketing;
GO
-- Reviews and Social
CREATE SCHEMA Interaction;
GO
-- History and Metrics
CREATE SCHEMA Analytics;
GO
-- Configuration and Compliance
CREATE SCHEMA System;
GO