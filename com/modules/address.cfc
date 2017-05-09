<cfcomponent output="yes">
	<cfset utils = createObject("component", "com.utils")>
	<cfset currentUser = createObject("component", "com.members")>
	<cffunction name="getAddressByType" access="remote" returntype="query" output="yes">
		<cfargument name="groupID" type="string" default="~" required="no">
		<cfargument name="memberID" type="string" default="~" required="no">
		<cfargument name="addressTypeID" type="string" default="~" required="no">
		<cfsilent>
			<cfset statusCode = 1000>
			<cfset message = "Success">

			<!---------- START ADDRESS QUERY ---------->
				<cftry>	
					<cfquery name="thisQuery" datasource="projectRead">
						SELECT	A.addressID, 
								A.addressOrderID, 
								A.addressTypeID, 
								A.address1, 
								A.address2, 
								A.city, 
								A.region, 
								A.postalCode, 
								A.country, 
								A.county, 
								A.addressStatus
						FROM address A
						WHERE NOT A.addressStatus IN ('Deleted', 'Inactive', 'Pending')
						<cfif arguments.groupID neq '~'>
							AND A.groupID = <cfqueryparam value="#arguments.groupID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
						</cfif>
						<cfif arguments.memberID neq '~'>
							AND A.memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
						</cfif>
						<cfif arguments.addressTypeID neq '~'>
							AND A.addressTypeID = <cfqueryparam value="#arguments.addressTypeID#" CFSQLTYPE="CF_SQL_INTEGER">
						</cfif>
						ORDER BY	A.addressOrderID, 
									A.city, 
									A.region, 
									A.address1, 
									A.address2, 
									A.postalCode
					</cfquery>

					<cfcatch>
						<!--- <cfdump var="#cfcatch#"> --->
						<cfset statusCode = 5000>
						<cfset message = "An Error Occured: " & cfcatch>
					</cfcatch>
				</cftry>
			<!---------- END ADDRESS QUERY ---------->
		</cfsilent>
		{
			"statusCode": #statusCode#,
			"requestid": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"addressID" : "string", 
						"addressOrderID" : "integer", 
						"addressTypeID" : "string", 
						"address1" : "string", 
						"address2" : "string", 
						"city" : "string", 
						"region" : "string", 
						"postalCode" : "string", 
						"country" : "string", 
						"county" : "string", 
						"addressStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"addressID" : "#utils.jsonFormat(thisQuery.addressID)#", 
								"addressOrderID" : #utils.jsonFormat(thisQuery.addressOrderID)#, 
								"addressTypeID" : "#utils.jsonFormat(thisQuery.addressTypeID)#", 
								"address1" : "#utils.jsonFormat(thisQuery.address1)#", 
								"address2" : "#utils.jsonFormat(thisQuery.address2)#", 
								"city" : "#utils.jsonFormat(thisQuery.city)#", 
								"region" : "#utils.jsonFormat(thisQuery.region)#", 
								"postalCode" : "#utils.jsonFormat(thisQuery.postalCode)#", 
								"country" : "#utils.jsonFormat(thisQuery.country)#", 
								"county" : "#utils.jsonFormat(thisQuery.county)#", 
								"addressStatus" : "#utils.jsonFormat(thisQuery.addressStatus)#" 
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventname": "address/addressTypes",
			"requestparams": {
				<cfif arguments.memberID neq "~">"memberID" : "#utils.jsonFormat(arguments.memberID)#",</cfif>
				<cfif arguments.groupID neq "~">"groupID" : "#utils.jsonFormat(arguments.groupID)#",</cfif>
				"addressTypeID" : "<cfif arguments.addressTypeID neq "~">#utils.jsonFormat(arguments.addressTypeID)#</cfif>"
			}
		}
	</cffunction>
	<cffunction name="getAddressTypes" access="remote" returntype="query" output="yes">
		<cfargument name="usedByGroups" type="numeric" default="0">
		<cfargument name="usedByMembers" type="numeric" default="0">
		<cfargument name="addressTypeID" type="string" default="~" required="no">
		<cfsilent>
			<cfset statusCode = 1000>
			<cfset message = "Success">

			<!---------- START ADDRESS QUERY ---------->
				<cftry>
					<cfquery name="thisQuery" datasource="projectRead">
						SELECT	AT.addressTypeID, 
								AT.addressType
						FROM addressTypes AT
						WHERE NOT AT.addressTypeStatus IN ('Deleted', 'Inactive', 'Pending')
						<cfif arguments.usedByGroups>
							AND AT.usedByGroups = 1
						</cfif>
						<cfif arguments.usedByMembers>
							AND AT.usedByMembers = 1
						</cfif>
						<cfif arguments.addressTypeID neq '~'>
							AND AT.addressTypeID = <cfqueryparam value="#arguments.addressTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
						</cfif>
						ORDER BY AT.addressType
					</cfquery>
					
					<cfcatch>
						<!--- <cfdump var="#cfcatch#"> --->
						<cfset statusCode = 5000>
						<cfset message = "An Error Occured: " & cfcatch>
					</cfcatch>
				</cftry>
			<!---------- END ADDRESS QUERY ---------->
		</cfsilent>
		{
			"statusCode": #statusCode#,
			"requestid": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"addressTypeID" : "string", 
						"addressType" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"addressTypeID" : "#utils.jsonFormat(thisQuery.addressTypeID)#", 
								"addressType" : "#utils.jsonFormat(thisQuery.addressType)#"
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventname": "address/addressTypes",
			"requestparams": {
				"addressTypeID" : "#utils.jsonFormat(arguments.addressTypeID)#",
				"usedByGroups" : #utils.jsonFormat(arguments.usedByGroups)#,
				"usedByMembers" : #utils.jsonFormat(arguments.usedByMembers)#
			}
		}
	</cffunction>
</cfcomponent>