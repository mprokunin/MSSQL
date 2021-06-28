-- Batch submitted through debugger: SQLQuery1.sql|0|0|C:\Users\zaitsev\AppData\Local\Temp\3\~vs93E7.sql  
  
CREATE proc [dbo].[MainSync]  
AS  
Begin  
--синхронизация справочников  
  
exec dbo.SyncCPU  
  
exec dbo.SyncNIC  
  
exec dbo.SyncOS  
  
exec dbo.SyncVideo  
  
exec dbo.SyncUpdates  
  
-- обновляем таблицу SCCMSync  
delete from dbo.SCCMSync  
  
insert into dbo.SCCMSync  
select distinct  
cs.Name0,                                    
cs.Model0,  
sd.User_Name0,--cs.UserName0,  
os.Caption0 + ' ' +os.CSDVersion0 as OS,                                   
dd.Size0/1024 as Size,  
TotalPhysicalMemory0/1024 as TotalPhysicalMemory,  
vd.Description00,  
cd.Description00,  
pd.Name0,  
nd.DefaultIPGAteway0,  
nd.IPAddress0,  
nd.IPSubnet0,  
nd.MACAddress0,  
ncd.ProductName0  
 from [SQLit01].SMS_001.dbo.Computer_System_DATA cs  
 left join [SQLit01].SMS_001.dbo.System_DISC sd on (cs.Name0 = sd.Name0)  
left join [SQLit01].SMS_001.dbo.Operating_System_DATA os on (cs.MachineID = os.MachineID)  
--inner join Disk_DATA dd on (dd.MachineId = os.MachineId)  
left join  
(select SystemName0, sum(Size0) Size0 from [SQLit01].SMS_001.dbo.Disk_DATA   
group by SystemName0) dd on  (cs.Name0 = dd.SystemName0)  
left join [SQLit01].SMS_001.dbo.Video_Controller_DATA vd on (cs.MachineID = vd.MachineId)  
left join [SQLit01].SMS_001.dbo.CD_ROM_DATA cd on  (cs.MachineID = cd.MachineID)  
left join [SQLit01].SMS_001.dbo.Processor_DATA pd on (cs.MachineID = pd.MachineID)  
left join [SQLit01].SMS_001.dbo.Network_DATA nd on (cs.MachineID = nd.MachineID)  
left join [SQLit01].SMS_001.dbo.Netcard_DATA ncd on (cs.MachineID = ncd.MachineID)  
left join [SQLit01].SMS_001.dbo.PC_Memory_DATA md on (cs.MachineID = md.MachineID)  
where   
os.Caption0 not like '%server%'  
and  
vd.Description00 NOT LIKE '%DameWare%' and   
vd.Description00 NOT LIKE '%ConfigMgr%'and  
vd.Description00 NOT LIKE '%Microsoft%' and  
vd.Description00 NOT LIKE '%VMWare%' and  
vd.Description00 NOT LIKE '%Mirage%'  
and nd.IPAddress0 IS NOT NULL  
and nd.IPSubnet0 IS NOT NULL  
and ncd.Description0 not like '%miniport%'  
and ncd.Manufacturer0 NOT LIKE '%Microsoft%'  
and ncd.Manufacturer0 NOT LIKE '%VMWare%'  
and ncd.Manufacturer0 NOT LIKE '%Symantec%'  
and ncd.Manufacturer0 NOT LIKE '%Win32%'  
  
  
--удаляем дубликаты  
delete from dbo.SCCMSync where rowid in  
(  
select rowid from dbo.SCCMSync s1  
where s1.rowid NOT IN ( select min(rowid) from dbo.SCCMSync s2   
where s1.HostName = s2.HostName  )  
)  
  
-- синхронизация рабочих станций  
  
declare @HostName [varchar](100),  
 @Model [varchar](100),  
 @UserName [varchar](100),  
 @OS [varchar](100),  
 @hdd [int],  
 @RAM [int],  
 @Video [varchar](100),  
 @CD [varchar](100),  
 @CPU [varchar](100),  
 @Gateway [varchar](100),  
 @IPAddress [varchar](100),  
 @IPSubnet [varchar](100),  
 @MACAddress [varchar](100),  
 @NIC [varchar](100),  
 @cpuid int,   
 @videoid int,   
 @osid int,   
 @userid int,  
    @nicid int,  
    @cdid bit,  
 @WorkstationID int,  
    @DEviceId int,  
 @VLANId int  
  
  
  
  
  
  
declare @t table  
(  
cpuid int,   
videoid int,   
osid int,   
userid int,  
nicid int  
)  
  
  
declare WS cursor for  
  
select  HostName,Model,UserName,OS,hdd,RAM,Video,CD,CPU,Gateway,IPAddress,IPSubnet,MACAddress,NIC  
 from SCCMSync  
  
open WS   
  
  
fetch next from WS  
into @HostName,@Model,@UserName,@OS,@hdd,@RAM,@Video,@CD,@CPU,@Gateway,@IPAddress,@IPSubnet,@MACAddress,@NIC  
  
  
while @@FETCH_STATUS = 0  
begin  
  
----  
---- проверяем есть ли уже рабочая станция с таким именем  
 IF NOT EXISTS(select 1 from tblWorkstation where Hostname = @Hostname)  
BEGIN  
-- если нет, то добавляем  
-- но сначала вызываем процедуру для получения значений цпу, видео, ось, юзер  
  
insert into @t  
exec GetWSValues @CPU,@Video,@OS,@UserName,@NIC  
  
select  @cpuid = cpuid  from @t    
select  @videoid = videoid   from @t    
select  @osid = osid from @t   
select  @userid = userid  from @t   
select  @nicid = nicid  from @t   
--  
--  
--select  @cpuid , @videoid ,@osid , @userid ,  @nicid     
----определяем наличие CDROM  
  IF @CD IS NULL   
    set @cdid = 0  
ELSE   
 set @cdid = 1  
  
---print @Hostname + ' '+ convert(varchar,@hdd)+ ' '+ convert(varchar,@RAM)+ ' '+ convert(varchar,@cpuid)+ ' '+ convert(varchar,@cdid)+ ' '+ convert(varchar,@videoid)+ ' '+ convert(varchar,@osid) + ' '+ convert(varchar,@userid)  
----добалвяем рабочую станцию  
exec spWorkstationAdd @Hostname=@Hostname, @WarrantyInfo=null, @Inventory=null,  
@FormFactor=null, @HDD=@hdd, @RAM=@RAM, @CPUID=@cpuid, @CDROM=@cdid, @RoomID=null, @VideoID=@videoid,  
 @OSID=@osid, @UserID=@userid, @isConfigured=0, @USB=0, @EquipmentID=null,  
 @AccountNumber=null, @DeviceComment=null, @BuyDate=null, @InvoiceNumber=null,  
@InvoiceDate=null, @SerialNumber=null, @WarrantyContactInfo=null, @Model = @Model  
--  
---- для того чтобы добавить сведения о сетевых интерфейчас - определяем deviceid, vlan, nicid  
--  
select @WorkstationID = WorkstationID from tblWorkStation where Hostname = @HostName  
  
select @DEviceId = DEviceId from tblDevice where ExtID = @WorkstationID  
  
select @VLANId = VLANID from tblVLAN where SubNetMask = @IPSubnet and DefaultGateway = @Gateway  
--  
----добавляем данные по сетевым интерфейсам  
--  
exec spDeviceInterfaceAdd @DeviceID=@DEviceId, @VLANID=@VLANId, @Ipaddress=@IPAddress,  
 @CommentIPPlan='', @FWNat='', @FWComment='', @FWStatus='', @DHCPStatus='',  
 @DHCPInfo='', @MACAddress= @MACAddress, @BalanceType='', @DomainName='',  
 @UserNames=null, @DeviceZone='', @InterfaceSpeed='', @InterfaceType='',  
 @NICID=@nicid, @NicSerial='', @NicComment=null, @DNS='', @InDeviceInterfaceID=null,  
 @OutDeviceInterfaceID=null, @SocketID=null, @Unit=null, @Port=null, @Comment=null,  
 @interfaceName=null, @interfaceStatus=null, @SubNetMask=null  
end  
else  
begin  
  
  
--select @WorkstationID = WorkstationID from tblWorkStation where Hostname = @HostName  
  
--select @DEviceId = DEviceId from tblDevice where ExtID = @WorkstationID  
  
--select @VLANId = VLANID from tblVLAN where SubNetMask = @IPSubnet and DefaultGateway = @Gateway  
----  
------добавляем данные по сетевым интерфейсам  
----  
--exec spDeviceInterfaceAdd @DeviceID=@DEviceId, @VLANID=@VLANId, @Ipaddress=@IPAddress,  
-- @CommentIPPlan='', @FWNat='', @FWComment='', @FWStatus='', @DHCPStatus='',  
-- @DHCPInfo='', @MACAddress= @MACAddress, @BalanceType='', @DomainName='',  
-- @UserNames=null, @DeviceZone='', @InterfaceSpeed='', @InterfaceType='',  
-- @NICID=@nicid, @NicSerial='', @NicComment=null, @DNS='', @InDeviceInterfaceID=null,  
-- @OutDeviceInterfaceID=null, @SocketID=null, @Unit=null, @Port=null, @Comment=null,  
-- @interfaceName=null, @interfaceStatus=null, @SubNetMask=null  
   
--вызываем процедуру синхронизации для каждой рабочей станции  
-- exec Sync_SCCM  
--   
exec Sync_SCCM @HostName,@Model,@UserName,@OS,@hdd,@RAM,@Video,@CD,@CPU,@Gateway,@IPAddress,@IPSubnet,@MACAddress,@NIC  
  
  
  
end  
  
-- добавление апдейтов для рабочей станции  
--exec [dbo].[SyncWorkstationUpdates] @Hostname  
  
  
fetch next from WS  
into @HostName,@Model,@UserName,@OS,@hdd,@RAM,@Video,@CD,@CPU,@Gateway,@IPAddress,@IPSubnet,@MACAddress,@NIC  
  
END  
   
  
close WS  
deallocate WS  
  
end  
  
  
  
--select * from serverpass.dbo.SCCMSync  
--  
--select * from tblVLAN  
  
--select  * from dbo.tblWorkstation  
  
  
  
--exec spWorkstationAdd @Hostname=X, @WarrantyInfo=null, @Inventory=null,  
--@FormFactor=null, @HDD=X, @RAM=X, @CPUID=?, @CDROM=X, @RoomID=null, @VideoID=?,  
-- @OSID=?, @UserID=?, @isConfigured=0, @USB=0, @EquipmentID=null,  
-- @AccountNumber=null, @DeviceComment=null, @BuyDate=null, @InvoiceNumber=null,  
-- @InvoiceDate=null, @SerialNumber=null, @WarrantyContactInfo=null  
--  
--  
--cpuid, videoid, osid, userid;  
  
  
--exec spDeviceInterfaceAdd @DeviceID=1679, @VLANID=52, @Ipaddress='1.1.1.1',  
-- @CommentIPPlan='', @FWNat='', @FWComment='', @FWStatus='', @DHCPStatus='',  
-- @DHCPInfo='', @MACAddress='11-11-11-11-11-11', @BalanceType='', @DomainName='',  
-- @UserNames=null, @DeviceZone='', @InterfaceSpeed='', @InterfaceType='',  
-- @NICID=7, @NicSerial='', @NicComment=null, @DNS='', @InDeviceInterfaceID=null,  
-- @OutDeviceInterfaceID=null, @SocketID=null, @Unit=null, @Port=null, @Comment=null,  
-- @interfaceName=null, @interfaceStatus=null, @SubNetMask=null  
  
  
  
--exec spWorkstationAdd @Hostname='ACCSYS02', @WarrantyInfo=null, @Inventory=null,  
--@FormFactor=null, @HDD=149, @RAM=2023, @CPUID=80, @CDROM=0, @RoomID=null, @VideoID=103,  
-- @OSID=55, @UserID=312, @isConfigured=0, @USB=0, @EquipmentID=null,  
-- @AccountNumber=null, @DeviceComment=null, @BuyDate=null, @InvoiceNumber=null,  
--@InvoiceDate=null, @SerialNumber=null, @WarrantyContactInfo=null, @Model = 'sd'  