<cfcomponent output="false">
	
	<!--- Application name, should be unique --->
	<cfset this.name = "KathuneApp">

	<!--- use when testing Kathune as a submodule off of /com/hanzo/cf/kathune --->
	<cfset this.componentpaths = [ ExpandPath(GetDirectoryFromPath(GetCurrentTemplatePath()) & "/com/hanzo/cf/kathune/kathune/") ] />

	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = createTimeSpan(0,8,0,0) />
	
	<!--- Dev or Prod? --->
	<cfset this.isDev = false />

	<!--- Run when application starts up --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		
		<cfif (not this.isDev and not isdefined('application.kathune')) or (isdefined('url.reinit'))>
			<cflock name="AppInit" timeout="30" type="exclusive">
				<!--- use when testing Kathune as a submodule off of /com/hanzo/cf/kathune --->
				<cfset application.kathune = createObject('component','com.hanzo.cf.kathune.kathune.Kathune').init('/config.xml') />
				
				<!---
				use when testing Kathune as a mapping either in componentpaths or in cfadmin
				
				<cfset application.kathune = createObject('component','Kathune').init('/config.xml') /> --->
			</cflock>
			<cfif isdefined('url.reinit')>
				<cfobjectcache action="clear" />
			</cfif>
		</cfif>
		
		<cfreturn true />
	</cffunction>

	<!--- Run before the request is processed --->
	<cffunction name="onRequestStart" returnType="boolean" output="false">
		<cfargument name="thePage" type="string" required="true" />
		
		<cfif isdefined('url.reinit')>
			<cfset onApplicationStart() />
		</cfif>
		
		<cfset request.isDev = this.isDev />
		
		<cfif this.isDev>

			<!---
			use when testing Kathune as a submodule off of /com/hanzo/cf/kathune --->
			<cfset request.kathune = createObject('component','com.hanzo.cf.kathune.kathune.Kathune').init('/config.xml') />
			

			<!--- 
			use when testing Kathune as a mapping either in componentpaths or in cfadmin
			
			<cfset request.kathune = createObject('component','Kathune').init('/config.xml') />
			--->
			<cfobjectcache action="clear" />
		
		<cfelse>
			<cflock name="AppRead" timeout="15" type="readonly">
				<cfset request.kathune = application.kathune />
			</cflock>
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
</cfcomponent>