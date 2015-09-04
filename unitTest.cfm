<cfscript>
	settings.dsn = 'Parse';
	settings.user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1';
	settings.siteuuid = 'ABABFF';	
	
	obj = createObject('component','com.hanzo.cf.Kathune.tentacle.Blizzard.NorthAmerica.NorthAmericaTentacle').init(settings);
	
	obj.Grab();
</cfscript>

<!--- blank page? try this line to see the raw HTML page: remember! cfdump will NOT work if you call dumprawfood. --->
<!--- <textarea><cfoutput>#obj.DumpRawFood()#</cfoutput></textarea> --->

<cfdump var=#obj#>

<cfset myArr = obj.getPostsAsObjectArray() />

<cfloop from="1" to="#arrayLen(myArr)#" index="i">
	<cfset post = myArr[i] />
	<cfset post.dump() />
</cfloop>

<!--- fetch the first one --->
<cfif arraylen(myArr) gte 1>
<cfset html = obj.fetchPostByHook(myArr[1].getHookValue())>
<textarea rows='15' cols='42' name="go"><cfoutput>#html#</cfoutput></textarea>
</cfif>