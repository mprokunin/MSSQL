-- Good
USE tempdb
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('yourTable') IS NOT NULL DROP TABLE yourTable
CREATE TABLE yourTable
(
	blah		VARCHAR(20) DEFAULT 'blah',
	columname	BINARY(8)
)
GO

INSERT INTO yourTable ( columname ) VALUES ( RAND() )
GO 10000

INSERT INTO yourTable ( columname ) VALUES ( 0x0000000000008A27 )
GO

EXEC sp_create_plan_guide 
	@name = N'yourGuide1', 
	@stmt = N'/* some comment */ SELECT * FROM yourTable WHERE columname = @1',
	@type = N'SQL',
	@module_or_batch = NULL,
	@params = '@1 BINARY(8)', 
	@hints = N'OPTION (RECOMPILE)';
GO


-- These won't match
/* some comment */ SELECT * FROM yourTable WHERE columname = 0x0000000000008A27
EXEC sp_executesql N'/* some comment */ SELECT * FROM yourTable WHERE columname = 0x0000000000008A27'
GO

-- These will
DECLARE @1 BINARY(8) = 0x0000000000008A27
EXEC sp_executesql N'/* some comment */ SELECT * FROM yourTable WHERE columname = @1', N'@1 BINARY(8)', @1
GO

-- External parameter name is different; will still match
DECLARE @2 BINARY(8) = 0x0000000000008A27
EXEC sp_executesql N'/* some comment */ SELECT * FROM yourTable WHERE columname = @1', N'@1 BINARY(8)', @2
GO

EXEC sp_control_plan_guide @operation = 'DROP', @name = N'yourGuide1'
GO


SELECT * FROM sys.plan_guides
EXEC sp_control_plan_guide N'DROP', N'TemplateGuide1'
--EXEC sp_control_plan_guide N'ENABLE', N'Guide1'