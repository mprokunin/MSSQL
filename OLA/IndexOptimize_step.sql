EXECUTE master.dbo.IndexOptimize
@Databases = 'RenHealth_Account.master,
RenHealth_Address.master,
RenHealth_Auth.master,
RenHealth_Legal.master,
RenHealth_LPU.master,
RenHealth_Permissions.master,
RenHealth_Underwriting.master',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y'
,@Indexes = 'ALL_INDEXES'
,@TimeLimit = 7000
,@LogToTable = 'Y'
,@Execute = 'N'
go


