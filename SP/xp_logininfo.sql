xp_logininfo [ [ @acctname = ] 'account_name' ] 
[ , [ @option = ] 'all' | 'members' ] 
[ , [ @privilege = ] variable_name OUTPUT]

exec xp_logininfo @acctname = 'DOMAIN\Front_analytics_Access_RA', @option = 'members'


