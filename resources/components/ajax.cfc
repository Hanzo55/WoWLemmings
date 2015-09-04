<cfcomponent displayname="ajax" hint="ajax wrapper for cf" output="false">
	
	<cffunction name="getServers" access="remote" returnFormat="json" output="false">
		<cfargument name="domain" type="string" required="true" />
		
		<cfquery name="qryServers" datasource="wowlemmings" cachedwithin="#createTimeSpan(0,8,0,0)#">
			SELECT ServerName, ServerRegExp, LTRIM(RTRIM(ServerType)) AS ServerType
			FROM Servers
			WHERE Region = <cfif arguments.domain is 'US'>'US'<cfelse>'EU-EN'</cfif>
			ORDER BY ServerName
		</cfquery>
		
		<cfreturn qryServers />	
	</cffunction>

</cfcomponent>