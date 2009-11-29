<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	
	<title></title>
	<link rel="stylesheet" href="menu_style.css" type="text/css" />
	<link rel="stylesheet" href="main.css" type="text/css" />	
	<cf_todoParser rTodo="qTodo">
</head>
<body>
	<div class="menu">
		<ul>
			<li><a href="index.cfm" >Home</a></li>
			<cfinclude template="reportnav.cfm" />

		</ul>
	</div>
	
<h1 id="reports">Reports</h1>

<cfswitch expression="#URL.report#">
	
	<cfcase value="doneperday">
		<cfset title="Done per Day">
		<cfquery name="donePerDay" dbtype="query">
			SELECT * FROM qTodo
			WHERE type = 'DONE'
		</cfquery>
	
	</cfcase>
	<cfcase value="todoperday">
		<cfset title="TODO per Day">
		<cfquery name="donePerDay" dbtype="query">
			SELECT * FROM qTodo
			WHERE type = 'TODO'
		</cfquery>
		
	</cfcase>
	<cfcase value="pomperday">
		<cfset title="POM per Day">
		<cfquery name="donePerDay" dbtype="query">
			SELECT * FROM qTodo
			WHERE type = 'POM'
		</cfquery>
		
	</cfcase>
	
	<cfcase value="estimatevsactual">
		<cfset title="Estimated Vs. Actual">
		<cfquery name="donePerDay" dbtype="query">
			SELECT * FROM qTodo
			WHERE type = 'DONE'
		</cfquery>
			<cfdump var="#donePerDay#">
		<cfabort>
	
	</cfcase>
</cfswitch>
	<cfchart  format="gif" chartWidth="500" chartheight="300" title="#title#">
		<cfchartseries type="bar">
		<cfoutput query="donePerDay" group="pomdate">
			<cfset counter=0>
			<cfoutput>
				<cfset counter++>
			</cfoutput>
			<cfchartdata item="#pomdate#" value="#counter#">
		</cfoutput>
		</cfchartseries>
	</cfchart>
</body>
</html>
