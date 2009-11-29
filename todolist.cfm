<!--- This file displays a todo table --->
<cf_todoParser rTodo="qTodo">
<cfquery name="backOrdered" dbtype="query">
	SELECT * FROM qTodo
	WHERE 1=1 
	<cfif ListLen(COOKIE.hideItem)>
	AND type NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#COOKIE.hideItem#" list="true">)
	</cfif>
	AND type != 'DATE'
	ORDER by pomdate DESC
</cfquery>


<!--- Do a table for each day --->
<table width="100%" cellpadding="2" cellspacing="2" border="1">
	<cfoutput query="backOrdered" group="pomdate">
	<thead>
		<tr>
			<th colspan="5" align="left">
					#LSDateFormat(pomdate, "long")#
			</th>
		</tr>
		<tr>
			<th>
				<!--- This is the line column --->
			</th>
			<th>
				<!--- This is the tickbox column --->
			</th>
			<th>
				<!--- Icon column --->
			</th>

			<th align="left">
				<!--- Item column --->
				Item
			</th>
			<th align="left">
				<!--- Estimation for todo column --->
				Estimate
			</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput>
		<tr>
			<td>#row#</td>
			<td width="20">
				<cfif ListFind("POM,TODO", TYPE)>
					<input type="checkbox" name="row" value="#row#" class="pomCheck" onclick="markAsDone(this)">
				</cfif>
			</td>
			<td>
				<img src="images/#type#.png" border=0>
			</td>
			<td>#text#</td>
			<td></td>
		</tr>
		</cfoutput>
	</tbody>
</cfoutput>
</table>


<cfdump var="#qTodo#">