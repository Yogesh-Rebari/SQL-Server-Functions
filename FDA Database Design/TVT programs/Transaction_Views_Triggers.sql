-- 1. Transactions (All or Nothing Rule)
-- Example: If a user pays for an order, you must (1) Create the Order AND 
--  (2) Deduct the Money. If step 2 fails, you must cancel step 1.
CREATE PROCEDURE Finance.ProcessOrderPayment
    @UserID INT,
    @OrderID INT,
    @Amount DECIMAL(10,2)
AS
BEGIN
    BEGIN TRANSACTION; -- Start the "Safety Net"
    BEGIN TRY
        -- 1. Deduct money from Wallet
        UPDATE Users.UserWallets 
        SET Balance = Balance - @Amount 
        WHERE UserID = @UserID;

        -- 2. Update Order Status
        UPDATE [Order].Transactions 
        SET Status = 'Paid' 
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION; -- Save everything if both worked
        PRINT 'Payment Successful';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Undo everything if any error occurred
        PRINT 'Transaction Failed. Money not deducted. Error: ' + ERROR_MESSAGE();
    END CATCH
END;

--2. Views (Virtual Table)
CREATE VIEW Analytics.vw_OrderSummary AS
SELECT 
    O.OrderID,
    U.Name AS Customer,
    R.Name AS Restaurant,
    O.TotalAmount,
    O.Status,
    O.OrderTime
FROM [Order].Transactions O
JOIN Users.Profiles U ON O.UserID = U.UserID
JOIN Restaurant.Profiles R ON O.RestaurantID = R.RestaurantID;
GO
-- Usage:
SELECT * FROM Analytics.vw_OrderSummary WHERE Status = 'Delivered';

CREATE VIEW Restaurant.vw_VegMenu AS
SELECT Name, Price, Description
FROM Restaurant.MenuItems
WHERE IsVeg = 1;

--3. Triggers (Auto-Pilot)
-- Example 01 : When the balance in a wallet changes, this trigger updates the LastUpdated column automatically.
CREATE TRIGGER Users.trg_UpdateWalletTime
ON Users.UserWallets
AFTER UPDATE
AS
BEGIN
    UPDATE Users.UserWallets
    SET LastUpdated = GETDATE()
    FROM Users.UserWallets W
    JOIN inserted i ON W.WalletID = i.WalletID; -- "inserted" is a magic table in SQL
END;

-- Example 02 : If someone deletes a restaurant, we don't want to just lose that data. This trigger logs who deleted it and when.
CREATE TRIGGER Restaurant.trg_LogDeletion
ON Restaurant.Profiles
AFTER DELETE
AS
BEGIN
    INSERT INTO Analytics.SystemLogs (Action, Details, ActionDate)
    SELECT 'DELETE', 'Restaurant ' + Name + ' was removed', GETDATE()
    FROM deleted; -- "deleted" is another magic table
END;

