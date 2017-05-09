<cfcomponent displayname="Member Information and login" output="yes">
	<cfsilent><cfset utils = createObject("component", "com.utils")></cfsilent>
	<cffunction name="getCurrentUser" access="remote" returntype="query" output="yes">
		<cfscript>
			userLoggedIn();
		</cfscript>

		<!---------- START SURRENT USER INFORMATION ---------->
			<!--- START CURRENT_USER LOOKUP --->
				<cfquery name="thisQuery" datasource="#application.dbName#">
					SELECT	M.memberID, 
							M.firstName, 
							M.lastName,
							(
								SELECT MTS.memberTypeID
								FROM memberTypeSelected MTS
										INNER JOIN memberTypes MT ON MT.memberTypeID = MTS.memberTypeID
								WHERE MTS.memberID = M.memberID
								AND NOT MT.memberTypeStatus IN ('999999','Inactive','Deleted')
								AND NOT MTS.memberTypeSelectedStatus IN ('999999','Inactive','Deleted')
								ORDER BY MT.orderID 
								LIMIT 1
							) AS memberTypeID
					FROM members M
							INNER JOIN logins L ON L.memberID = M.memberID
					WHERE L.sessionID = <cfqueryparam value="#cookie.crudCookie#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				</cfquery>
			<!--- END CURRENT_USER LOOKUP --->
		<!---------- START SURRENT USER INFORMATION ---------->

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="userLogInCheck" access="remote" returntype="any" output="yes">
		<cfargument name="login" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfsilent>
			<cfset systemDateTime = now()>
			<cfset statusCode = 1000>
			<cfset message = "Success">

			<!---------- START COOKIE RESET ---------->
				<cfcookie name="crudCookie" value="~">
			<!---------- END COOKIE RESET ---------->
			
			<!---------- START FIELD CHECK ---------->
				<cfif trim(arguments.login) eq ''>
					<cfset statusCode = 5000>
					<cfset message = "Login ID is blank.">
				</cfif>

				<cfif trim(arguments.password) eq ''>
					<cfset statusCode = 5000>
					<cfset message = "Password is blank.">
				</cfif>
			<!---------- START FIELD CHECK ---------->

			<!---------- START LOGIN CHECK ---------->
				<cfif statusCode lte 1000 and statusCode lte 1999>
					<!--- START CHECK THE POSSIBLE LOGIN INFORMATION AGAINST THE DB --->
						<cfquery name="thisQuery" datasource="#application.dbName#">
							SELECT	memberID, 
									login, 
									password, 
									accessLevel,
									memberStatus
							FROM members
							WHERE login = <cfqueryparam value="#Trim(arguments.login)#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
							AND password = <cfqueryparam value="#Trim(arguments.password)#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
						</cfquery>
					<!--- END CHECK THE POSSIBEL LOGIN INFORMATION AGAINST THE DB --->

					<!---------- START LOGIN CHECK ---------->
						<cfif (thisQuery.recordcount neq 0) and (thisQuery.login eq Trim(arguments.login)) and (thisQuery.password eq Trim(arguments.password))>
							<cfset systemDateTime = now()>

							<!---------- START NEW SESSION VALUE ---------->
								<cfcookie name="crudCookie" value="#CreateUUID()#">

								<!--- START SUBMIT THE USER PROFILE WITH THE NEW COOKIE VALUE --->
									<cfquery datasource="#application.dbName#" dbtype="ODBC">
										INSERT INTO logins (
											sessionID,
											memberID, 
											dateLoggedIn
										)
										VALUES(
											<cfqueryparam value="#cookie.crudCookie#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
											<cfqueryparam value="#thisQuery.memberID#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="35">, 
											#CreateODBCDateTime(now())#
										)
									</cfquery>
								<!--- END SUBMIT THE USER PROFILE WITH THE NEW COOKIE VALUE --->

								<!---------- START NOTE ---------->
									<cfset returnValue = createObject("component", "com.notes").createNote(
										noteType: 'Member Login', 
										referenceID: thisQuery.memberID,
										title: 'Member logged into READ',
										description: 'Member logged into READ on "' & DateFormat(systemDateTime, 'MM/DD/YYYY') & ' ' & TimeFormat(systemDateTime, 'HH:MM:SS') & '"<br><br>Refferer Page: ' & HTTP_REFERER & '<br><br>IP Address: ' & REMOTE_ADDR
									)>
								<!---------- END NOTE ---------->
							<!---------- END NEW SESSION VALUE ---------->

							<!---------- START PENDING TO ACTIVE ---------->
								<cfif thisQuery.memberStatus eq 'Pending'>
									<!--- START UPDATE OF GROUP INFORMATION --->
										<cfquery datasource="#application.dbName#">
											UPDATE members
											SET	memberStatus = 'Active'
											WHERE memberID = <cfqueryparam value="#thisQuery.memberID#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="35">
										</cfquery>
									<!--- END UPDATE OF GROUP INFORMATION --->

									<!---------- START NOTE ---------->
										<cfset returnValue = createObject("component", "com.notes").createNote(
											noteType: 'Member Login', 
											referenceID: thisQuery.memberID,
											title: 'Member verified account by logging into READ',
											description: 'Member verified account by logging into READ on "' & DateFormat(systemDateTime, 'MM/DD/YYYY') & ' ' & TimeFormat(systemDateTime, 'HH:MM:SS') & '"<br><br>Refferer Page: ' & HTTP_REFERER & '<br><br>IP Address: ' & REMOTE_ADDR
										)>
									<!---------- END NOTE ---------->
								</cfif>
							<!---------- END PENDING TO ACTIVE ---------->
						<cfelse>
							<cfset statusCode = 5000>
							<cfset message = 'Login ID and/or Password you submitted could not be found. Please try again.'>
						</cfif>
					<!---------- END LOGIN CHECK ---------->
				<cfelseif statusCode neq 5000>
					<cfset statusCode = 5000>
					<cfset message = "Login Not Found">
				</cfif>
			<!---------- END 'POST' METHOD CHECK ---------->
		</cfsilent>
		{
			"statusCode": #statusCode#,
			"requestid": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(value : message)#"
				<cfif statusCode lte 1000 and statusCode lte 1999>
					,"totalRows": #thisQuery.recordCount#,
					"columns": { 
						"memberID" : "string", 
						"login" : "string", 
						"accessLevel" : "string", 
						"memberStatus" : "string"
					},
					"results": [
						<cfoutput query="thisQuery">
							{ 
								"memberID" : "#utils.jsonFormat(value : thisQuery.memberID)#", 
								"login" : "#utils.jsonFormat(value : thisQuery.login)#", 
								"accessLevel" : "#utils.jsonFormat(value : thisQuery.accessLevel)#", 
								"memberStatus" : "#utils.jsonFormat(value : thisQuery.memberStatus)#"
							}<cfif thisQuery.recordCount neq thisQuery.CurrentRow>,</cfif>
						</cfoutput>
					]
				</cfif>
			},
			"eventname": "groups/listGroups",
			"requestparams": {
				"login" : "#utils.jsonFormat(arguments.login)#"
			}
		}
	</cffunction>
	<cffunction name="userLoggedIn" access="remote" returntype="string" output="yes">
		<cfif isDefined("cookie.crudCookie") and isValid("UUID", cookie.crudCookie) >
			<cfreturn true/>
		<cfelse>
			<cflocation url="/index.htm" addtoken="No">
			<cfabort>
		</cfif>
	</cffunction>
	<cffunction name="userLoggedOut" access="remote" returntype="string" output="yes">
		<cfset returnValue = 1>
		<cftry>
			<cfif (isDefined("cookie.crudCookie") and isValid("UUID", cookie.crudCookie) ) >
				<cfquery datasource="#application.dbName#">
					UPDATE logins
					SET dateLoggedOut = #CreateODBCDateTime(now())#
					WHERE sessionID = <cfqueryparam value="#cookie.crudCookie#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				</cfquery>
	
				<cfcookie name="READ" value="0">
			</cfif>
			
			<cfcatch>
				<cfset returnValue = "Error: " & cfcatch.detail>
			</cfcatch> 
		</cftry>

		<cfreturn returnValue>
	</cffunction>
	<cffunction name="getPermission" access="remote" returntype="string" output="no">
		<cfargument name="method" type="string" required="yes">
		<cfreturn "LAVED">
	</cffunction>
	<cffunction name="getPageAccess" access="remote" returntype="any" output="no">
		<cfargument name="page" type="string" required="yes">
		<cfargument name="section" type="string" default="~">
		<cfscript>
			currentUser = getCurrentUser();
		</cfscript>

		<cfsilent>
			<cfset statusCode = 1000>
			<cfset message = "Success">
			
			<!---------- END QUERY LOOKUP ---------->
				<cftry>
					<cfquery name="thisQuery" datasource="#application.dbName#">
						SELECT	PA.pageAccessID, 
								PAG.pageAccess
						FROM pageAccess PA
								INNER JOIN pageAccessGranted PAG ON PAG.pageAccessID = PA.pageAccessID
						WHERE PA.filePathing = <cfqueryparam value="#arguments.page#" cfsqltype="CF_SQL_VARCHAR">
						<cfif arguments.section neq '~'>
							AND PA.section = <cfqueryparam value="#arguments.section#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
						<cfelse>
							AND (
								PA.section = ''
								OR PA.section IS NULL
							)
						</cfif>
						AND NOT PA.pageAccessStatus IN ('999999','Inactive','Deleted')
						AND PAG.memberTypeID IN (
							SELECT MTS.memberTypeID
							FROM memberTypeSelected MTS
									INNER JOIN memberTypes MT ON MT.memberTypeID = MTS.memberTypeID
							WHERE MTS.memberID = <cfqueryparam value="#currentUser.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"> 
							AND NOT MT.memberTypeStatus IN ('999999','Inactive','Deleted')
							AND NOT MTS.memberTypeSelectedStatus IN ('999999','Inactive','Deleted')
							ORDER BY MT.orderID
						)
					</cfquery>
					
					<cfcatch>
						<cfset statusCode = 5000>
						<cfset message = "Error: " & cfcatch.detail>
					</cfcatch>
				</cftry>
			<!---------- END QUERY LOOKUP ---------->
		</cfsilent>
		<!---
		{
			"statusCode": #statusCode#,
			"requestid": "#createUUID()#",
			"data": {
				"message": "#utils.jsonFormat(message)#"
				<cfif statusCode gte 1000 and statusCode lte 1999>
					,"totalRows": 1,
					"columns": { 
						"pageAccessID" : "string", 
						"pageAccess" : "string"
					},
					"results": [
						<cfoutput>
							{ 
								"pageAccessID" : "#utils.jsonFormat(thisQuery.pageAccessID)#", 
								"pageAccess" : "#utils.jsonFormat(thisQuery.pageAccess)#"
							}
						</cfoutput>
					]
				</cfif>
			},
			"eventname": "members/getPageAccess",
			"requestparams": {
				"page" : "#utils.jsonFormat(arguments.page)#"
				<cfif arguments.section neq "~">,"section" : "#utils.jsonFormat(arguments.section)#"</cfif>
			}
		}
		--->
		#thisQuery.pageAccess#
	</cffunction>
	<cffunction name="getMemberQuery" access="remote" returntype="query">
	</cffunction>
	<cffunction name="getMemberJSON" access="remote" returntype="string">
		<cfargument name="memberID" type="string" required="yes">
	</cffunction>
	<cffunction name="listMembersJSON" access="remote" returntype="string">
		<cfargument name="alpha" type="string" default="All" required="no">
		<cfargument name="search" type="string" default="~" required="no">
		<cfargument name="startCount" type="string" default="1" required="no">
		<cfargument name="displayCount" type="string" default="10" required="no">
		<cfargument name="memberID" type="string" default="~" required="no">
		<cfargument name="groupID" type="string" default="~" required="no">
		<cfargument name="groupName" type="string" default="~" required="no">
		<cfargument name="firstName" type="string" default="~" required="no">
		<cfargument name="middleName" type="string" default="~" required="no">
		<cfargument name="nickName" type="string" default="~" required="no">
		<cfargument name="lastName" type="string" default="~" required="no">
		<cfargument name="address" type="string" default="~" required="no">
		<cfargument name="city" type="string" default="~" required="no">
		<cfargument name="region" type="string" default="~" required="no">
		<cfargument name="country" type="string" default="~" required="no">
		<cfargument name="email" type="string" default="~" required="no">
		<cfargument name="phone" type="string" default="~" required="no">
		<cfargument name="groupType" type="string" default="~" required="no">
		<cfargument name="addressType" type="string" default="~" required="no">

		<cfscript>
			members = listMembers(
				alpha: arguments.alpha,
				search: arguments.search,
				startCount: arguments.startCount,
				displayCount: arguments.displayCount,
				memberID: arguments.memberID,
				groupID: arguments.groupID,
				groupName: arguments.groupName,
				firstName: arguments.firstName,
				middleName: arguments.middleName,
				nickName: arguments.nickName,
				lastName: arguments.lastName,
				address: arguments.address,
				city: arguments.city,
				region: arguments.region,
				country: arguments.country,
				email: arguments.email,
				phone: arguments.phone,
				groupType: arguments.groupType,
				addressType: arguments.addressType
			);
		</cfscript>

		<!--- <cfdump var="#members#"> --->
		<!---------- START REAL RECORD COUNT BASED ON GROUP BY ---------->
			<cfset thisRecordCount = 0>
			<cfoutput query="members" group="memberID">
				<cfset thisRecordCount = thisRecordCount + 1>
			</cfoutput>
		<!---------- END REAL RECORD COUNT BASED ON GROUP BY ---------->

		<!---------- START JSON RETURN VALUE ---------->
			<cfset thisJSON = ''>

			<cfset thisJSON = thisJSON & '{'>
				<cfset thisJSON = thisJSON & '"recordCount": ' & thisRecordCount & ','>
				<cfset thisJSON = thisJSON & '"startCount": ' &  arguments.s & ','>
				<cfset thisJSON = thisJSON & '"displayCount": ' &  arguments.c & ','>
				<cfset thisJSON = thisJSON & '"data": ['>
					<cfset masterRowCount = 1>
					<cfoutput query="members" group="memberID">
						<cfif masterRowCount neq 1>
							<cfset thisJSON = thisJSON & ','>
						</cfif>

						<cfset thisJSON = thisJSON & '{'>
							<cfset thisJSON = thisJSON & '"id": "' & members.memberID & '",'>
							<cfset thisJSON = thisJSON & '"firstName": "' & members.firstName & '",'>
							<cfset thisJSON = thisJSON & '"middleName": "' & members.middleName & '",'>
							<cfset thisJSON = thisJSON & '"nickName": "' & members.nickName & '",'>
							<cfset thisJSON = thisJSON & '"lastName": "' & members.lastName & '",'>
							<!---------- START ADDREDD INFO ---------->
								<cfquery name="address" dbtype="query">
									SELECT	addressID,
											addressType,
											address1,
											address2,
											city,
											region,
											postalCode,
											country,
											county,
											addressStatus
									FROM members
									WHERE memberID = <cfqueryparam value="#members.memberID#" cfsqltype="CF_SQL_VARCHAR">
									AND NOT addressType is null
									GROUP BY	addressID,
												addressType,
												address1,
												address2,
												city,
												region,
												postalCode,
												country,
												county,
												addressStatus
								</cfquery>

								<!--- <cfdump var="#address#"> --->

								<cfif address.recordCount neq 0>
									<cfset thisJSON = thisJSON & '"addresses": ['>
									<cfset rowCount = 1>

									<cfloop query="address">
										<cfif rowCount neq 1>
											<cfset thisJSON = thisJSON & ','>
										</cfif>
										<cfset thisJSON = thisJSON & '{'>
											<cfset thisJSON = thisJSON & '"addressID": "' & address.addressID & '",'>
											<cfset thisJSON = thisJSON & '"addressType": "' & address.addressType & '",'>
											<cfset thisJSON = thisJSON & '"address1": "' & address.address1 & '",'>
											<cfset thisJSON = thisJSON & '"address2": "' & address.address2 & '",'>
											<cfset thisJSON = thisJSON & '"city": "' & address.city & '",'>
											<cfset thisJSON = thisJSON & '"region": "' & address.region & '",'>
											<cfset thisJSON = thisJSON & '"postalCode": "' & address.postalCode & '",'>
											<cfset thisJSON = thisJSON & '"country": "' & address.country & '",'>
											<cfset thisJSON = thisJSON & '"county": "' & address.county & '",'>
											<cfset thisJSON = thisJSON & '"addressStatus": "' & address.addressStatus & '"'>
										<cfset thisJSON = thisJSON & '}'>
										<cfset rowCount = rowCount + 1>
									</cfloop>
									<cfset thisJSON = thisJSON & '],'>
								</cfif>
							<!---------- END ADDRESS INFO ---------->

							<!---------- START GROUPS INFO ---------->
								<cfquery name="groups" dbtype="query">
									SELECT	groupID,
											groupType,
											groupName,
											groupStatus
									FROM members
									WHERE memberID = <cfqueryparam value="#members.memberID#" cfsqltype="CF_SQL_VARCHAR">
									AND NOT groupID IS null
									GROUP BY	groupID,
												groupType,
												groupName,
												groupStatus
								</cfquery>

								<!--- <cfdump var="#address#"> --->

								<cfif groups.recordCount neq 0>
									<cfset thisJSON = thisJSON & '"groups": ['>
									<cfset rowCount = 1>

									<cfloop query="groups">
										<cfif rowCount neq 1>
											<cfset thisJSON = thisJSON & ','>
										</cfif>
										<cfset thisJSON = thisJSON & '{'>
											<cfset thisJSON = thisJSON & '"groupID": "' & groups.groupID & '",'>
											<cfset thisJSON = thisJSON & '"groupType": "' & groups.groupType & '",'>
											<cfset thisJSON = thisJSON & '"groupName": "' & groups.groupName & '",'>
											<cfset thisJSON = thisJSON & '"groupStatus": "' & groups.groupStatus & '"'>
										<cfset thisJSON = thisJSON & '}'>
										<cfset rowCount = rowCount + 1>
									</cfloop>
									<cfset thisJSON = thisJSON & '],'>
								</cfif>
							<!---------- END GROUPS INFO ---------->

							<!---------- START GROUPS INFO ---------->
								<cfquery name="email" dbtype="query">
									SELECT	emailID,
											emailType,
											email,
											emailOrderID,
											emailStatus
									FROM members
									WHERE memberID = <cfqueryparam value="#members.memberID#" cfsqltype="CF_SQL_VARCHAR">
									AND NOT emailID IS null
									GROUP BY	emailID,
												emailType,
												email,
												emailOrderID,
												emailStatus
									order by emailOrderID
								</cfquery>

								<!--- <cfdump var="#email#"> --->
								<cfif email.recordCount neq 0>
									<cfset thisJSON = thisJSON & '"emails": ['>
									<cfset rowCount = 1>

									<cfloop query="email">
										<cfif rowCount neq 1>
											<cfset thisJSON = thisJSON & ','>
										</cfif>
										<cfset thisJSON = thisJSON & '{'>
											<cfset thisJSON = thisJSON & '"emailID": "' & email.emailID & '",'>
											<cfset thisJSON = thisJSON & '"emailType": "' & email.emailType & '",'>
											<cfset thisJSON = thisJSON & '"emailOrderID": "' & email.emailOrderID & '",'>
											<cfset thisJSON = thisJSON & '"email": "' & email.email & '",'>
											<cfset thisJSON = thisJSON & '"emailStatus": "' & email.emailStatus & '"'>
										<cfset thisJSON = thisJSON & '}'>
										<cfset rowCount = rowCount + 1>
									</cfloop>
									<cfset thisJSON = thisJSON & '],'>
								</cfif>
							<!---------- END ADDRESS INFO ---------->

							<!---------- START GROUPS INFO ---------->
								<cfquery name="phone" dbtype="query">
									SELECT	phoneID,
											phoneType,
											phoneOrderID,
											phoneNumber,
											phoneStatus
									FROM members
									WHERE memberID = <cfqueryparam value="#members.memberID#" cfsqltype="CF_SQL_VARCHAR">
									AND NOT phoneID IS null
									GROUP BY	phoneID,
											phoneType,
											phoneOrderID,
											phoneNumber,
											phoneStatus
								</cfquery>

								<!--- <cfdump var="#address#"> --->
								<cfif phone.recordCount neq 0>
									<cfset thisJSON = thisJSON & '"phoneNumbers": ['>
									<cfset rowCount = 1>

									<cfloop query="phone">
										<cfif rowCount neq 1>
											<cfset thisJSON = thisJSON & ','>
										</cfif>
										<cfset thisJSON = thisJSON & '{'>
											<cfset thisJSON = thisJSON & '"phoneID": "' & phone.phoneID & '",'>
											<cfset thisJSON = thisJSON & '"phoneType": "' & phone.phoneType & '",'>
											<cfset thisJSON = thisJSON & '"phoneOrderID": "' & phone.phoneOrderID & '",'>
											<cfset thisJSON = thisJSON & '"phoneNumber": "' & phone.phoneNumber & '",'>
											<cfset thisJSON = thisJSON & '"phoneStatus": "' & phone.phoneStatus & '"'>
										<cfset thisJSON = thisJSON & '}'>
										<cfset rowCount = rowCount + 1>
									</cfloop>
									<cfset thisJSON = thisJSON & '],'>
								</cfif>
							<!---------- END ADDRESS INFO ---------->
							<cfset thisJSON = thisJSON & '"memberStatus": "' & members.memberStatus & '"'>

						<cfset thisJSON = thisJSON & '}'>

						<cfset masterRowCount = masterRowCount + 1>
					</cfoutput>
				<cfset thisJSON = thisJSON & ']'>
			<cfset thisJSON = thisJSON & '}'>
		<!---------- END JSON RETURN VALUE ---------->

		<cfscript>
			return thisJSON;
		</cfscript>
	</cffunction>
	<cffunction name="getMember" access="remote" returntype="query" output="yes">
		<cfargument name="memberID" type="string" default="~" required="no">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				SELECT	memberID,
						firstName,
						middleName,
						nickName,
						lastName,
						login,
						password,
						accessLevel,
						dateAdded,
						memberStatus
				FROM members
				WHERE memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfquery>

			<cfcatch>
				<cfset thisQuery = #CFCATCH#>
			</cfcatch>
		</cftry>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="deleteMember" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset returnValue = 200>

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE members
				SET	memberStatus = 'Deleted',
					dateDeleted = #CreateODBCDateTime(now())#,
					deletedBy = <cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				WHERE memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfquery>

			<cfcatch>
				<cfset returnValue = cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue>
	</cffunction>
	<cffunction name="listMembers" access="remote" returntype="query" output="yes">
		<cfargument name="alpha" type="string" default="All" required="no">
		<cfargument name="search" type="string" default="~" required="no">
		<cfargument name="startCount" type="string" default="1" required="no">
		<cfargument name="displayCount" type="string" default="10" required="no">
		<cfargument name="memberID" type="string" default="~" required="no">
		<cfargument name="groupID" type="string" default="~" required="no">
		<cfargument name="groupName" type="string" default="~" required="no">
		<cfargument name="firstName" type="string" default="~" required="no">
		<cfargument name="middleName" type="string" default="~" required="no">
		<cfargument name="nickName" type="string" default="~" required="no">
		<cfargument name="lastName" type="string" default="~" required="no">
		<cfargument name="address" type="string" default="~" required="no">
		<cfargument name="city" type="string" default="~" required="no">
		<cfargument name="region" type="string" default="~" required="no">
		<cfargument name="country" type="string" default="~" required="no">
		<cfargument name="email" type="string" default="~" required="no">
		<cfargument name="phone" type="string" default="~" required="no">
		<cfargument name="groupType" type="string" default="~" required="no">
		<cfargument name="addressType" type="string" default="~" required="no">
		<cfargument name="addressStatus" type="string" default="~" required="no">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				SELECT	memberID,
						firstName,
						middleName,
						nickName,
						lastName,
						login,
						password,
						accessLevel,
						dateAdded,
						memberStatus,
						addressID,
						addressType,
						addressOrderID,
						address1,
						address2,
						IFNULL(city,'&nbsp;') AS City,
						IFNULL(region,'&nbsp;') AS region,
						postalCode,
						country,
						county,
						addressStatus,
						groupID,
						groupType,
						groupName,
						groupStatus,
						emailID,
						emailType,
						emailOrderID,
						email,
						emailStatus,
						phoneID,
						phoneType,
						phoneOrderID,
						phoneNumber,
						phoneStatus
				FROM listMembers
				WHERE memberID <> ''
				<cfif Trim(arguments.search) neq '~'>
					AND (
						firstName LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR lastName LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR address1 LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR address2 LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR city LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR region LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR postalCode LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR country LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR county LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR phoneNumber LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						OR email LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
					)
				</cfif>
				<cfif Trim(arguments.alpha) EQ '0-9'>
					AND Left(lastName, 1) IN  ('0','1','2','3','4','5','6','7','8','9','0')
				<cfelseif Trim(arguments.alpha) neq 'ALL'>
					AND Left(lastName, 1) = <cfqueryparam value="#arguments.alpha#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
				</cfif>
				<cfif Trim(arguments.memberID) neq '~'>
					AND memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.firstName) neq '~'>
					AND firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.middleName) neq '~'>
					AND middleName = <cfqueryparam value="#arguments.middleName#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.nickName) neq '~'>
					AND nickName = <cfqueryparam value="#arguments.nickName#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.lastName) neq '~'>
					AND lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif  Trim(arguments.groupID) neq '~'>
					AND groupID = <cfqueryparam value="#arguments.groupID#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif  Trim(arguments.groupName) neq '~'>
					AND groupName = <cfqueryparam value="#arguments.groupName#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.address) neq '~'>
					AND (
						address1 LIKE <cfqueryparam value="%#arguments.address#%" cfsqltype="CF_SQL_VARCHAR">
						OR address2 LIKE <cfqueryparam value="%#arguments.address#%" cfsqltype="CF_SQL_VARCHAR">
					)
				</cfif>
				<cfif Trim(arguments.city) neq '~'>
					AND city = <cfqueryparam value="#arguments.city#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.region) neq '~'>
					AND region = <cfqueryparam value="#arguments.region#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.country) neq '~'>
					AND country = <cfqueryparam value="#arguments.country#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.phone) neq '~'>
					AND phone LIKE <cfqueryparam value="%#arguments.phone#%" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.email) neq '~'>
					AND email LIKE <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.groupType) neq '~'>
					AND groupType LIKE <cfqueryparam value="#arguments.groupType#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.addressType) neq '~'>
					AND addressType LIKE <cfqueryparam value="#arguments.addressType#%" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif Trim(arguments.addressStatus) neq '~'>
					AND addressStatus = <cfqueryparam value="#arguments.addressStatus#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				ORDER BY 	lastName, 
							firstName, 
							middleName, 
							addressOrderID
				LIMIT #arguments.displayCount# OFFSET #arguments.startCount - 1#
			</cfquery>

			<cfcatch>
				<cfset thisQuery = #CFCATCH#>
			</cfcatch>
		</cftry>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="listMembersByMemberTypes" access="remote" returntype="query" output="yes">
		<cfargument name="alpha" type="string" default="All" required="no">
		<cfargument name="search" type="string" default="~" required="no">
		<cfargument name="startCount" type="string" default="1" required="no">
		<cfargument name="displayCount" type="string" default="10" required="no">
		<cfargument name="memberID" type="string" default="~" required="no">
		<cfargument name="groupID" type="string" default="~" required="no">
		<cfargument name="groupName" type="string" default="~" required="no">
		<cfargument name="firstName" type="string" default="~" required="no">
		<cfargument name="middleName" type="string" default="~" required="no">
		<cfargument name="nickName" type="string" default="~" required="no">
		<cfargument name="lastName" type="string" default="~" required="no">
		<cfargument name="address" type="string" default="~" required="no">
		<cfargument name="city" type="string" default="~" required="no">
		<cfargument name="region" type="string" default="~" required="no">
		<cfargument name="country" type="string" default="~" required="no">
		<cfargument name="email" type="string" default="~" required="no">
		<cfargument name="phone" type="string" default="~" required="no">
		<cfargument name="groupType" type="string" default="~" required="no">
		<cfargument name="addressType" type="string" default="~" required="no">
		<cfargument name="addressStatus" type="string" default="~" required="no">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				SELECT	memberID,
						firstName,
						middleName,
						nickName,
						lastName,
						login,
						password,
						accessLevel,
						dateAdded,
						memberStatus,
						addressID,
						addressType,
						addressOrderID,
						address1,
						address2,
						city,
						region,
						postalCode,
						country,
						county,
						addressStatus,
						groupID,
						groupType,
						groupName,
						groupStatus,
						emailID,
						emailType,
						emailOrderID,
						email,
						emailStatus,
						phoneID,
						phoneType,
						phoneOrderID,
						phoneNumber,
						phoneStatus,
						memberType
				FROM listMembersByType
				WHERE memberID <> ''
					<cfif Trim(arguments.search) neq '~'>
						AND (
							firstName LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR lastName LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR address1 LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR address2 LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR city LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR region LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR postalCode LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR country LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR county LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR phoneNumber LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
							OR email LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
						)
					</cfif>
					<cfif Trim(arguments.alpha) EQ '0-9'>
						AND Left(lastName, 1) IN  ('0','1','2','3','4','5','6','7','8','9','0')
					<cfelseif Trim(arguments.alpha) neq 'ALL'>
						AND Left(lastName, 1) = <cfqueryparam value="#arguments.alpha#" cfsqltype="CF_SQL_VARCHAR" maxlength="10">
					</cfif>
					<cfif Trim(arguments.memberID) neq '~'>
						AND memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.firstName) neq '~'>
						AND firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.middleName) neq '~'>
						AND middleName = <cfqueryparam value="#arguments.middleName#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.nickName) neq '~'>
						AND nickName = <cfqueryparam value="#arguments.nickName#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.lastName) neq '~'>
						AND lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif  Trim(arguments.groupID) neq '~'>
						AND groupID = <cfqueryparam value="#arguments.groupID#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif  Trim(arguments.groupName) neq '~'>
						AND groupName = <cfqueryparam value="#arguments.groupName#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.address) neq '~'>
						AND (
							address1 LIKE <cfqueryparam value="%#arguments.address#%" cfsqltype="CF_SQL_VARCHAR">
							OR address2 LIKE <cfqueryparam value="%#arguments.address#%" cfsqltype="CF_SQL_VARCHAR">
						)
					</cfif>
					<cfif Trim(arguments.city) neq '~'>
						AND city = <cfqueryparam value="#arguments.city#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.region) neq '~'>
						AND region = <cfqueryparam value="#arguments.region#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.country) neq '~'>
						AND country = <cfqueryparam value="#arguments.country#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.phone) neq '~'>
						AND phone LIKE <cfqueryparam value="%#arguments.phone#%" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.email) neq '~'>
						AND email LIKE <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.groupType) neq '~'>
						AND groupType LIKE <cfqueryparam value="#arguments.groupType#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.addressType) neq '~'>
						AND addressType LIKE <cfqueryparam value="#arguments.addressType#%" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<cfif Trim(arguments.addressStatus) neq '~'>
						AND addressStatus = <cfqueryparam value="#arguments.addressStatus#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					ORDER BY 	lastName, 
								firstName, 
								middleName, 
								addressOrderID
					LIMIT #arguments.displayCount# OFFSET #arguments.startCount - 1#
			</cfquery>

			<cfcatch>
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="createMember" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" default="#createUUID()#">
		<cfargument name="externalID" type="string" default="~" required="no">
		<cfargument name="addedBy" type="string" default="0" required="no">
		<cfargument name="firstName" type="string" default="~" required="no">
		<cfargument name="middleName" type="string" default="~" required="no">
		<cfargument name="nickName" type="string" default="~" required="no">
		<cfargument name="lastName" type="string" default="~" required="no">
		<cfargument name="login" type="string" default="~" required="no">
		<cfargument name="password" type="string" default="~" required="no">
		<cfargument name="passwordHint" type="string" default="~" required="no">
		<cfargument name="accessLevel" type="string" default="999999" required="no">
		<cfargument name="memberStatus" type="string"  default="pending" required="no">

		<cfset returnMessage = "">

		<!---------- START EXISTING MEMBER ---------->
			<cfset existingMember = checkExistingMember(login: arguments.login)>

			<cfif (existingMember neq 0) >
				<cfset returnMessage = existingMember>
			</cfif>
		<!---------- END EXISTING MEMBER ---------->

		<!---------- START NEW MEMBER SUMBIT ---------->
			<cfif NOT returnMessage contains "|">
				<cftry>
					<cfquery datasource="#application.dbName#">
						INSERT INTO members(
							memberID, 
							<cfif trim(arguments.externalID) neq '~'>
								externalID,
							</cfif>
							addedBy, 
							<cfif trim(arguments.firstName) neq '~'>
								firstName,
							</cfif>
							<cfif trim(arguments.middleName) neq '~'>
								middleName,
							</cfif>
							<cfif trim(arguments.nickName) neq '~'>
								nickName,
							</cfif>
							<cfif trim(arguments.firstName) neq '~'>
								LastName,
							</cfif>
							<cfif trim(arguments.login) neq '~'>
								login,
							</cfif>
							<cfif trim(arguments.password) neq '~'>
								password,
							</cfif>
							<cfif trim(arguments.passwordHint) neq '~'>
								passwordHint,
							</cfif>
							<cfif trim(arguments.accessLevel) neq '~'>
								accessLevel,
							</cfif>
							dateAdded
						)
						VALUES(
							<cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="40">, 
							<cfif trim(arguments.externalID) neq '~'>
								<cfqueryparam value="#arguments.externalID#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							'1', 
							<cfif trim(arguments.firstName) neq '~'>
								<cfqueryparam value="#arguments.firstName#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.middleName) neq '~'>
								<cfqueryparam value="#arguments.middleName#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.nickName) neq '~'>
								<cfqueryparam value="#arguments.nickName#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.firstName) neq '~'>
								<cfqueryparam value="#arguments.LastName#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.login) neq '~'>
								<cfqueryparam value="#arguments.login#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.password) neq '~'>
								<cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.passwordHint) neq '~'>
								<cfqueryparam value="#arguments.passwordHint#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfif trim(arguments.accessLevel) neq '~'>
								<cfqueryparam value="#arguments.accessLevel#" cfsqltype="CF_SQL_VARCHAR">,
							</cfif>
							<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="CF_SQL_TIMESTAMP">
						)
					</cfquery>

					<cfcatch>
						<cfset returnMessage = "ERROR|" & CFCATCH.Detail>
					</cfcatch>
				</cftry>

				<cfscript>
					/********** START MEMBER UPDATE **********/
						returnMessage = setMember(
							memberID: arguments.memberID, 
							externalID = arguments.externalID,
							firstName = arguments.firstName, 
							middleName = arguments.middleName, 
							nickName = arguments.nickName, 
							lastName = arguments.lastName, 
							login = arguments.login, 
							password = arguments.password, 
							passwordHint = arguments.passwordHint, 
							accessLevel = arguments.accessLevel, 
							memberStatus = arguments.memberStatus
						);
					/********** END MEMBER UPDATE **********/
				</cfscript>
			</cfif>
		<!---------- START NEW MEMBER SUMBIT ---------->

		<cfscript>
			if(returnMessage contains "|") { return listLast(returnMessage, '|'); } else { return arguments.memberID; }
		</cfscript>
	</cffunction>
	<cffunction name="checkExistingMember" access="remote" returntype="string" output="yes">
		<cfargument name="login" type="string" default="~" required="no">

		<cfset returnMessage = "0">

		<cftry>
			<cfquery name="memberLookup" datasource="#application.dbName#">
				SELECT memberID
				FROM members
				WHERE login = <cfqueryparam value="#arguments.login#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			</cfquery>

			<cfif memberLookup.recordCount neq 0>
				<cfset returnMessage = 'ERROR|The login <em>"' & arguments.login & '"</em> already exists. '>
			</cfif>

			<cfcatch>
				<cfset returnMessage = "ERROR|" & CFCATCH.Detail>
			</cfcatch>
		</cftry>

		<cfreturn returnMessage>
	</cffunction>
	<cffunction name="setMember" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="externalID" type="string" default="~" required="no">
		<cfargument name="studentID" type="string" default="~" required="no">
		<cfargument name="firstName" type="string" default="~" required="no">
		<cfargument name="middleName" type="string" default="~" required="no">
		<cfargument name="nickName" type="string" default="~" required="no">
		<cfargument name="lastName" type="string" default="~" required="no">
		<cfargument name="login" type="string" default="~" required="no">
		<cfargument name="password" type="string" default="~" required="no">
		<cfargument name="passwordHint" type="string" default="~" required="no">
		<cfargument name="accessLevel" type="string" default="~" required="no">
		<cfargument name="memberStatus" type="string" default="pending">

		<cfset returnMessage = "200">

		<!--- <cfdump var="#arguments#"> --->

		<cftry>
			<cfquery datasource="#application.dbName#">
				UPDATE members
				SET dateUpdated = #CreateODBCDateTime(now())#
					<cfif trim(arguments.externalID) neq '~'>, externalID = <CFQUERYPARAM VALUE="#arguments.externalID#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.studentID) neq '~'>, studentID = <cfqueryparam value="#arguments.studentID#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"></cfif>
					<cfif trim(arguments.firstName) neq '~'>, firstName = <CFQUERYPARAM VALUE="#arguments.firstName#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.middleName) neq '~'>, middleName = <CFQUERYPARAM VALUE="#arguments.middleName#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.nickName) neq '~'>, nickName = <CFQUERYPARAM VALUE="#arguments.nickName#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.lastName) neq '~'>, lastName = <CFQUERYPARAM VALUE="#arguments.lastName#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.login) neq '~'>, login = <CFQUERYPARAM VALUE="#arguments.login#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="100"></cfif>
					<cfif trim(arguments.password) neq '~'>, password = <CFQUERYPARAM VALUE="#arguments.password#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="45"></cfif>
					<cfif trim(arguments.passwordHint) neq '~'>, passwordHint = <CFQUERYPARAM VALUE="#arguments.passwordHint#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.accessLevel) neq '~'>, accessLevel = <CFQUERYPARAM VALUE="#arguments.accessLevel#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
					<cfif trim(arguments.memberStatus) neq '~'>, memberStatus = <CFQUERYPARAM VALUE="#arguments.memberStatus#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="50"></cfif>
				WHERE MemberID = <CFQUERYPARAM VALUE="#arguments.memberID#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH="40">
			</cfquery>

			<cfcatch>
				<cfset returnMessage = "ERROR|" & CFCATCH.Detail>
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>

		<cfreturn returnMessage>
	</cffunction>
	<cffunction name="getMemberStatusOptions" access="remote" returntype="string" output="yes">
		<cfargument name="memberStatus" type="string" required="yes">

		<cfset statusList = 'Active,Pending,Inactive,Deleted'>

		<cfset returnMessage = ''>

		<cfloop index="i" list="#statusList#" delimiters=",">
			<cfif i eq arguments.memberStatus>
				<cfset isSelected = ' selected'>
			<cfelse>
				<cfset isSelected = ''>
			</cfif>

			<cfset returnMessage = returnMessage & '<option value="' & i & '" ' & isSelected & '>' & i & '</option>' & chr(10)>
		</cfloop>

		<cfreturn returnMessage>
	</cffunction>
	<cffunction name="createDemographics" access="remote" returntype="string" output="yes">
		<cfargument name="externalID" type="string" default="~">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="demographicStatus" type="string" default="Active">
		<cftry>
			<cfset thisUUID = createUUID()>

			<cfquery datasource="#application.dbName#">
				INSERT INTO memberDemographics (
					demographicID, 
					<cfif Trim(arguments.externalID) neq '~'>externalID,</cfif>
					memberID, 
					dateAdded, 
					addedBy, 
					demographicStatus
				)
				VALUES(
					<cfqueryparam value="#thisUUID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">, 
					<cfif Trim(arguments.externalID) neq '~'><cfqueryparam value="#arguments.externalID#" cfsqltype="CF_SQL_VARCHAR">, </cfif>
					<cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">, 
					<cfqueryparam value="#createODBCDateTime(now())#" CFSQLTYPE="CF_SQL_TIMESTAMP">, 
					<cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					<cfqueryparam value="#arguments.demographicStatus#" cfsqltype="CF_SQL_VARCHAR">
				)
			</cfquery>

			<cfset returnValue = 1>

			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfset returnValue = "Error|" & cfcatch.detail>
			</cfcatch>
		</cftry>
		<cfreturn returnValue>
	</cffunction>
	<cffunction name="setDemographics" access="remote" returntype="string" output="yes">
		<cfargument name="demographicID" type="string" required="yes">
		<cfargument name="externalID" type="string" default="~">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="dateOfBirth" type="any" default="0">
		<cfargument name="sex" type="string" default="~">
		<cfargument name="race" type="string" default="~">
		<cfargument name="onPublicAssistance" type="numeric" default="99999999">
		<cfargument name="income" type="any" default="99999999">
		<cfargument name="incomePeriod" type="string" default="365">
		<cfargument name="hoursEmployedPerWeek" type="numeric" default="99999999">
		<cfargument name="numberPerHouseHold" type="numeric" default="99999999">
		<cfargument name="immigrant" type="numeric" default="99999999">
		<cfargument name="englishAsASecondLanguage" type="numeric" default="99999999">
		<cfargument name="educationLevel" type="string" default="">
		<cfargument name="adultBasicEducation" type="numeric" default="99999999">
		<cfargument name="adultSecondaryEducation" type="numeric" default="99999999">
		<cfargument name="educatedOutsideUS" type="numeric" default="99999999">
		<cfargument name="educatedInsideUS" type="numeric" default="99999999">
		<cfargument name="financialLiteracy" type="numeric" default="99999999">
		<cfargument name="healthLiteracy" type="numeric" default="99999999">
		<cfargument name="familyLiteracy" type="numeric" default="99999999">
		<cfargument name="demographicStatus" type="string" default="Active">

		<!---------- START UPDATE QUERY ---------->
			<cfset returnValue = '1'>

			<cftry>
				<cfquery datasource="#application.dbName#">
					UPDATE memberDemographics
					SET	
						<cfif arguments.externalID neq '~'>externalID = <cfqueryparam value="#arguments.externalID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,</cfif>
						<cfif isDate(arguments.dateOfBirth)>dateOfBirth = <cfqueryparam value="#arguments.dateOfBirth#" CFSQLTYPE="CF_SQL_TIMESTAMP">,</cfif>
						<cfif arguments.sex neq '~'>sex = <cfqueryparam value="#arguments.sex#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,</cfif>
						<cfif arguments.race neq '~'>race = <cfqueryparam value="#arguments.race#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,</cfif>
						<cfif arguments.onPublicAssistance neq '99999999'>onPublicAssistance = <cfqueryparam value="#arguments.onPublicAssistance#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif isNumeric(arguments.income) and arguments.income neq '99999999'>income = <cfqueryparam value="#arguments.income#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,</cfif>
						<cfif arguments.incomePeriod neq '~'>incomePeriod = <cfqueryparam value="#arguments.incomePeriod#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,</cfif>
						<cfif arguments.hoursEmployedPerWeek neq '99999999'>hoursEmployedPerWeek = <cfqueryparam value="#arguments.hoursEmployedPerWeek#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.numberPerHouseHold neq '99999999'>numberPerHouseHold = <cfqueryparam value="#arguments.numberPerHouseHold#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.immigrant neq '99999999'>immigrant = <cfqueryparam value="#arguments.immigrant#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.englishAsASecondLanguage neq '99999999'>englishAsASecondLanguage = <cfqueryparam value="#arguments.englishAsASecondLanguage#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						educationLevel = <cfqueryparam value="#arguments.educationLevel#" cfsqltype="CF_SQL_VARCHAR">,
						<cfif arguments.adultBasicEducation neq '99999999'>adultBasicEducation = <cfqueryparam value="#arguments.adultBasicEducation#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.adultSecondaryEducation neq '99999999'>adultSecondaryEducation = <cfqueryparam value="#arguments.adultSecondaryEducation#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.educatedOutsideUS neq '99999999'>educatedOutsideUS = <cfqueryparam value="#arguments.educatedOutsideUS#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.educatedInsideUS neq '99999999'>educatedInsideUS = <cfqueryparam value="#arguments.educatedInsideUS#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.financialLiteracy neq '99999999'>financialLiteracy = <cfqueryparam value="#arguments.financialLiteracy#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.healthLiteracy neq '99999999'>healthLiteracy = <cfqueryparam value="#arguments.healthLiteracy#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						<cfif arguments.familyLiteracy neq '99999999'>familyLiteracy = <cfqueryparam value="#arguments.familyLiteracy#" cfsqltype="CF_SQL_INTEGER">,</cfif>
						dateUpdated = #createODBCDateTime(now())#,
						updatedBy = '1',
						demographicStatus = <cfqueryparam value="#arguments.demographicStatus#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
					WHERE demographicID = <cfqueryparam value="#arguments.demographicID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
					AND memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				</cfquery>

				<cfcatch>
					<cfset returnValue = "Error|" & cfcatch.detail>
					<cfdump var="#cfcatch#">
				</cfcatch>
			</cftry>
		<!---------- END UPDATE QUERY  ---------->

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="createMemberEthnicities" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="ethnicityID" type="string" required="yes">
		<cfargument name="memberEthnicityStatus" type="string" default="Active" required="no">

		<cfset returnValue = '200'>

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				INSERT INTO memberEthnicity(
					memberID,
					ethnicityID,
					dateAdded,
					addedBy,
					memberEthnicityStatus
				)
				VALUES (
					<cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.ethnicityID#" cfsqltype="CF_SQL_VARCHAR">,
					#CreateODBCDateTime(now())#,
					<cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.memberEthnicityStatus#" cfsqltype="CF_SQL_VARCHAR">
				) 
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" & cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="deleteMemberEthnicities" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset returnvalue = '200'>

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE memberEthnicity
				SET	memberEthnicityStatus = 'Deleted',
					dateDeleted = #CreateODBCDateTime(now())#
				WHERE memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
				AND memberEthnicityStatus = 'Active'
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" & cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="getMemberEthnicities" access="remote" returntype="query" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfquery name="thisQuery" datasource="#application.dbName#">
			SELECT	E.ethnicityID,
					E.ethnicity,
					(
						SELECT COUNT(memberEthnicityID) AS C
						FROM  memberEthnicity ME 
						WHERE ME.ethnicityID = E.ethnicityID
						AND ME.memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
						AND NOT memberEthnicityStatus IN ('Pending','Inactive','Deleted')
					) AS selected
			FROM ethnicities E
			WHERE NOT E.ethnicityStatus IN ('Pending','Inactive','Deleted')
		</cfquery>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="getEthnicitieOptions" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset ethnicities = getMemberEthnicities(memberID: arguments.memberID)>

		<cfset returnMessage = ''>

		<cfoutput query="ethnicities">
			<cfif ethnicities.selected gt 0>
				<cfset isSelected = ' selected'>
			<cfelse>
				<cfset isSelected = ''>
			</cfif>

			<cfset returnMessage = returnMessage & '<option value="' & ethnicities.ethnicityID & '" ' & isSelected & '>' & ethnicities.ethnicity & '</option>' & chr(10)>
		</cfoutput>
		<cfreturn returnMessage>
	</cffunction>
	<cffunction name="getMemberIncome" access="remote" returntype="query" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="memberIncomeStatus" type="string" default="Active">

		<cfquery name="thisQuery" datasource="#application.dbName#">
			SELECT	memberIncomeID,
					incomeID,
					income,
					incomePeriod,
					membersPerHousehold,
					memberIncomeStatus
					
			FROM memberIncomes MI
			WHERE	memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
			AND memberIncomeStatus = <cfqueryparam value="#arguments.memberIncomeStatus#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="getMemberIncomePeriodOptions" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset memberIncome = getMemberIncome(memberID: arguments.memberID)>

		<cfset incomePeriodList = 'Day,Week,Two Weeks,Twice a Month,Month,Quarter,Year'>
		<cfset incomePeriodInDaysList = '1,7,14,15,30,90,365'>

		<cfset returnValue = ''>

		<cfloop index="I" from="1" to="#ListLen(incomePeriodList)#" step="1">
			<cfif ListGetAt(incomePeriodInDaysList, I) eq memberIncome.incomePeriod>
				<cfset isSelected = ' selected'>
			<cfelse>
				<cfset isSelected = ''>
			</cfif>
		
			<cfset returnValue = returnValue & '<option value="' & ListGetAt(incomePeriodInDaysList, I) & '"' & isSelected & '>' & ListGetAt(incomePeriodList, I) & '</option>' & chr(10)>
		</cfloop>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="getMembersPerHouseholdOptions" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset memberIncome = getMemberIncome(memberID: arguments.memberID)>

		<cfset returnValue = ''>

		<cfloop index="I" from="1" to="20" step="1">
			<cfif I eq memberIncome.membersPerHousehold>
				<cfset isSelected = ' selected'>
			<cfelse>
				<cfset isSelected = ''>
			</cfif>

			<cfset returnValue = returnValue & '<option value="' & I & '"' & isSelected & '>' & i & '</option>' & chr(10)>
		</cfloop>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="deleteMemberIncome" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">

		<cfset returnValue = 200>

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE memberIncomes 
				SET	dateDeleted = #CreateODBCDateTime(now())#,
					deletedBy = <cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					memberIncomeStatus = 'Deleted'
				WHERE	memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfcatch>
				<cfset returnValue = "ERROR|" & cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="createMemberIncome" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="incomeID" type="numeric" default="0" required="no">
		<cfargument name="income" type="any" default="0">
		<cfargument name="incomePeriod" type="numeric" default="365" required="no">
		<cfargument name="membersPerHousehold" type="numeric" default="1">
		<cfargument name="memberIncomeStatus" type="string" default="Active">

		<cfset returnValue = 200>

		<cfif NOT isNumeric(arguments.income)>
			<cfset arguments.income = 0>
		</cfif>

		<cfset returnValue = deleteMemberIncome(
			memberID: arguments.memberID
		)>

		<cfif returnValue eq 200>
			<cftry>
				<cfquery name="thisQuery" datasource="#application.dbName#">
					INSERT INTO memberIncomes (
						memberID,
						incomeID,
						income, 
						incomePeriod,
						membersPerHousehold,
						dateAdded,
						addedBy, 
						memberIncomeStatus
					)
					VALUES (
						<cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.incomeID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.income#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.incomePeriod#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#arguments.membersPerHousehold#" cfsqltype="CF_SQL_INTEGER">,
						#CreateODBCDateTime(now())#,
						<cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.memberIncomeStatus#" cfsqltype="CF_SQL_VARCHAR">
					)
				</cfquery>
				
				<cfcatch>
					<cfset returnValue = "ERROR|" & cfcatch.detail>
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="createMemberType" access="remote" returntype="string" output="yes">
		<cfargument name="memberTypeID" type="string" default="#createUUID()#" required="no">
		<cfargument name="memberType" type="string" required="yes">
		<cfargument name="orderID" type="numeric" default="999999">

		<cfset returnValue = "200">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				INSERT INTO memberTypes (
					memberTypeID,
					orderID,
					memberType,
					dateAdded,
					addedBy,
					memberTypeStatus
				)
				VALUES (
					<cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.orderID#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.memberType#" cfsqltype="CF_SQL_VARCHAR">,
					#CreateODBCDateTime(now())#,
					<cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					'Active'
				)
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" &  cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="setMemberType" access="remote" returntype="string" output="yes">
		<cfargument name="memberTypeID" type="string" required="yes">
		<cfargument name="memberType" type="string" required="yes">
		<cfargument name="orderID" type="numeric" default="999999" required="no">
		<cfargument name="memberTypeStatus" type="string" required="yes">

		<cfset returnValue = "200">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE memberTypes 
				SET	memberType = <cfqueryparam value="#arguments.memberType#" cfsqltype="CF_SQL_VARCHAR">,
					orderID	= <cfqueryparam value="#arguments.orderID#" cfsqltype="CF_SQL_INTEGER">
					dateUpdated = #CreateODBCDateTime(now())#,
					updatedBy = <cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					memberTypeStatus = <cfqueryparam value="#arguments.memberTypeStatus#" cfsqltype="CF_SQL_VARCHAR">
				WHERE memberTypeID = <cfqueryparam value="#arguments.memberTypeStatus#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" &  cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="deleteMemberType" access="remote" returntype="string" output="yes">
		<cfargument name="memberTypeID" type="string" required="yes">
		<cfargument name="memberType" type="string" required="yes">

		<cfset returnValue = "200">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE memberTypes 
				SET	dateDeleted = #CreateODBCDateTime(now())#,
					deletedBy = <cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					memberTypeStatus = 'Deleted'
				WHERE memberTypeID = <cfqueryparam value="#arguments.memberTypeStatus#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" &  cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="getMemberTypes" access="remote" returntype="query" output="yes">
		<cfargument name="memberTypeStatus" type="string" required="no">
		<cfargument name="memberID" type="string" default="0" required="no">

		<cfquery name="thisQuery" datasource="#application.dbName#">
			SELECT	MT.memberTypeID,
					MT.memberType,
					MT.orderID,
					(
						SELECT Count(MTS.memberTypeSelected) AS C
						FROM memberTypeSelected MTS
						WHERE MTS.memberTypeID = MT.memberTypeID
						AND MTS.memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
					) AS selected,
					MT.memberTypeStatus
			FROM memberTypes MT
			WHERE MT.memberTypeID <> ''
			<cfif arguments.memberTypeStatus neq ''>
				AND (
					<cfloop index="L" from="1" to="#ListLen(arguments.memberTypeStatus)#" step="1">
						<cfif L neq 1>OR </cfif>
						MT.memberTypeStatus = <cfqueryparam value="#ListGetAt(arguments.memberTypeStatus, L)#" cfsqltype="CF_SQL_VARCHAR">
					</cfloop>
				)
			</cfif>
			ORDER BY MT.orderID ASC
		</cfquery>

		<cfreturn thisQuery>
	</cffunction>
	<cffunction name="getMemberTypeOptions" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="memberTypeStatus" type="string" default="Active" required="no">

		<cfset memberTypes = getMemberTypes (
				memberTypeStatus = arguments.memberTypeStatus,
				memberID = arguments.memberID
		)>

		<cfset returnValue = ''>

		<cfloop query="memberTypes">
			<cfif memberTypes.selected neq 0>
				<cfset isSelected = ' selected'>
			<cfelse>
				<cfset isSelected =''>
			</cfif>

			<cfset returnValue = returnValue & '<option value="' & memberTypes.memberTypeID & '" ' & isSelected & '>' & memberTypes.memberType & '</option>' & chr(10)>
		</cfloop>

		<cfreturn returnValue />
	</cffunction>
	<cffunction name="deleteMemberTypeSelected" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="memberTypeID" type="string" required="yes">

		<cfset returnValue = '200'>

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				UPDATE memberTypeSelected
				SET	dateDeleted = #CreateODBCDateTime(now())#,
					deletedBy = <cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					memberTypeSelectedStatus = 'Deleted'
				WHERE memberID = <cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">
				AND	memberTypeID = <cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" &  cfcatch.detail>
			</cfcatch>
		</cftry>
		<cfreturn returnValue />
	</cffunction>
	<cffunction name="createMemberTypeSelected" access="remote" returntype="string" output="yes">
		<cfargument name="memberID" type="string" required="yes">
		<cfargument name="memberTypeID" type="string" required="Yes">

		<cfset returnValue = "200">

		<cftry>
			<cfquery name="thisQuery" datasource="#application.dbName#">
				INSERT INTO memberTypeSelected (
					memberID,
					memberTypeID,
					dateAdded,
					addedBy,
					memberTypeSelectedStatus
				)
				VALUES (
					<cfqueryparam value="#arguments.memberID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.memberTypeID#" cfsqltype="CF_SQL_VARCHAR">,
					#CreateODBCDateTime(now())#,
					<cfqueryparam value="#getCurrentUser().memberID#" cfsqltype="CF_SQL_VARCHAR">,
					'Active'
				)
			</cfquery>

			<cfcatch>
				<cfset returnValue = "Error|" &  cfcatch.detail>
			</cfcatch>
		</cftry>

		<cfreturn returnValue>
	</cffunction>
</cfcomponent>
