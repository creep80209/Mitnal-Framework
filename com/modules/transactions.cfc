component displayname="transactions.cfc" hint="transaction management" output="true"
{
	remote struct function getTransactions(
		any creditDebitID = "~", 
		any parentID = "~", 
		any institutionID = "~", 
		any groupName = "~", 
		any accountTypeID = "~", 
		any accountType = "~", 
		any vendorID = "~", 
		any vendorName = "~", 
		any isDebit = "~", 
		any isBusiness = "~", 
		any isDeductable = "~", 
		any checkNumber = "~", 
		any amount = "~", 
		any creditDebitTitle = "~", 
		any creditDebitDescription = "~", 
		any creditDebitDate = "~", 
		any creditDebitDateRange = "~", 
		any creditDebitStatus = "Active"
	)
	 displayname=""
	 description=""
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/modules/transactions/getTransactions",
				"arguments" : [
					"name" : { 
						"value" : "", "type" : "numeric", "default": "", "required" : true, "description" : "", 
						"validation" : [
							{ "type" : "string", "message" : "is blank or null;" }
						]
					}
				]
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/


			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.data.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN QUERY **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY INIT **********/
						local.queryService = new query();
						local.queryService.setDatasource( "accounting" );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
//						local.queryService.addParam( name="", value=arguments., cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="creditDebitDate", value=arguments.creditDebitDate, cfsqltype="cf_sql_date" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = "
							SELECT	CD.creditDebitID, 
									CD.parentID, 
									CD.institutionID, 
									(
										SELECT I.groupName
										FROM groups I
										WHERE I.groupID =  CD.institutionID
									) AS institutionName,
									CD.accountTypeID,
									(
										SELECT AT.accountType
										FROM accountTypes AT
										WHERE AT.accountTypeID = CD.accountTypeID
									) AS accountType,
									CD.vendorID, 
									(
										SELECT V.groupName
										FROM groups V
										WHERE V.groupID =  CD.vendorID
									) AS vendorName, 
									CD.isDebit, 
									CD.isBusiness, 
									CD.isDeductable, 
									CD.checkNumber, 
									CD.amount, 
									CD.creditDebitTitle, 
									CD.creditDebitDescription, 
									CD.creditDebitDate, 
									CD.creditDebitStatus
							FROM accounting.creditDebit CD
							WHERE 1 = 1
						";

						// ADD ARGUMENT
						/*
						if ( trim( arguments. ) != "0" ) {
							local.queryService.sqlString &= "
								AND . = :
							";
						}
						*/

						// ADD ARGUMENT
						if ( trim( arguments.creditDebitDate ) != "~" ) {
							local.queryService.sqlString &= "
								AND CD.creditDebitDate = :creditDebitDate
							";
						}

						// ADD ORDER BY TO QUERY
						local.queryService.sqlString &= "
							ORDER BY	CD.creditDebitDate,
										CD.creditDebitTitle, 
										CD.creditDebitID
						";
					/***** END QUERY STRING *****/

					/***** BEGIN QUERY EXECUTE *****/
						local.queryResult = local.queryService.execute( sql=local.queryService.sqlString );
					/***** END QUERY EXECUTE *****/

					/***** BEGIN QUERY RESULTS *****/
						local.queryMetaData = local.queryResult.getPrefix();
						local.thisQuery = local.queryResult.getResult();
					/***** END QUERY RESULTS *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END QUERY **********/

		/********** BEGIN OUPUT **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY LOOP *****/
						local.thisCountA = 1;
						for ( local.A IN local.thisQuery  ) {
							local.returnValue["results"][ local.thisCountA ] = {
								"creditDebitID" : local.A[ "creditDebitID" ],
								"parentID" : local.A[ "parentID" ],
								"institutionID" : local.A[ "institutionID" ],
								"institutionName" : local.A[ "institutionName" ],
								"accountTypeID" : local.A[ "accountTypeID" ],
								"accountType" : local.A[ "accountType" ],
								"vendorID" : local.A[ "vendorID" ],
								"vendorName" : local.A[ "vendorName" ],
								"isDebit" : local.A[ "isDebit" ],
								"isBusiness" : local.A[ "isBusiness" ],
								"isDeductable" : local.A[ "isDeductable" ],
								"checkNumber" : local.A[ "checkNumber" ],
								"amount" : local.A[ "amount" ],
								"creditDebitTitle" : local.A[ "creditDebitTitle" ],
								"creditDebitDescription" : local.A[ "creditDebitDescription" ],
								"creditDebitDate" : DateFormat( local.A[ "creditDebitDate" ],  'MM/DD/YYYY'),
								"creditDebitStatus" : local.A[ "creditDebitStatus" ]
							};
							local.thisCountA++;
						}
					/***** END QUERY LOOP *****/

					/***** BEGIN RECORD COUNT UPDATE *****/
						local.returnValue.totalRows = local.queryMetaData.recordCount;
					/***** END RECORD COUNT UPDATE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					//writeLog( file=application.applicationname, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END OUPUT **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
}