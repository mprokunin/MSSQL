--------------------------------------------------------------------------------------------
ALTER ASSEMBLY [Database_test]
   WITH PERMISSION_SET = UNSAFE;
--------------------------------------------------------------------------------------------



CREATE TABLE Sales
(
      SaleID INT IDENTITY(1,1),
      SaleDate SMALLDATETIME,
      SaleAmount MONEY,
      ItemsSold INT
);
GO

CREATE MESSAGE TYPE [RecordSale] VALIDATION = NONE;
CREATE CONTRACT [SalesContract] 
(
      [RecordSale] SENT BY INITIATOR
); 
GO

CREATE QUEUE [SalesQueue];
CREATE SERVICE [SalesService] ON QUEUE [SalesQueue]([SalesContract]);
GO
CREATE QUEUE [RecordSalesQueue];
CREATE SERVICE [RecordSalesService] ON QUEUE [RecordSalesQueue];
GO


------------- Get message from the queue
create PROCEDURE sp_RecordSaleMessage
AS 
BEGIN
  		  declare @URL varchar(max) 
            SET NOCOUNT ON;
            DECLARE @Handle UNIQUEIDENTIFIER;
            DECLARE @MessageType SYSNAME;
            DECLARE @Message XML
            DECLARE @SaleDate DATETIME 
            DECLARE @SaleAmount MONEY
            DECLARE @ItemsSold INT;

            RECEIVE TOP (1) 
                  @Handle = conversation_handle,
                  @MessageType = message_type_name, 
                  @Message = message_body
            FROM [SalesQueue];
                
            IF(@Handle IS NOT NULL AND @Message IS NOT NULL)
            BEGIN
                  SELECT @SaleDate = CAST(CAST(@Message.query('/Params/SaleDate/text()') AS NVARCHAR(MAX)) AS DATETIME)
                  SELECT @SaleAmount = CAST(CAST(@Message.query('/Params/SaleAmount/text()') AS NVARCHAR(MAX)) AS MONEY)
                  SELECT @ItemsSold = CAST(CAST(@Message.query('/Params/ItemsSold/text()') AS NVARCHAR(MAX)) AS INT)

                  INSERT INTO Sales(SaleDate ,SaleAmount ,ItemsSold )
                  VALUES(@SaleDate,@SaleAmount,@ItemsSold);
				  select @URL= 'http://sps101.ABC.holding/sites/Private/en/Pages/Private_en_index.aspx' + '?Date=' + convert(varchar(30),@SaleDate) + '?Amount=' + convert(varchar(30),@SaleAmount) 
						+ '?Items=' + convert(varchar(30),@ItemsSold)
				  exec sp_GET @URL
            END
END
GO

ALTER QUEUE [SalesQueue] WITH ACTIVATION 
(
      STATUS = ON,
      MAX_QUEUE_READERS = 1,
      PROCEDURE_NAME = sp_RecordSaleMessage,
      EXECUTE AS OWNER
);
GO


------------- Put message into the queue
CREATE PROCEDURE sp_SendSalesInfo
(
      @SaleDate SMALLDATETIME,
      @SaleAmount MONEY, 
      @ItemsSold INT
)
AS
BEGIN
      DECLARE @MessageBody XML
      CREATE TABLE #ProcParams
      (
            SaleDate SMALLDATETIME,
            SaleAmount MONEY,
            ItemsSold INT
      )
      INSERT INTO #ProcParams(SaleDate,SaleAmount, ItemsSold)
      VALUES(@SaleDate, @SaleAmount, @ItemsSold)

      SELECT @MessageBody = (SELECT * FROM #ProcParams FOR XML PATH ('Params'), TYPE);

      DECLARE @Handle UNIQUEIDENTIFIER;
	  
      BEGIN DIALOG CONVERSATION @Handle
      FROM SERVICE [RecordSalesService]
      TO SERVICE 'SalesService'
      ON CONTRACT [SalesContract]
      WITH ENCRYPTION = OFF;
	  
      SEND ON CONVERSATION @Handle 
      MESSAGE TYPE [RecordSale](@MessageBody);
END
GO


--test

select * from Sales
declare @SaleDate datetime = getdate()
exec sp_SendSalesInfo @SaleDate=@SaleDate, @SaleAmount=100, @ItemsSold=6
select * from Sales


declare
      @SaleDate SMALLDATETIME = getdate(),
      @SaleAmount MONEY = '20', 
      @ItemsSold INT = 5,
	  @URL varchar(max)
select @URL= 'http://172.17.6.99:8088/get_test' + '?Date=' + convert(varchar(30),@SaleDate) + '?Amount=' + convert(varchar(30),@SaleAmount) 
					+ '?Items=' + convert(varchar(30),@ItemsSold)

declare	  @URL varchar(max)
select @URL= 'http://intwebsrv01/phonebook/phone_book.aspx' 
exec sp_GET @URL
