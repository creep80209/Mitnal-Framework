<cfcomponent displayname="permissions" output="yes">
	<cfsilent>
		<cfset utils = createObject("component", "com.utils")>
		<cfset members = createObject("component", "com.members")>
		<cfset currentUser = members.getCurrentUser()>
		<!---------- <cfset pageAccess = members.getPageAccess()> ---------->
	</cfsilent>
	<cffunction name="getPages" access="remote" returntype="any" output="yes">
		<cfargument name="search" type="string" default="~">
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset variables.methodName = "com/pageAccess.cfc?method=getPages">
				<cfset variables.statusCode = 1000>
				<cfset variables.message = "Success">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START PERMISSION LOOKUP  ---------->
			<!---
				<cfset variables.permissions = utils.jsonFormat( members.getPageAccess( page: "com\pageAccess.cfc", section : "getPages" ) )>

				<cfif variables.permissions eq ''>
					<cfset variables.statusCode = 4044>
					<cfset variables.message = "Insufficient user permissions">
				</cfif>
			--->
				<cfset variables.permissions = "CRUD">
			<!---------- END PERMISSION LOOKUP ---------->

			<!---------- START QUERY ---------->
				<cfif variables.statusCode lte 1999>
					<cfquery name="thisQuery" datasource="projectRead">
						SELECT	A.pageAccessID, 
								A.filePathing, 
								A.section, 
								A.pageAccessStatus
						FROM pageAccess A
						WHERE pageAccessStatus NOT IN ('Pending','Inactive','Deleted')
						ORDER BY	A.filePathing, 
									A.section
					</cfquery>
					<cftry>
						<cfcatch>
							<cfset variables.statuscode = 5000>
							<cfset variables.message = "An Error had occurred: " & cfcatch.detail>
						</cfcatch>
					</cftry>
				</cfif>
			<!---------- END QUERY ---------->
		<cfsilent>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #utils.jsonFormat( variables.statuscode )#,
			"requestID": "#createUUID()#",
			"permissions" : "#utils.jsonFormat( variables.permissions )#", 
			"data": {
				"message": "#utils.jsonFormat( variables.message )#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": {
						"pageAccessID": "string",
						"filePathing": "string",
						"section": "string",
						"pageAccessStatus": "string"
					},
					"results": [
					<cfoutput query="thisQuery">
						{
							"pageAccessID": "#utils.jsonFormat( thisQuery.pageAccessID )#", 
							"filePathing": "#utils.jsonFormat( thisQuery.filePathing )#", 
							"section": "#utils.jsonFormat( thisQuery.section )#", 
							"pageAccessStatus": "#utils.jsonFormat( thisQuery.pageAccessStatus )#"
						}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
					</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat( variables.methodName )#",
			"requestParams": {
				<cfif Trim(arguments.search) neq "~">"search" : "#utils.jsonFormat( arguments.search )#"</cfif>
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
</cfcomponent>
