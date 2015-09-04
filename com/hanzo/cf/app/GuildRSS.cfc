<cfcomponent output="false">

	<!--- ** INIT ** --->

	<cffunction name="init" returntype="com.hanzo.cf.app.GuildRSS" access="public" output="false">
		<cfargument name="xmlPath" type="string" required="true" />

		<cfscript>
			// declare local temp variables
			var xmlObj 					= 0;
			var config 					= 0;
			var configFile				= 0;
			var data					= StructNew();
			var player					= 0;
			var realmstring				= '';
			var namestring				= '';
			var	current_count			= 1;

			// declare persistent vars for the lifetime of the app
			variables.rsscolumnlist		= 'AUTHOREMAIL,AUTHORNAME,AUTHORURI,CATEGORYLABEL,CATEGORYSCHEME,CATEGORYTERM,COMMENTS,CONTENT,CONTENTTYPE,CONTRIBUTOREMAIL,CONTRIBUTORNAME,CONTRIBUTORURI,CREATEDDATE,EXPIRATIONDATE,ID,IDPERMALINK,LINKHREF,LINKTYPE,PUBLISHEDDATE,RIGHTS,RSSLINK,SOURCE,SOURCEURL,SUMMARY,SUMMARYMODE,SUMMARYSRC,SUMMARYTYPE,TITLE,TITLETYPE,UPDATEDDATE,URI,XMLBASE,RSSUPDATEDDATE';
			//variables.wowarmory 		= CreateObject('component','com.hanzo.cf.wow.ArmoryGateway');
			variables.wowarmory			= CreateObject('component','com.blizzard.services.wow').init(cache=application.cache);
			variables.rss_queue			= CreateObject('component','com.hanzo.cf.stl.Queue');
			variables.twit_queue		= CreateObject('component','com.hanzo.cf.stl.Queue');

			// for efficiency regarding locking, this var is blind inserted to, and may include dupes.
			variables.guildrss_temp		= QueryNew(variables.rsscolumnlist);
			
			// this is the legitimate rss cache that is queried when RSS is requested. it containes no duplicates.
			variables.guildrss_cache	= QueryNew(variables.rsscolumnlist);
		</cfscript>

		<!--- read config, convert to xml object --->		
		<cffile action="read" file="#expandPath(arguments.xmlPath)#" variable="configFile" />

		<cfset xmlObj = XmlParse(configFile)>
		
		<!--- setup xpath arrays --->
		<cfset config = XmlSearch(xmlObj, '/config') />

		<!--- init local variables scope with app settings --->
		<cfloop array="#config[1].XmlChildren#" index="thisConfigVar">
			<cfset variables['#thisConfigVar.XmlName#'] = thisConfigVar.XmlText />
		</cfloop>
		
		<cflog file="GuildRSS" type="information" text="init() - Setting loaded from config.xml into memory." />
		
		<!--- initalize/cache guild rss feed queue --->
		<cfset variables.wowarmory.SetRegion( variables.locale ) />
		
		<cftry>
			<cfset data = variables.wowarmory.GetPlayersInGuild( variables.guild, variables.server, variables.maxRank ) />
			<cfcatch type="any"></cfcatch>
		</cftry>
		
		<cfif NOT StructIsEmpty(data)>
		
			<cfloop collection="#data#" item="player">
				
				<cfset realmstring 	= ListAppend(realmstring, variables.server) />
				<cfset namestring 	= ListAppend(namestring, URLEncodedFormat(player) ) />
			
				<cfset current_count++ />
			
				<cfif current_count GT variables.namesPerFeed>
					
					<cfset variables.rss_queue.push( variables.wowarmory.GetArmoryURL() & '/character-feed.atom?r=' & realmstring & '&cn=' & namestring & '&locale=en_US' ) />
				
					<cfset realmstring 		= '' />
					<cfset namestring 		= '' />
					<cfset current_count 	= 1 />
					
				</cfif>
			
			</cfloop>
		
		<cfelse>
			<cfthrow type="GuildRSS.InitFailure" message="Unable to retrieve guild player listing" detail="During the init process, the application made an attempt to retrieve a listing of players in the guild #variables.guild# on the server #variables.server# (locale: #variables.locale#), but was unable to complete the request." />
		</cfif>
		
		<cflog file="GuildRSS" type="information" text="init() - Loaded #variables.rss_queue.size()# RSS feeds into memory." />
		
		<cfreturn this />
	</cffunction>

	<!--- ** PUBLIC METHODS ** --->

	<cffunction name="process" returntype="void" access="public" output="false">

		<cfset var i = 0 />
		<cfset var nextFeed = 0 />
		<cfset var threadNames = '' />

		<cfloop from="1" to="#variables.maxThreads#" index="i">
			
			<!--- grab the next feed --->
			<cfset nextFeed = variables.rss_queue.front() />
			
			<cflog file="GuildRSS" type="information" text="process() - Grabbing next RSS feed from queue: #nextFeed#" />			

			<!--- remove it --->
			<cfset variables.rss_queue.pop() />
			
			<!--- add it back to the end --->
			<cfset variables.rss_queue.push( nextFeed ) />

			<cfset threadNames = ListAppend(threadNames, '__Feed_thread_' & i ) />

			<!--- process it --->
			<cfthread name="__Feed_thread_#i#"
					index="#i#"
					feed="#nextFeed#"
					action="run">
						
				<cflog file="GuildRSS" type="information" text="process() - Spawning ProcessFeed() via thread __Feed_thread_#attributes.index#" />
						
				<cfset ProcessFeed( attributes.feed ) />
				
			</cfthread>
			
		</cfloop>
		
		<cfthread action="join" name="#threadNames#" timeout="#Evaluate(variables.threadTimeout * 1000)#" />
		
		<cfset UpdateAllFeeds() />
		
		<cfset DeleteOutdatedFeeds() />
	</cffunction>

	<cffunction name="twit" returntype="void" access="public" output="false">
	
		<cfset UpdateTwitQueue() />
	</cffunction>

	<cffunction name="rss" returntype="xml" access="public" output="false">

		<cfset var guildRSSData 	= 0 />
		<cfset var prop 			= StructNew() />
		<cfset var getEvents		= GetRecentEvents( variables.maxElements ) />
		
		<cfset prop.title = variables.feedName />
		<cfset prop.link = variables.feedURL />
		<cfset prop.description = variables.feedDescription />
		<cfset prop.version = "rss_2.0" />

		<cffeed action="create"
				properties="#prop#"
				query="#getEvents#"
				xmlvar="guildRSSData" />
		
		<cfreturn guildRSSData />
	</cffunction>

	<cffunction name="dumpall" returntype="void" access="public" output="true">
	
		<cfdump var=#this# />
		<cfdump var=#variables# />
		<cfoutput>#variables.rss_queue.dump()#</cfoutput>
		<cfoutput>#variables.twit_queue.dump()#</cfoutput>
		<cfabort />
	</cffunction>

	<!--- ** PRIVATE METHODS ** --->

	<cffunction name="ProcessFeed" returntype="void" access="private" output="false">
		<cfargument name="feedURL" type="string" required="true" />

		<cfset var rssQuery = 0 />
		<cfset var thisColumn = 0 />
		<cfset var event = 0 />
		<cfset var lastRow = 0 />

		<cflog file="GuildRSS" type="information" text="ProcessFeed() - Processing #arguments.feedURL#" />

		<cftry>

			<cffeed action="read"
					source="#arguments.feedURL#"
					query="rssQuery" />

			<cflock type="exclusive" name="cacheWrite" timeout="#Round(Evaluate(variables.threadTimeout / variables.maxThreads))#">
	
				<cfloop query="rssQuery">
		
					<cfset lastRow = QueryAddRow( variables.guildrss_temp ) />
				
					<cfloop list="#ListDeleteAt(variables.rsscolumnlist,ListLen(variables.rsscolumnlist))#" index="thisColumn">
						
						<cfif thisColumn is 'CONTENT'>
							
							<cfset QuerySetCell( variables.guildrss_temp, thisColumn, Replace( rssQuery[thisColumn][rssQuery.CurrentRow], '"/character-sheet.xml', '"' & variables.wowarmory.GetArmoryURL() & '/character-sheet.xml', 'ONE' ), lastRow ) />
						
						<cfelse>
						
							<cfset QuerySetCell( variables.guildrss_temp, thisColumn, rssQuery[thisColumn][rssQuery.CurrentRow], lastRow ) />
						
						</cfif>
						
					</cfloop>
					
					<cfset QuerySetCell( variables.guildrss_temp, 'RSSUPDATEDDATE', ExtractDateFromZulian(rssQuery['UPDATEDDATE'][rssQuery.CurrentRow]), lastRow ) />
						
				</cfloop>
			
			</cflock>
			
			<cfcatch type="any">
				<cflog file="GuildRSS" type="warning" text="ProcessFeed() - Unable to process: #arguments.feedURL#" />
				<cflog file="GuildRSS-Err" type="error" text="#CFCATCH.Message#: #CFCATCH.Detail#" />
				<cflog file="GuildRSS-Err" type="error" text="rssQuery records: #rssQuery.RecordCount#, rssQuery current record: #rssQuery.CurrentRow#, rssQuery column: #thisColumn#, rssQuery column total: #ListLen(rssQuery.ColumnList)#" />
				<cflog file="GuildRSS-Err" type="error" text="variables.guildrss_temp ColumnList: #variables.guildrss_temp.ColumnList# (#ListLen(variables.guildrss_temp.ColumnList)# columns)" />
			</cfcatch>
		
		</cftry>
	</cffunction>

	<cffunction name="UpdateAllFeeds" returntype="void" access="private" output="false">

		<cfset event_count = 0 />
	
		<cfloop query="variables.guildrss_temp">
		
			<cfif NOT EventExistsInCache( variables.guildrss_temp.id[variables.guildrss_temp.CurrentRow] )>
			
				<cfset AddEventToCache( variables.guildrss_temp, variables.guildrss_temp.CurrentRow ) />
				
				<cfset event_count++ />
			
			</cfif>
		
		</cfloop>
		
		<cfif (event_count)>
			<cflog file="GuildRSS" type="information" text="UpdateAllFeeds() - Added #event_count# new event(s) [Cache now at #variables.guildrss_cache.RecordCount#]" />
		</cfif>
	
		<!--- and finish by emptying the temp table so it doesn't grow insanely huge over time --->	
		<cfset variables.guildrss_temp = QueryNew( variables.rsscolumnlist ) />
	</cffunction>

	<cffunction name="DeleteOutdatedFeeds" returntype="void" access="private" output="false">

		<cfset var totalEvents = variables.guildrss_cache.RecordCount />
		
		<cfif totalEvents GT variables.purgeThreshold>

			<cfset variables.guildrss_cache = GetRecentEvents( variables.purgeThreshold ) />
			
			<cflog file="GuildRSS" type="information" text="DeleteOutdatedFeeds() - Purged #Evaluate(totalEvents - variables.purgeThreshold)# old event(s) [Cache now at #variables.guildrss_cache.RecordCount#]" />
		
		</cfif>
	</cffunction>

	<cffunction name="EventExistsInCache" returntype="boolean" access="private" output="false">
		<cfargument name="id" type="string" required="true" />
		
		<cfif variables.guildrss_cache.RecordCount GT 0>
		
			<cfreturn (GetEventFromCache( arguments.id ).RecordCount GT 0) />
			
		<cfelse>
		
			<cfreturn false />
			
		</cfif>
	</cffunction>

	<cffunction name="GetRecentEvents" returntype="query" access="private" output="false">
		<cfargument name="maxrows" type="numeric" required="false" default="100" />

		<cfset var data = 0 />
		<cfset var guildrss__fetch = 0 />
	
		<cfquery name="guildrss__fetch" dbtype="query" maxrows="#arguments.maxrows#">
			SELECT *
			FROM variables.guildrss_cache
			ORDER BY RSSUpdatedDate DESC
		</cfquery>
	
		<cfreturn guildrss__fetch />
	</cffunction>

	<cffunction name="GetEventFromCache" returntype="query" access="private" output="false">
		<cfargument name="id" type="string" required="true" />

		<cfset var guildrss_cache__fetch = 0 />

		<cftry>
			<cfquery name="guildrss_cache__fetch" dbtype="query">
				SELECT *
				FROM variables.guildrss_cache
				WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" />
			</cfquery>
			
			<cfreturn guildrss_cache__fetch />

			<cfcatch type="any">
				<cfreturn variables.guildrss_cache />		
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="AddEventToCache" returntype="void" access="private" output="false">
		<cfargument name="data" type="query" required="true" />
		<cfargument name="row" type="numeric" required="true" />

		<cfset var thisColumn = 0 />
		<cfset var thisRow = 0 />

		<cfset thisRow = QueryAddRow( variables.guildrss_cache ) />
		
		<cfloop list="#ListDeleteAt(variables.rsscolumnlist,ListLen(variables.rsscolumnlist))#" index="thisColumn">
				
			<cfset QuerySetCell( variables.guildrss_cache, thisColumn, arguments.data[thisColumn][arguments.row], thisRow ) />
				
		</cfloop>
		
		<cfset QuerySetCell( variables.guildrss_cache, 'RSSUPDATEDDATE', ExtractDateFromZulian(arguments.data['UPDATEDDATE'][arguments.row]), thisRow ) />
	</cffunction>

	<cffunction name="ExtractDateFromZulian" returntype="date" access="private" output="false">		
		<cfargument name="zulian" type="string" required="true" />

		<cfset var mask = '([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2})Z' />
	
		<cfset var dateTime = ReReplace(arguments.zulian, mask, '\1 \2','ONE') />
		
		<cfset realDateTime = ParseDateTime( dateTime ) />		
	
		<cfreturn realDateTime />	
	</cffunction>

</cfcomponent>