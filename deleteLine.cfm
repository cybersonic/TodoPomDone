<cfparam name="url.line" default="0">
	
<cfif url.line GT 0>
	<cfset counter=1>
	<cfloop file="#application.todofile#" index="l">
		<cfif counter NEQ url.line>
			<cffile action="append" file="#application.todofile#_temp" output="#l#">
		</cfif>
		<cfset counter++>
	</cfloop>
	<cffile action="copy" source="#application.todofile#_temp" destination="#application.todofile#">	
	<cffile action="delete" file="#application.todofile#_temp">	
</cfif>
<cflocation url="index.cfm" addtoken="false">