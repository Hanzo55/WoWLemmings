<cfparam name="fac" default="">
<cfparam name="serv" default="">
<cfparam name="clas" default="">
<cfparam name="regi" default="">
<cfparam name="idiotFilter" default="0">
<cfparam name="maxrows" default="50">
<cfparam name="page" default="1">
<cfparam name="keyword" default="">

<cfquery name="total" datasource="wowlemmings" blockfactor="#maxrows#" cachedWithin="#createTimeSpan(0,0,30,0)#">  <!--- it's cached based on the timer of the repopulation schedule --->
  SELECT Count(PostID) as records
   FROM 
     Links
		WHERE 0=0
	<cfif fac is "a">
		AND isAlliance = 1
	<cfelseif fac is "h">
		AND isHorde = 1
	</cfif>
	<cfif serv is "pvp">
		AND isPvP = 1
	<cfelseif serv is "pve">
		AND isPvE = 1
	</cfif>
	<cfif clas is "rogu">
		AND isRogue = 1
	<cfelseif clas is "deth">
		AND isDeathKnight = 1
	<cfelseif clas is "demo">
		AND isDemonHunter = 1
	<cfelseif clas is "drui">
		AND isDruid = 1
	<cfelseif clas is "mage">
		AND isMage = 1
	<cfelseif clas is "monk">
		AND isMonk = 1
	<cfelseif clas is "warr">
		AND isWarrior = 1
	<cfelseif clas is "warl">
		AND isWarlock = 1
	<cfelseif clas is "hunt">
		AND isHunter = 1
	<cfelseif clas is "sham">
		AND isShaman = 1
	<cfelseif clas is "pala">
		AND isPaladin = 1
	<cfelseif clas is "prie">
		AND isPriest = 1
	</cfif>
	<cfif idiotFilter eq 1>
		AND isIdiot = 0
	</cfif>	
	<cfif regi is "us">
		AND Region = 'US'
	<cfelseif regi is "eu-en">
		AND Region = 'EU-EN'
	</cfif>
	<cfif len(trim(keyword))>
		AND (PostTitle ILIKE '%#trim(keyword)#%' OR to_tsvector('english', PostBody) @@ to_tsquery('english','#trim(keyword)#'))
	</cfif>
		AND 1=1
</cfquery>

<cfquery name="qryResults" datasource="wowlemmings" blockfactor="#maxrows#" cachedWithin="#createTimeSpan(0,0,30,0)#">
WITH LinksBlock AS
(
    SELECT ROW_NUMBER() OVER(ORDER BY EffectiveDate DESC, PostID) AS RowNum, *
    FROM Links
	WHERE 0=0
	<cfif fac is "a">
		AND isAlliance = 1
	<cfelseif fac is "h">
		AND isHorde = 1
	</cfif>
	<cfif serv is "pvp">
		AND isPvP = 1
	<cfelseif serv is "pve">
		AND isPvE = 1
	</cfif>
	<cfif clas is "rogu">
		AND isRogue = 1
	<cfelseif clas is "deth">
		AND isDeathKnight = 1
	<cfelseif clas is "demo">
		AND isDemonHunter = 1
	<cfelseif clas is "drui">
		AND isDruid = 1
	<cfelseif clas is "mage">
		AND isMage = 1
	<cfelseif clas is "monk">
		AND isMonk = 1
	<cfelseif clas is "warr">
		AND isWarrior = 1
	<cfelseif clas is "warl">
		AND isWarlock = 1
	<cfelseif clas is "hunt">
		AND isHunter = 1
	<cfelseif clas is "sham">
		AND isShaman = 1
	<cfelseif clas is "pala">
		AND isPaladin = 1
	<cfelseif clas is "prie">
		AND isPriest = 1
	</cfif>
	<cfif idiotFilter eq 1>
		AND isIdiot = 0
	</cfif>	
	<cfif regi is "us">
		AND Region = 'US'
	<cfelseif regi is "eu-en">
		AND Region = 'EU-EN'
	</cfif>
	<cfif len(trim(keyword))>
		AND (PostTitle ILIKE '%#trim(keyword)#%' OR to_tsvector('english', PostBody) @@ to_tsquery('english','#trim(keyword)#'))
	</cfif>
	AND 1=1
)

SELECT * 
FROM LinksBlock
WHERE RowNum 
BETWEEN (#page# - 1) * #maxrows# + 1 
AND #page# * #maxrows#
ORDER BY EffectiveDate DESC
</cfquery>

