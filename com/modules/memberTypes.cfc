<cfcomponent displayname="memberTypes" output="yes">
	<cfset utils = createObject("component", "com.utils")>
	<cfset members = createObject("component", "com.members")>
	<cfset currentUser = members.getCurrentUser()>
	<cffunction name="listMemberTypes" access="remote" returntype="any" output="yes">
		<cfargument name="memberTypeID" type="string" default="~">
		<cfargument name="search" type="string" default="">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "memberTypes/listMemberTypes">
				<cfset statusCode = 1000>
				<cfset message = "Success">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							SELECT	MT.memberTypeID, 
									MT.orderID, 
									MT.memberType, 
									MT.memberTypeStatus
							FROM memberTypes MT
							WHERE NOT MT.memberTypeStatus IN ('Inactive','Deleted')
							<cfif arguments.memberTypeID neq "~">
								AND MT.MemberTypeID = <cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
							ORDER BY MT.orderID
						</cfquery>

						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END QUERY ---------->
			<cfelse>
				<cfset statusCode = 9000>
				<cfset message = "You do not have permision to access this method">
			</cfif>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #statusCode#,
			"requestID": "#createUUID()#",
			"permission" : "#Trim(thisMethodPermissions)#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"memberTypeID" : "string", 
						"orderID" : "numeric", 
						"memberType" : "string", 
						"memberTypeStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"memberTypeID" : "#utils.jsonFormat(thisQuery.memberTypeID)#", 
								"orderID" : #utils.jsonFormat(thisQuery.orderID)#, 
								"memberType" : "#utils.jsonFormat(thisQuery.memberType)#", 
								"memberTypeStatus" : "#utils.jsonFormat(thisQuery.memberTypeStatus)#"
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"search" : "#utils.jsonFormat(arguments.search)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="editMemberType" access="remote" returntype="any" output="yes">
		<cfargument name="memberTypeID" type="string" default="~">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "memberTypes/editMemberType">
				<cfset statusCode = 1000>
				<cfset message = "Success">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<!---------- START GROUP QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							SELECT	MT.memberTypeID, 
									MT.orderID, 
									MT.memberType, 
									MT.memberTypeStatus
							FROM memberTypes MT
							WHERE MT.memberTypeID = <cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
							ORDER BY MT.memberType
						</cfquery>
	
						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END GROUP QUERY ---------->
				
				<!---------- START CHECK TO SEE IF THERE ARE NO RECORDS ---------->
					<cfif thisQuery.RecordCount eq 0>
						<cfset statusCode = 5000>
						<cfset message = "No Records Found">
					</cfif>
				<!---------- END CHECK TO SEE IF THERE ARE NO RECORDS ---------->
			<cfelse>
				<cfset statusCode = 9000>
				<cfset message = "You do not have permision to access this method">
			</cfif>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #statusCode#,
			"requestID": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"memberTypeID" : "string", 
						"orderID" : "numeric", 
						"memberType" : "string", 
						"memberTypeStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"memberTypeID" : "#utils.jsonFormat(thisQuery.memberTypeID)#", 
								"orderID" : #utils.jsonFormat(thisQuery.orderID)#, 
								"memberType" : "#utils.jsonFormat(thisQuery.memberType)#", 
								"memberTypeStatus" : "#utils.jsonFormat(thisQuery.memberTypeStatus)#"
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"memberTypeID" : "#utils.jsonFormat(arguments.memberTypeID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="createMemberType" access="remote" returntype="any" output="yes">
		<cfargument name="memberTypeID" type="string" default="#createUUID()#">
		<cfargument name="memberType" type="string" default="">
		<cfargument name="orderID" type="numeric" default="9999999">
		<cfargument name="memberTypeStatus" type="string" default="999999">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "memberTypes/createMemberType">
				<cfset statusCode = 1000>
				<cfset message = "Record Created">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<cfset thisMemberTypeID = createUUID()>
	
				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							INSERT INTO memberTypes (
								memberTypeID, 
								memberType,
								orderID, 
								memberTypeStatus
							)
							VALUES (
								<cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
								<cfqueryparam value="#arguments.memberType#" cfsqltype="CF_SQL_VARCHAR" maxlength="300">,
								<cfqueryparam value="#arguments.orderID#" cfsqltype="CF_SQL_NUMERIC">,
								<cfqueryparam value="#arguments.memberTypeStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="45">
							)
						</cfquery>
	
						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END QUERY ---------->
			<cfelse>
				<cfset statusCode = 9000>
				<cfset message = "You do not have permision to access this method">
			</cfif>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #statusCode#,
			"requestID": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": 1,
					"columns": { 
						"memberTypeID" : "string", 
						"orderID" : "numeric", 
						"memberType" : "string", 
						"memberTypeStatus" : "string"
					},
					"results": [
						<cfoutput>
							{ 
								"memberTypeID" : "#utils.jsonFormat(arguments.memberTypeID)#",
								"orderID" : #utils.jsonFormat(arguments.orderID)#, 
								"memberTypeName" : "#utils.jsonFormat(arguments.memberType)#", 
								"memberType" : "#utils.jsonFormat(arguments.memberTypeStatus)#" 
							}
						</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="setMemberType" access="remote" returntype="any" output="yes">
		<cfargument name="memberTypeID" type="string" required="yes">
		<cfargument name="memberType" type="string" required="yes">
		<cfargument name="memberTypeStatus" type="string" required="yes">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "memberTypes/setMemberType">
				<cfset statusCode = 1000>
				<cfset message = "Record Updated">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<!---------- START STATUS UPDATE ---------->
					<cfif arguments.memberTypeStatus eq "999999">
						<cfset arguments.memberTypeStatus = "Active">
					</cfif>
				<!---------- END STATUS UPDATE ---------->

				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							UPDATE memberTypes
							SET	memberType = <cfqueryparam value="#arguments.memberType#" cfsqltype="CF_SQL_VARCHAR" maxlength="300">, 
								memberTypeStatus = <cfqueryparam value="#arguments.memberTypeStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="45">, 
								dateUpdated = #CreateODBCDateTime(now())#, 
								updatedBy = <cfqueryparam value="#currentUser.memberID#" cfsqltype="CF_SQL_VARCHAR">
							WHERE memberTypeID = <cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
						</cfquery>
	
						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END QUERY ---------->
			<cfelse>
				<cfset statusCode = 9000>
				<cfset message = "You do not have permision to access this method">
			</cfif>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #statusCode#,
			"requestID": "#createUUID()#",
			"permission" : "#Trim(thisMethodPermissions)#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"memberTypeID" : "#utils.jsonFormat(arguments.memberTypeID)#", 
				"memberType" : "#utils.jsonFormat(arguments.memberType)#", 
				"memberTypeStatus" : "#utils.jsonFormat(arguments.memberTypeStatus)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="deleteMemberType" access="remote" returntype="any" output="yes">
		<cfargument name="memberTypeID" type="string" required="yes">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "memberTypes/deleteMemberType">
				<cfset statusCode = 1000>
				<cfset message = "Record Deleted">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							UPDATE memberTypes
							SET	memberTypeStatus = 'Deleted',
								dateDeleted = #CreateODBCDateTime(now())#, 
								deletedBy = <cfqueryparam value="#currentUser.memberID#" cfsqltype="CF_SQL_VARCHAR">
							WHERE memberTypeID = <cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
						</cfquery>
	
						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END QUERY ---------->
			</cfif>
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #statusCode#,
			"requestID": "#createUUID()#",
			"permission" : "#Trim(thisMethodPermissions)#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"memberTypeID" : "#utils.jsonFormat(arguments.memberTypeID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
</cfcomponent>