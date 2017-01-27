<cfcomponent displayname="Blizzard" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.Blizzard.BlizzardTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- this is an abstract base class which contains shared parsing rules for blizzard-forums in general. should not be instanced. --->
		<cfset setHook('topic')>

		<!---<cfset setLinkRegularExpression('<a class="topic-title" itemprop="url" href="\/wow\/en\/forum\/topic\/([0-9]+)">\s<span itemprop="headline">([^\/]+)<\/span>\s<\/a>') />--->
		<!---<cfset setLinkRegularExpression('<a class="ForumTopic" href="\/forums\/en\/wow\/topic\/([0-9]+)" data-forum-topic=''[^'']+''>\s<span class="ForumTopic-type">[^<]+<i class="Icon"><\/i>[^<]+<\/span><div class="ForumTopic-details"><span class="ForumTopic-heading">\s+<span class="ForumTopic-title--wrapper" >[^<]+<span class="ForumTopic-title" data-toggle="tooltip" data-tooltip-content="[^\"]+">([^<]+)<i class="statusIcon statusIcon-mobile" data-toggle="tooltip" data-tooltip-content=""><\/i>') />--->
		
		<cfset setLinkRegularExpression('<a class = "ForumTopic-timestamp--lastPost" href="\/forums\/en\/wow\/topic\/([0-9]+)[^"]+"\s+data-toggle="tooltip" data-tooltip-content="Last Post">\s+.+?\s+<\/a>[^<]+<\/span>\s+<span class="ForumTopic-title"[^>]+>\s+(.+?)\s+<\/span>') />
		<cfset setTitleRegularExpression('<a href="[^"]+" class="Breadcrumb-content is-active">(.+?)<\/a>') />
		<cfset setBodyRegularExpression('<div class="TopicPost-bodyContent" data-topic-post-body-content="true">(.+?)<\/div>') />

		<cfreturn super.init(arguments.settings) />
	</cffunction>

	<cffunction name="getThreadByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfreturn getThreadURL() & '/' & getHook() & '/' & arguments.hook />
	</cffunction>
	
</cfcomponent>





