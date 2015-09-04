<cfset lastMonthDate = dateAdd("m", -1, now())>
<cfset checkDateStart = createDate(year(lastMonthDate), month(lastMonthDate), 1)>

<cfquery name="stats" datasource="wowlemmings" blockfactor="1" cachedWithin="#createTimeSpan(1,0,0,0)#">
	SELECT *
	FROM History
	WHERE EffectiveDate = #CreateODBCDate(checkDateStart)#
	AND 1=1
</cfquery>