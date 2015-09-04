<cfsilent>
	<cfsetting showdebugoutput="false" />
	<cfset rss = request.kathune.GetRSS(argumentCollection=url) />
</cfsilent><cfcontent type="text/xml"><cfoutput>#rss#</cfoutput>