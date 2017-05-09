/********** BEGIN DOCUMENT **********/
	jQuery( document ).ready(
		function() {
			// START TRANSACTIONS
			getTransactions( { "data" : { "method" : "getTransactions", "creditDebitDate" : "01/04/2016" } }  );

			$( ".transactions" ).html(
				buildTransactions( global.data.transactions )
			);
		}
	);
/********** END DOCUMENT **********/

/********** BEGIN FUNCTIONS **********/
	function getTransactions( json ) {
		/***** BEGIN DEFAULT VALUES *****/
			t = '';
			thisFunctionName = "getTransactions()";
		/***** END DEFAULT VALUES *****/
		
		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : thisFunctionName } );
		/***** END LOG *****/
	
		/***** START AJAX *****/
			if ( /^1\d{3}$/.test( getLoggingStatusCode() ) ) {
				try {
					/***** BEGIN VENDOR LOOKUP *****/
						jQuery.ajax(
							{
								type: "GET", 
								url: "/com/modules/transactions.cfc",
								data : json.data,
								async : false,
								contentType: "application/json; charset=utf-8",
								dataType: "json", 
								cache: false,
								success: function( data, textStatus, jqXHR ){
									/****** START DATA PROCESS *****/
										if ( /^1\d{3}$/.test( data.statusCode ) ) {
											// WRITE RESULT TO GLOBAL.DATA 
											global.data.transactions = data;
										}
										else {
											/***** BEGIN LOG *****/
												setLoggingRecord( { "type" : "error", "statusCode" : data.statusCode, "title" : "Error", "message" : data.message, "continue" : false, "trace" : data } );
											/***** END LOG *****/
										}
									/****** END DATA PROCESS *****/
								}, 
								error: function( xhr, ajaxoptions, thrownError ) {
									/***** BEGIN LOG *****/
										setLoggingRecord( { "type" : "error", "statusCode" : 5000, "title" : "Error", "message" : thrownError, "continue" : false, "trace" : xhr } );
									/***** END LOG *****/
								}
							}
						);
					/***** END VENDOR LOOKUP *****/
				}
				catch ( e ) {
					/***** START ERROR MESSAGE *****/
						setLoggingRecord( { "type" : "error", "statusCode" : 5000, "title" : "Error", "message" : "Error Running " + thisFunctionName, "continue" : false, "trace" : e } );
					/***** END ERROR MESSAGE *****/
				}
			}
		/***** END AJAX *****/

		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : thisFunctionName } );
		/***** END LOG *****/
	}
	
	function buildTransactions( json ) {
		/***** BEGIN DEFAULT VALUES *****/
			t = '';
			thisFunctionName = "buildTransactions()";
		/***** END DEFAULT VALUES *****/
		
		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : thisFunctionName } );
		/***** END LOG *****/
	
		/***** START AJAX *****/
			if ( /^1\d{3}$/.test( getLoggingStatusCode() ) ) {
				try {
					/***** START DATAGRID *****/
						t += '<article>';
							t += '<header>';
								t += '<span>Title</span>';
								t += '<span>Institution</span>';
								t += '<span>Check</span>';
								t += '<span>Account</span>';
								t += '<span>Vendor</span>';
								t += '<span>Business</span>';
								t += '<span>Deductable</span>';
								t += '<span>Debit</span>';
								t += '<span>Credit</span>';
								t += '<span>Balance</span>';
								t += '<span>Date</span>';
								t += '<span>Status</span>';
							t += '</header>';
							t += '<section>';
								balanceTotal = 0;
								creditTotal = 0;
								debitTotal = 0;
								
								for( A in global.data.transactions.results ) {
									t += '<article ref="' + global.data.transactions.results[ A ].creditDebitID + '" parentID="' + global.data.transactions.results[ A ].parentID + '">';
										t += '<header>' + global.data.transactions.results[ A ].creditDebitDescription + '</header>';
										t += '<span>' + global.data.transactions.results[ A ].creditDebitTitle + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].institutionName + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].checkNumber + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].accountType + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].vendorName + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].isBusiness + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].isDeductable + '</span>';
										t += '<span>';
											if ( global.data.transactions.results[ A ].isDebit ) {
												t += global.data.transactions.results[ A ].amount.toFixed(2);
												debitTotal = debitTotal + global.data.transactions.results[ A ].amount;
												balanceTotal = balanceTotal - global.data.transactions.results[ A ].amount
											} 
										t += '</span>';
										t += '<span>';
											if ( !global.data.transactions.results[ A ].isDebit ) {
												t += global.data.transactions.results[ A ].amount.toFixed(2);
												creditTotal = creditTotal + global.data.transactions.results[ A ].amount;
												balanceTotal = balanceTotal + global.data.transactions.results[ A ].amount;
											}
										t += '</span>';
										t += '<span>';
											t += balanceTotal.toFixed(2) ;
										t += '</span>';
										t += '<span>' + global.data.transactions.results[ A ].creditDebitDate + '</span>';
										t += '<span>' + global.data.transactions.results[ A ].creditDebitStatus + '</span>';
										t += '<footer></footer>';
									t += '</article>';
								}
							t += '</section>';
							t += '<footer>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span></span>';
								t += '<span>Date</span>';
								t += '<span>Status</span>';
							t += '</footer>';
						t += '</article>';
					/***** END DATAGRID *****/
				}
				catch ( e ) {
					console.log(e);
					/***** START ERROR MESSAGE *****/
						setLoggingRecord( { "type" : "error", "statusCode" : 5000, "title" : "Error", "message" : "Error Running " + thisFunctionName, "continue" : false, "trace" : e } );
					/***** END ERROR MESSAGE *****/
				}
			}
		/***** END AJAX *****/

		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : thisFunctionName } );
		/***** END LOG *****/
		
		return t;
	}
/********** END FUNCTIONS **********/