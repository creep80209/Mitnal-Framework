<cfcomponent displayname="groupTypes" output="yes">
	<cfset utils = createObject("component", "com.utils")>
	<cfset members = createObject("component", "com.members")>
	<cfset currentUser = members.getCurrentUser()>
	<cffunction name="list" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" default="~">
		<cfargument name="search" type="string" default="~">
		<cfargument name="startCount" type="numeric" default="1">
		<cfargument name="displayCount" type="numeric" default="10">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes/listGroupTypes">
				<cfset statusCode = 1000>
				<cfset message = "Success">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset permissions = #members.getPermission(Method : methodName)#>
				<!--- <cfset permissions = utils.jsonFormat( members.getPageAccess( page: "com\timeSheet.cfc", section : "getTimes" ) )> --->
				
				<cfif permissions eq ''>
					<cfset statusCode = 4044>
					<cfset message = "Insufficient user permissions">
				</cfif>
			<!---------- END METHOD PERMISSION ---------->

			<!---------- START GROUP QUERY ---------->
				<cfif statusCode lte 1999>
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							SELECT	GT.groupTypeID, 
									GT.orderID, 
									GT.groupType, 
									GT.groupTypeStatus
							FROM groupTypes GT
							WHERE NOT GT.groupTypeStatus IN ('Inactive','Deleted')
							ORDER BY GT.orderID
						</cfquery>

						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				</cfif>
			<!---------- END GROUP QUERY ---------->
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #utils.jsonFormat(statuscode)#,
			"requestID": "#createUUID()#",
			"permissions" : "#utils.jsonFormat(permissions)#", 
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"groupTypeID" : "string", 
						"orderID" : "numeric", 
						"groupType" : "string", 
						"groupTypeStatus" : "string"
					},
					"results": [
						<cfsilent>
							<!--- START CHECK TO SEE IF THE START COUNT IS GREATER THAT THE TOTAL NUMBER FO RECORDS --->
								<cfif thisQuery.recordCount LT arguments.displayCount>
									<cfset thisStartCount = 1>
								<cfelseif thisQuery.recordCount LT arguments.startCount>
									<cfset thisStartCount = ((int(thisQuery.recordCount / arguments.displayCount) - 1) * arguments.displayCount) + 1>
								<cfelse>
									<cfset thisStartCount = arguments.startCount>
								</cfif>
							<!--- END CHECK TO SEE IF THE START COUNT IS GREATER THAT THE TOTAL NUMBER FO RECORDS --->
	
							<!--- START DISPLAY COUNT --->
								<cfset thisDisplayCount = arguments.displayCount>
	
								<cfset pageCount = thisStartCount + arguments.displayCount>
	
								<cfif arguments.displayCount GT thisQuery.RecordCount or pageCount GT thisQuery.RecordCount>
									<cfset thisDisplayCount = thisQuery.RecordCount + 1>
								</cfif>
							<!--- END DISPLAY COUNT --->
							<cfset thisRowCount = thisStartCount>
						</cfsilent>
						<cfif thisQuery.recordCount neq 0>
						<cfoutput query="thisQuery" startrow="#thisStartCount#" maxrows="#thisDisplayCount#">
							<cfif thisStartCount neq thisRowCount>,</cfif>
								{ 
									"groupTypeID" : "#utils.jsonFormat(thisQuery.groupTypeID)#", 
									"orderID" : #utils.jsonFormat(thisQuery.orderID)#, 
									"groupType" : "#utils.jsonFormat(thisQuery.groupType)#", 
									"groupTypeStatus" : "#utils.jsonFormat(thisQuery.groupTypeStatus)#"
								}
							<cfset thisRowCount = thisRowCount + 1>
						</cfoutput>
					</cfif>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				<cfif Trim(arguments.groupTypeID) neq "~">"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#",</cfif>
				<cfif Trim(arguments.search) neq "~">"search" : "#utils.jsonFormat(arguments.search)#",</cfif>
				"startCount": #utils.jsonFormat(thisStartCount)#,
				"displayCount": #utils.jsonFormat(arguments.displayCount)#
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="create" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" default="#createUUID()#">
		<cfargument name="groupType" type="string" default="">
		<cfargument name="orderID" type="numeric" default="9999999">
		<cfargument name="groupTypeStatus" type="string" default="999999">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes/createGroupType">
				<cfset statusCode = 1000>
				<cfset message = "Record Created">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset permissions = #members.getPermission(Method : methodName)#>
				<!--- <cfset permissions = utils.jsonFormat( members.getPageAccess( page: "com\timeSheet.cfc", section : "getTimes" ) )> --->
				
				<cfif permissions eq ''>
					<cfset statusCode = 4044>
					<cfset message = "Insufficient user permissions">
				</cfif>
			<!---------- END METHOD PERMISSION ---------->

			<cfif statusCode lte 1999>
				<cfset thisGroupTypeID = createUUID()>

				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							INSERT INTO groupTypes (
								groupTypeID, 
								groupType,
								orderID, 
								groupTypeStatus
							)
							VALUES (
								<cfqueryparam value="#arguments.groupTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
								<cfqueryparam value="#arguments.groupType#" cfsqltype="CF_SQL_VARCHAR" maxlength="300">,
								<cfqueryparam value="#arguments.orderID#" cfsqltype="CF_SQL_NUMERIC">,
								<cfqueryparam value="#arguments.groupTypeStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="45">
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
			"permissions" : "#utils.jsonFormat(permissions)#", 
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": 1,
					"columns": { 
						"groupTypeID" : "string", 
						"orderID" : "numeric", 
						"groupType" : "string", 
						"groupTypeStatus" : "string"
					},
					"results": [
						<cfoutput>
							{ 
								"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#",
								"orderID" : #utils.jsonFormat(arguments.orderID)#, 
								"groupTypeName" : "#utils.jsonFormat(arguments.groupType)#", 
								"groupType" : "#utils.jsonFormat(arguments.groupTypeStatus)#" 
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
	<cffunction name="get" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" default="~">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes">
				<cfset statusCode = 1000>
				<cfset message = "Success">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset permissions = #members.getPermission(Method : methodName)#>
				<!--- <cfset permissions = utils.jsonFormat( members.getPageAccess( page: "com\timeSheet.cfc", section : "getTimes" ) )> --->

				<cfif permissions eq ''>
					<cfset statusCode = 4044>
					<cfset message = "Insufficient user permissions">
				</cfif>
			<!---------- END METHOD PERMISSION ---------->

			<!---------- START GROUP QUERY ---------->
				<cfif statusCode lte 1999>
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							SELECT	GT.groupTypeID, 
									GT.orderID, 
									GT.groupType, 
									GT.groupTypeStatus
							FROM groupTypes GT
							WHERE NOT GT.groupTypeStatus IN ('Inactive','Deleted')
							AND GT.groupTypeID = <cfqueryparam value="#arguments.groupTypeID#" cfsqltype="CF_SQL_VARCHAR">
							ORDER BY GT.orderID
						</cfquery>

						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = cfcatch.detail >
						</cfcatch>
					</cftry>
				</cfif>
			<!---------- END GROUP QUERY ---------->
		</cfsilent>
		<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
		{
			"statusCode": #utils.jsonFormat(statuscode)#,
			"requestID": "#createUUID()#",
			"permissions" : "#utils.jsonFormat(permissions)#", 
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"groupTypeID" : "string", 
						"orderID" : "numeric", 
						"groupType" : "string", 
						"groupTypeStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"groupTypeID" : "#utils.jsonFormat(thisQuery.groupTypeID)#", 
								"orderID" : #utils.jsonFormat(thisQuery.orderID)#, 
								"groupType" : "#utils.jsonFormat(thisQuery.groupType)#", 
								"groupTypeStatus" : "#utils.jsonFormat(thisQuery.groupTypeStatus)#"
							}
						</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="update" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" default="">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes/editGroupType">
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
							SELECT	GT.groupTypeID, 
									GT.orderID, 
									GT.groupType, 
									GT.groupTypeStatus
							FROM groupTypes GT
							WHERE GT.groupTypeID = <cfqueryparam value="#arguments.groupTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
							ORDER BY GT.groupType
						</cfquery>
	
						<cfcatch>
							<cfset statusCode = 5000>
							<cfset message = "An Error Occured: " & cfcatch.detail >
						</cfcatch>
					</cftry>
				<!---------- END GROUP QUERY ---------->
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
						"groupTypeID" : "string", 
						"orderID" : "numeric", 
						"groupType" : "string", 
						"groupTypeStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"groupTypeID" : "#utils.jsonFormat(thisQuery.groupTypeID)#", 
								"orderID" : #utils.jsonFormat(thisQuery.orderID)#, 
								"groupType" : "#utils.jsonFormat(thisQuery.groupType)#", 
								"groupTypeStatus" : "#utils.jsonFormat(thisQuery.groupTypeStatus)#"
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="setGroupType" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" required="yes">
		<cfargument name="groupType" type="string" required="yes">
		<cfargument name="groupTypeStatus" type="string" required="yes">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes/setGroupType">
				<cfset statusCode = 1000>
				<cfset message = "Record Updated">
			<!---------- END DEFAULT VARIABLES ---------->

			<!---------- START METHOD PERMISSION ---------->
				<cfset thisMethodPermissions = #members.getPermission(Method : methodName)#>
			<!---------- END METHOD PERMISSION ---------->

			<cfif thisMethodPermissions CONTAINS "L">
				<!---------- START STATUS UPDATE ---------->
					<cfif arguments.groupTypeStatus eq "999999">
						<cfset arguments.groupTypeStatus = "Active">
					</cfif>
				<!---------- END STATUS UPDATE ---------->

				<!---------- START QUERY ---------->
					<cftry>
						<cfquery name="thisQuery" datasource="projectRead">
							UPDATE groupTypes
							SET	groupType = <cfqueryparam value="#arguments.groupType#" cfsqltype="CF_SQL_VARCHAR" maxlength="300">, 
								groupTypeStatus = <cfqueryparam value="#arguments.groupTypeStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="45">, 
								dateUpdated = #CreateODBCDateTime(now())#, 
								updatedBy = <cfqueryparam value="#currentUser.memberID#" cfsqltype="CF_SQL_VARCHAR">
							WHERE groupTypeID = <cfqueryparam value="#arguments.groupTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
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
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#", 
				"groupType" : "#utils.jsonFormat(arguments.groupType)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="delete" access="remote" returntype="any" output="yes">
		<cfargument name="groupTypeID" type="string" required="yes">
		<cfsilent>
			<!---------- START DEFAULT VARIABLES ---------->
				<cfset methodName = "groupTypes/deleteGroupType">
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
							UPDATE groupTypes
							SET	groupTypeStatus = 'Deleted',
								dateDeleted = #CreateODBCDateTime(now())#, 
								deletedBy = <cfqueryparam value="#currentUser.memberID#" cfsqltype="CF_SQL_VARCHAR">
							WHERE groupTypeID = <cfqueryparam value="#arguments.groupTypeID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
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
			"data": {
				"message": "#utils.jsonFormat(message)#"
			},
			"eventName": "#utils.jsonFormat(methodName)#",
			"requestParams": {
				"groupTypeID" : "#utils.jsonFormat(arguments.groupTypeID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
</cfcomponent>