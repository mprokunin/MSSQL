-- https://www.irs.gov/pub/irs-pdf/p5124.pdf
--select @@VERSION
--use [TestDB]
--go
set nocount on
go
select '<?xml version="1.0" encoding="UTF-8"?>
<ftc:FATCA_OECD xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:iso="urn:oecd:ties:isofatcatypes:v1" xmlns:ftc="urn:oecd:ties:fatca:v2" xmlns:stf="urn:oecd:ties:stf:v4" xmlns:sfa="urn:oecd:ties:stffatcatypes:v2" xsi:schemaLocation="urn:oecd:ties:fatca:v2" version="2.0">'
select '  <ftc:MessageSpec>
    <sfa:SendingCompanyIN>' + [ns2:SendingCompanyIN] + '</sfa:SendingCompanyIN>
    <sfa:TransmittingCountry>' + [ns2:TransmittingCountry] + '</sfa:TransmittingCountry>
    <sfa:ReceivingCountry>' + [ns2:ReceivingCountry] + '</sfa:ReceivingCountry>
    <sfa:MessageType>' + [ns2:MessageType] +  '</sfa:MessageType>
    <sfa:MessageRefId>' + [ns2:MessageRefId] + '</sfa:MessageRefId>
    <sfa:ReportingPeriod>' + [ns2:ReportingPeriod] + '</sfa:ReportingPeriod>
    <sfa:Timestamp>' + convert(char(19), [ns2:Timestamp], 127) + '</sfa:Timestamp>
  </ftc:MessageSpec>
'
from [dbo].[header]
go
select '  <ftc:FATCA>
    <ftc:ReportingFI>
      <sfa:ResCountryCode>' + [ns2:ResCountryCode] + '</sfa:ResCountryCode>
      <sfa:TIN/>
      <sfa:Name>Investment Company Freedom Finance limited liability company</sfa:Name>
      <sfa:Address>
        <sfa:CountryCode>' + [ns2:ResCountryCode] + '</sfa:CountryCode>
        <sfa:AddressFix>
          <sfa:Street>' + [ns2:Street] + '</sfa:Street>
          <sfa:BuildingIdentifier>' + [ns2:BuildingIdentifier] + '</sfa:BuildingIdentifier>
          <sfa:SuiteIdentifier/>18.02
          <sfa:DistrictName/>
	      <sfa:PostCode>' + convert(varchar, [ns2:PostCode]) + '</sfa:PostCode>
          <sfa:City>' + [ns2:City] + '</sfa:City>
          <sfa:CountrySubentity>' + [ns2:CountrySubentity] + '</sfa:CountrySubentity>
        </sfa:AddressFix>
        <sfa:AddressFree>' + [ns2:AddressFree] + '</sfa:AddressFree>
      </sfa:Address>
      <ftc:DocSpec>
        <ftc:DocTypeIndic>' + [ns1:DocTypeIndic] + '</ftc:DocTypeIndic>
        <ftc:DocRefId>' + [ns1:DocRefId] + '</ftc:DocRefId>
      </ftc:DocSpec>
    </ftc:ReportingFI>
    <ftc:ReportingGroup>'
from [dbo].[header]
go
/* Pay attention to 
                <sfa:City>' + coalesce([ns2:City15], 'New York') + '</sfa:City>
                <sfa:CountrySubentity>' + coalesce([ns2:CountrySubentity16], 'USA')+ '</sfa:CountrySubentity>
*/
select '      <ftc:AccountReport>
        <ftc:DocSpec>
          <ftc:DocTypeIndic>' + [ns1:DocTypeIndic2] + '</ftc:DocTypeIndic>
          <ftc:DocRefId>' + [ns1:DocRefId3] + '</ftc:DocRefId>
        </ftc:DocSpec>
        <ftc:AccountNumber>' + [ns1:AccountNumber] + '</ftc:AccountNumber>
        <ftc:AccountClosed/>
        <ftc:AccountHolder>
          <ftc:Individual>
            <sfa:ResCountryCode>' + [ns2:ResCountryCode4] + '</sfa:ResCountryCode>
            <sfa:TIN>' + [ns2:TIN5] + '</sfa:TIN>
            <sfa:Name>
              <sfa:FirstName>' + rtrim(ltrim([ns2:FirstName6])) + '</sfa:FirstName>
' +
case when [ns2:MiddleName7] is null then
'              <sfa:MiddleName/>
'
else
'              <sfa:MiddleName>' + rtrim(ltrim([ns2:MiddleName7])) + '</sfa:MiddleName>
'
end +
'              <sfa:LastName>' + rtrim(ltrim([ns2:LastName8])) + '</sfa:LastName>
            </sfa:Name>
            <sfa:Address>
              <sfa:CountryCode>' + [ns2:CountryCode9] + '</sfa:CountryCode>
              <sfa:AddressFix>
' +
case when [ns2:Street10] is null then
''
else
'                <sfa:Street>' + [ns2:Street10] + '</sfa:Street>
' 
end +
case when [ns2:BuildingIdentifier11] is null then 
''
else
'                <sfa:BuildingIdentifier>' + coalesce(convert(varchar, [ns2:BuildingIdentifier11]), '') + '</sfa:BuildingIdentifier>
'
end +
case when [ns2:SuiteIdentifier12] is null then
''
else 
'                <sfa:SuiteIdentifier>' + convert(varchar, [ns2:SuiteIdentifier12]) + '</sfa:SuiteIdentifier>
'
end +
case when [ns2:DistrictName13] is null then
''
else 
'                <sfa:DistrictName>' + convert(varchar, [ns2:DistrictName13]) + '</sfa:DistrictName>
'
end +
case when [ns2:PostCode14] is null then
''
else 
'                <sfa:PostCode>' + convert(varchar, [ns2:PostCode14]) + '</sfa:PostCode>
' 
end + 
'                <sfa:City>' + coalesce([ns2:City15], 'New York') + '</sfa:City>
                <sfa:CountrySubentity>' + coalesce([ns2:CountrySubentity16], 'USA')+ '</sfa:CountrySubentity>
              </sfa:AddressFix>
' +
case when [ns2:AddressFree17] is not null then
'              <sfa:AddressFree>' + [ns2:AddressFree17] + '</sfa:AddressFree>
'
else ''
end +
'            </sfa:Address>
            <sfa:BirthInfo>
              <sfa:BirthDate>' + convert(varchar, convert(date, [ns2:BirthDate], 23)) + '</sfa:BirthDate>
              <sfa:City>' + [ns2:City18] + '</sfa:City>
            </sfa:BirthInfo>
          </ftc:Individual>
        </ftc:AccountHolder>
        <ftc:AccountBalance currCode="'+ [currCode] + '">' + format([ns1:AccountBalance], 'F2', 'de-DE') + '</ftc:AccountBalance>
        <ftc:Payment>
          <ftc:Type>' + coalesce([ns1:Type], 'FATCA501') + '</ftc:Type>
          <ftc:PaymentAmnt currCode="' + coalesce([currCode19], 'USD') + '">' + format(coalesce([ns1:PaymentAmnt], 0.00), 'F2', 'de-DE') + '</ftc:PaymentAmnt>
        </ftc:Payment>
' +
case 
when [ns1:Type1] is not null and [currCode191] is not null and [ns1:PaymentAmnt1] is not null then
'        <ftc:Payment>
          <ftc:Type>' + [ns1:Type1] + '</ftc:Type>
          <ftc:PaymentAmnt currCode="' + [currCode191] + '">' + format([ns1:PaymentAmnt1], 'F2', 'de-DE') + '</ftc:PaymentAmnt>
        </ftc:Payment>
'
else ''
end +
'      </ftc:AccountReport>
'
from [dbo].[clients]

select '    </ftc:ReportingGroup>
  </ftc:FATCA>
</ftc:FATCA_OECD>'
go

