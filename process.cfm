<cfparam name="url.bodiesOnly" default="false">
<cfparam name="url.scoreOnly" default="false">
<cfparam name="url.twitOnly" default="false">
<cfparam name="url.twitSearchOnly" default="false">

<cfscript>
	// since digestfood() is multithreaded, we may want to call it more frequently (say every 5-10 minutes)
	// so we'll add this parameter to allow for a seperate CFSCHEDULE. By doing this, we can now up the thread count max.
	if (url.bodiesOnly)
		request.kathune.Feed(request.kathune.getMaxThreads());
	else if (url.scoreOnly)
		request.kathune.Digest(request.kathune.getMaxThreads());
	else if (url.twitOnly)
		request.kathune.Glare();
	else if (url.twitSearchOnly)
		request.kathune.Thrash();
	else
		request.kathune.ExtendTentacles();
		
	// save some cpu cycles and only attempt to update history on the 1st of the month.
	if (day(now()) eq 1)		
		request.kathune.Boast();
</cfscript>
<!--- <cfoutput>#request.kathune.dumpInternals()#</cfoutput> --->