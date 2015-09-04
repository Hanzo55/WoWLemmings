<cfcomponent displayname="EventGateway" hint="com.hanzo.cf.Kathune.EventGateway">

	<cffunction name="onIncomingMessage">
		<cfargument name="cfevent" type="struct" required="true" />
		
		<cfscript>
			<!--- Get the message --->
			var messageBody = arguments.event.data.body;
			var message = messageBody.message;
			var retValue = structNew();

			retValue.body = message;

			<!--- set AMF destination id --->
			retValue.destination = 'ColdFusionGateway';
			
			<!--- send the return message back --->
			<!--- set EventGateway id --->
			SendGatewayMessage('KathuneGateway', retValue);			
		</cfscript>
	</cffunction>

</cfcomponent>