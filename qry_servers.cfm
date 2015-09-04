<cfsilent>
<cfquery name="qryServers" datasource="wowlemmings" cachedwithin="#createTimeSpan(30,0,0,0)#">
	SELECT ServerName, LTRIM(RTRIM(ServerType)) AS ServerType, LTRIM(RTRIM(Region)) As Region
	FROM Servers
	ORDER BY ServerName
</cfquery>
</cfsilent>