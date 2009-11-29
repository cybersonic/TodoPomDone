<cfparam name="form.action" default="">
<cfparam name="form.row" default="0">
<cfswitch expression="#FORM.action#">
	<cfcase value="markAsDone">
			<cfset newFile = "">
			<cfset counter = 1>
			<cfloop file="#application.todofile#" index="line">
				<cfset newline = line>
				<cfif counter EQ FORM.row>
					<cfset newline = "DONE #newline#">
				</cfif>
				<cfoutput>#newline#</cfoutput>
				<cffile action="append" file="#application.todofile#_temp" output="#newline#">
				<cfset counter++>
			</cfloop>
			<cffile action="copy" source="#application.todofile#_temp" destination="#APPLICATION.todofile#">
			<cffile action="delete" file="#application.todofile#_temp">
	</cfcase>
	<cfcase value="newItem">
		<cf_todoParser rTodo="qTodo">
		
		<cfif NOT qTodo.recordcount>
				<cffile action="append" file="#application.todofile#" output="#LSDateFormat(NOW(),"short")#">
		</cfif>
		<cf_todoParser rTodo="qTodo">
		<cfquery name="getMaxDate" dbtype="query">
			SELECT MAX(pomdate) AS latest FROM qTODO
		</cfquery>
		<cfif DateDiff('d',getMaxDate.latest, NOW())>
			<cffile action="append" file="#application.todofile#" output="#LSDateFormat(NOW(),"short")#">
		</cfif>
		<cffile action="append" file="#application.todofile#" output="#form.newitem#">
	</cfcase>
	
</cfswitch>

<!--- since we have made modifications to the files, we need to commit them in git --->
 <cfscript>  
     // first of we set the command to call  
     cmd1 = "git add TODO.txt";  
     cmd2 = "git commit -m 'autobackup'";
     // the environment variable is empty  
     envp = arraynew(1);  
     // and we want to run from a given "root"  
     path = "/Volumes/iDisk/Documents/TODO";  
     dir = createobject("java", "java.io.File").init(path);  
     // get the java runtime object  
     rt = createobject("java", "java.lang.Runtime").getRuntime();  
     // and make the exec call to run the command  
     rt.exec(cmd1, envp, dir);
	 rt.exec(cmd2, envp, dir);  
 </cfscript>
<cflocation url="index.cfm##line#FORM.row#" addtoken="false">
