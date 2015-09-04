<cfsilent>
	<cfheader name="Expires" value="#GetHttpTimeString(dateAdd('m', 1, now()) )#"> <!--- cache for 1 month --->
	<cfheader name="Cache-Control" value="max-age=2592000"> <!--- cache for 1 month --->
	<cfinclude template="/qry_servers.cfm">
</cfsilent><cfwddx action="cfml2js" input="#qryServers#" toplevelvariable="jsServers">