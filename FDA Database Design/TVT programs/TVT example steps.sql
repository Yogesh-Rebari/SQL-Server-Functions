--A user places an order.
--Step 1: The Automated Trigger
--First, we create a trigger. Its job is to watch the Order.Transactions table. 
--Every time a new order is successfully saved, it automatically logs a system event.
CREATE TRIGGER [Order].trg_AfterOrderPlaced
ON [Order].Transactions
AFTER INSERT -- Triggers automatically after a successful INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- "inserted" is a special SQL table that holds the row that was just added
    INSERT INTO Analytics.SystemLogs (Action, Details, ActionDate)
    SELECT 'NEW_ORDER', 'Order #' + CAST(OrderID AS VARCHAR) + ' placed by UserID ' + CAST(UserID AS VARCHAR), GETDATE()
    FROM inserted;
END;
GO

--Step 2: The Stored Procedure with Transaction
--Now, we write the procedure to handle the order placement. This uses a Transaction to protect the money.
CREATE PROCEDURE [Order].PlaceSecureOrder
    @UserID INT,
    @RestaurantID INT,
    @OrderAmount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Start the Transaction "Safety Net"
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Deduct money from User Wallet
        UPDATE Users.UserWallets
        SET Balance = Balance - @OrderAmount
        WHERE UserID = @UserID;

        -- CHECK: If balance becomes negative, throw an error to trigger a rollback
        IF (SELECT Balance FROM Users.UserWallets WHERE UserID = @UserID) < 0
        BEGIN
            RAISERROR('Insufficient funds in wallet.', 16, 1);
        END

        -- 2. Create the Order (This will trigger Step 1 automatically)
        INSERT INTO [Order].Transactions (UserID, RestaurantID, Status, TotalAmount, OrderTime)
        VALUES (@UserID, @RestaurantID, 'Placed', @OrderAmount, GETDATE());

        -- 3. If we reached here, both steps succeeded. Save permanently.
        COMMIT TRANSACTION;
        PRINT 'Order Placed Successfully and Logged by Trigger.';

    END TRY
    BEGIN CATCH
        -- 4. If ANY step failed, UNDO everything. Wallet money returns, Order is NOT created.
        ROLLBACK TRANSACTION;
        
        PRINT 'ERROR: Order failed. Transaction rolled back.';
        PRINT 'Message: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--Step 3: The View (The Reporting Window)
--create a View to check our results easily without writing long joins.
CREATE VIEW Analytics.vw_OrderAuditTrail AS
SELECT 
    L.LogID,
    L.Action,
    L.Details,
    U.Name AS UserName,
    O.TotalAmount,
    L.ActionDate
FROM Analytics.SystemLogs L
JOIN [Order].Transactions O ON L.Details LIKE '%' + CAST(O.OrderID AS VARCHAR) + '%'
JOIN Users.Profiles U ON O.UserID = U.UserID;
GO

-- This will run the Transaction, which (if successful) will fire the Trigger
EXEC [Order].PlaceSecureOrder @UserID = 1, @RestaurantID = 5, @OrderAmount = 450.00;

-- Now check the View to see the automated results
SELECT * FROM Analytics.vw_OrderAuditTrail;