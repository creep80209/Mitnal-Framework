<cfcomponent displayname="threads">
	<cfsilent><cfset utils = createObject("component", "com.utils")></cfsilent>
	<cffunction name="fullThreadList" access="remote" returntype="any" output="yes">
		<cfargument name="threadID" type="string" default="">

		<cfsilent>
			<cfset statusCode = 1000>
			<cfset message = "Success">
			
			<!---------- START LOOP FIND MASTER THREAD ID ---------->
				<cftry>
					<cfquery name="thisQuery" datasource="projectRead">
						SELECT	T.threadID,
								T.parentID,
								T.masterThreadID,
								T.title,
								T.dateAdded,
								M.firstName, 
								M.lastName, 
								(
									SELECT Count(S.threadID)
									FROM threads S
									WHERE S.parentID = T.threadID
								) AS childThreadCount
						FROM threads T
								JOIN members M ON M.memberID = T.addedBy
						WHERE T.masterThreadID IN (
							SELECT S.masterThreadID
							FROM threads S
							WHERE S.threadID = <cfqueryparam value="#url.threadID#" cfsqltype="CF_SQL_VARCHAR">
						)
					</cfquery>
					<cfcatch>
						<cfset statusCode = 5000>
						<cfset message = "An Error Occured: " & cfcatch.detail >
					</cfcatch>
				</cftry>
			<!---------- START LOOP FIND MASTER THREAD ID ---------->
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
						"threadID" : "string", 
						"title" : "string", 
						"dateTimeAdded" : "string", 
						"addedBy" : "string", 
						"subThreads" : "array"
					},
					"results": [
						<!---------- START SUB METHOD ---------->
							#getSubThreads(queryData = thisQuery)#
						<!---------- END SUB METHOD ---------->
					]
				</cfif>
			},
			"eventName": "groupTypes/listGroupTypes",
			"requestParams": {
				"threadID" : "#utils.jsonFormat(arguments.threadID)#"
			}
		}
		<cfif structKeyExists(arguments, "callback")>)</cfif>
	</cffunction>
	<cffunction name="getSubThreads" access="remote" returntype="any" output="yes">
		<cfargument name="queryData" type="query" required="yes" hint="Family tree data query.">
		<cfargument name="parentID" type="string" default="0">
	    <cfset var LOCAL = StructNew() />

		<!---------- START QUERY OR QUERY TO LOOKUP UP CHILD THREADS ---------->
			<cfquery name="LOCAL.subThread" dbtype="query">
				SELECT		threadID,
							parentID,
							masterThreadID,
							title,
							dateAdded,
							firstName, 
							lastName, 
							childThreadCount
				FROM arguments.queryData
				WHERE parentID = <cfqueryparam value="#arguments.parentID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		<!---------- START QUERY OR QUERY TO LOOKUP UP CHILD THREADS ---------->

		<!---------- END THREAD RETURN VALUE ---------->
			<cfif LOCAL.subThread.RecordCount>
				<cfloop query="LOCAL.subThread">
				    {
						"threadID" : "#utils.jsonFormat(LOCAL.subThread.threadID)#", 
						"title" : "#utils.jsonFormat(LOCAL.subThread.title)#", 
						"dateAdded" : "#DateFormat(thisQuery.dateAdded, 'MM/DD/YYYY')# #TimeFormat(thisQuery.dateAdded, 'hh:MM:SS tt')#", 
						"addedBy" : "#utils.jsonFormat(LOCAL.subThread.firstName)# #utils.jsonFormat(LOCAL.subThread.lastName)#", 
						"subThreads" : [
							<cfif LOCAL.subThread.childThreadCount neq 0>
							    <cfset getSubThreads( queryData = arguments.queryData, ParentID = LOCAL.subThread.threadID ) />
							</cfif>
						]
				    }<cfif LOCAL.subThread.recordCount neq LOCAL.subThread.currentRow>,</cfif>
				</cfloop>
			</cfif>
		<!---------- END THREAD RETURN VALUE ---------->

		<cfreturn>
	</cffunction>
</cfcomponent>