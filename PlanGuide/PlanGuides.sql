SELECT * FROM sys.plan_guides
EXEC sp_control_plan_guide N'ENABLE', N'TemplateGuide1'
EXEC sp_control_plan_guide N'DROP', N'TestTemplate'
GO