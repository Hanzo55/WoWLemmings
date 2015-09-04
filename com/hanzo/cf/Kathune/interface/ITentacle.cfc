<cfinterface displayName="ITentacle">
	
	<cffunction name="Grab" returntype="void" access="public" output="true">
	</cffunction>

	<cffunction name="fetchHTML" returntype="string" access="public" output="false">
	</cffunction>
	
	<cffunction name="fetchPostByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
	</cffunction>	
	
	<cffunction name="getThreadByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
	</cffunction>	

	<cffunction name="getForumPostQueryFromHTML" returntype="query" access="public" output="false">
		<cfargument name="html" type="string" required="true" />
	</cffunction>	
	
	<cffunction name="getPostsAsObjectArray" returntype="array" access="public" output="false">
	</cffunction>	

	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" />
		<cfargument name="row" type="numeric" required="true" />
	</cffunction>	
	
	<cffunction name="fetchArmoryURLFromPost" returntype="string" access="public" output="false">
		<cfargument name="htmlData" type="string" required="true" />
	</cffunction>			
	
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
	</cffunction>	
	
	<cffunction name="getForumURL" returntype="string" access="public" output="false">
	</cffunction>	
	
	<cffunction name="getHTML" returntype="string" access="public" output="false">
	</cffunction>	
	
	<cffunction name="getPostQuery" returntype="query" access="public" output="false">
	</cffunction>	
	
	<cffunction name="getSiteUUID" returntype="string" access="public" output="false">
	</cffunction>	
	
	<cffunction name="getRegion" returntype="string" access="public" output="false">
	</cffunction>
	
		
	
	
	









	
</cfinterface>