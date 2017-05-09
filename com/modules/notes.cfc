<cfcomponent displayname="notes" output="no">
	<cffunction name="createNote" access="public" returntype="string" output="no">
		<cfargument name="noteID" type="string" default="#createUUID()#" required="no">
		<cfargument name="externalID" type="string" default="0" required="no">
		<cfargument name="parentID" type="string" default="0" required="no">
		<cfargument name="groupID" type="string" default="0" required="no">
		<cfargument name="addedBy" type="string" default="0" required="no">
		<cfargument name="noteType" type="string" default="0" required="no">
		<cfargument name="referenceID" type="string" required="no">
		<cfargument name="title" type="string" default="" required="no">
		<cfargument name="subTitle" type="string" default="" required="no">
		<cfargument name="description" type="string" default="" required="no">
		<cfargument name="dateAdded" type="date" default="#CreateODBCDateTime(now())#">
		<cfargument name="noteStatus" type="string" default="Active">

		<cfsilent>
			<cfset returnValue = 1>
			<cfset message = "Note added to system">

			<!---------- START NOTE QUERY ---------->
				<cftry>
					<cfquery datasource="#application.dbName#">
						INSERT INTO notes(
							noteID, 
							externalID, 
							parentID,
							groupID,
							addedBy,
							noteType,
							referenceID,
							title,
							subTitle, 
							description,
							dateAdded,
							noteStatus
						)
						VALUES(
							<cfqueryparam value="#arguments.noteID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
							<cfqueryparam value="#arguments.externalID#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">, 
							<cfqueryparam value="#arguments.parentID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
							<cfqueryparam value="#arguments.groupID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
							<cfqueryparam value="#arguments.addedBy#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
							<cfqueryparam value="#arguments.noteType#" CFSQLTYPE="CF_SQL_VARCHAR" maxlength="50">, 
							<cfqueryparam value="#arguments.referenceID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">, 
							<cfqueryparam value="#arguments.title#" CFSQLTYPE="CF_SQL_VARCHAR" maxlength="255">, 
							<cfqueryparam value="#arguments.subTitle#" CFSQLTYPE="CF_SQL_VARCHAR" maxlength="255">, 
							<cfqueryparam value="#arguments.description#" CFSQLTYPE="CF_SQL_LONGVARCHAR">, 
							#arguments.dateAdded#,
							<cfqueryparam value="#arguments.noteStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
						)
					</cfquery>
	
					<cfcatch>
						<cfset returnValue = "Error: " & cfcatch.detail>
					</cfcatch>
				</cftry>
			<!---------- END NOTE QUERY ---------->
		</cfsilent>
		<!---------- START JSON OUTPUT ---------->
			<cfif structKeyExists(arguments, "callback")>#arguments.callback# (</cfif>
			{
				"statusCode": #statusCode#,
				"requestid": "#createUUID()#",
				"data": {
					"message": "#utils.jsonFormat(message)#"
				},
				"eventname": "notes/createNote",
				"requestparams": {
					"alpha" : "#utils.jsonFormat(arguments.alpha)#", 
					"search" : "#utils.jsonFormat(arguments.search)#"
				}
			}
			<cfif structKeyExists(arguments, "callback")>)</cfif>
		<!---------- END JSON OUTPUT ---------->
	</cffunction>
</cfcomponent>