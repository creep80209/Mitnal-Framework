component displayname="template.cfc" hint="this is just a valued template" output="true"
{
	remote struct function one(
		string thisValue="???"
	)
	 displayname="one function"
	 description="one function"
	 hint="one"
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
				"eventName" : "/com//",
				"arguments" : [
					"name" : { "value" : "", "type" : "numeric", "default": "", "required" : true, "description" : "" }
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
						local.queryService.setDatasource( application.dsn );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
						local.queryService.addParam( name="", value=arguments.thisValue, cfsqltype="cf_sql_integer" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = "
							SELECT
							FROM
							WHERE 1=1
						";

						// ADD ARGUMENT
						/*
						if ( trim( arguments.rmaid ) != "0" ) {
							local.queryService.sqlString &= "
								AND rma.parent_rma_pk = :_rmaid_
							";
						}
						*/

						// ADD ORDER BY TO QUERY
						local.queryService.sqlString &= "
							ORDER BY
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
								"" : local.A[ "" ]
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