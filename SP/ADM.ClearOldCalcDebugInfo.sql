USE [AUTO]
GO

/****** Object:  StoredProcedure [dbo].[ADM.ClearOldCalcDebugInfo]    Script Date: 7/27/2020 5:09:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================  
-- Author:  Igor Cvetkov  
-- Create date: 22.09.2014  
-- Description: Procedure created for job. Clear calculation debug information for old policies 
-- M. Prokunin added @@rowcount at June 28, 2020
-- M. Prokunin added @maxcnt at July 27, 2020
-- =============================================  
ALTER PROCEDURE [dbo].[ADM.ClearOldCalcDebugInfo] (
@maxcnt int = 200
)
AS  
BEGIN  
set rowcount 10000  
declare @cnt int =0
while (1=1) and (@cnt < @maxcnt)
begin
	select @cnt += 1
    DELETE PolicyCalcDebugInfo  
      WHERE policyID IN( SELECT p.policyID  
                           FROM  
                                policies p WITH (nolock)   
        INNER JOIN PolicyCalcDebugInfo info WITH (nolock) ON info.policyID = p.policyID  
        INNER JOIN programs pr WITH (nolock) ON p.programID = pr.ProgramID  
                                INNER JOIN SystemProductTypes t WITH (nolock) ON t.ID = pr.SystemProductType  
                           WHERE   
        t.Name IN('B2BSetChangesCore2' , 'B2BSfaCore2' , 'B2BSfaProlongationCore2Automatic' , 'B2BSfaProlongationCore2NonAutomatic')  
        AND p.status NOT IN( 'signed' , 'invalid' , 'annul')  
        AND lasteditdate < DATEADD( MONTH , -3 , CONVERT( date , GETDATE()))  
                       );  
	if @@rowcount <= 0 break;
end
END;  


GO


