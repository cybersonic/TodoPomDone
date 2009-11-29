<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<cfparam name="COOKIE.hideItem" default="">
<cfparam name="URL.hideItem" default="">
<cfparam name="URL.showItem" default="">
<cfif Len(URL.hideItem) AND NOT ListFindNoCase(COOKIE.hideitem,URL.hideItem)>
	<cfset COOKIE.hideItem = ListAppend(COOKIE.hideitem, URL.hideItem)>
</cfif>
<cfif Len(URL.showItem) AND ListFindNoCase(COOKIE.hideitem, URL.showItem)>
	<cfset COOKIE.hideItem = ListDeleteAt(COOKIE.hideItem, ListFindNoCase(COOKIE.hideItem,URL.showItem))>	
</cfif>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>TodoPomDone</title>
	<link rel="stylesheet" href="menu_style.css" type="text/css" />
	<link rel="stylesheet" href="main.css" type="text/css" />	
	<script type="text/javascript" 
	        src="http://www.google.com/jsapi"></script>
	<script type="text/javascript">
	  // You may specify partial version numbers, such as "1" or "1.3",
	  //  with the same result. Doing so will automatically load the 
	  //  latest version matching that partial revision pattern 
	  //  (i.e. both 1 and 1.3 would load 1.3.2 today).
	  google.load("jquery", "1.3.2");

	  google.setOnLoadCallback(function() {
	     jQuery.fn.check = function(mode) {
				   // if mode is undefined, use 'on' as default
				   var mode = mode || 'on';

				   return this.each(function() {
				     switch(mode) {
				       case 'on':
				         this.checked = true;
				         break;
				       case 'off':
				         this.checked = false;
				         break;
				       case 'toggle':
				         this.checked = !this.checked;
				         break;
				     }
				   });
				 };
		
	  });
	
		function markAsDone(item){		
			if($(item).is(':checked')){
				if(confirm("Do you want to mark this as done?")){
					$("#actionform").submit();
				}
				else{
					$(item).attr("checked", false);
				}
				
			}
		}
		function checkType(textareaItem){
			if($(textareaItem).val().substr(0,3) == "POM"){
				hideIcons();
				$("#pom_icon").show();
			}
			else if($(textareaItem).val().substr(0,4) == "DONE"){
					hideIcons();
					$("#done_icon").show();
			}
			else if($(textareaItem).val().substr(0,4) == "TODO"){
					hideIcons();
					$("#todo_icon").show();
			}						
			else {
				hideIcons();
				$("#other_icon").show();
			}
		}
	
		function hideIcons(){
			
			$("#pom_icon").hide();
			$("#todo_icon").hide();
			$("#done_icon").hide();
			$("#other_icon").hide();
		}
	
	
		function addPom(row){
			$("#newitem").val("POM " + $("#item_" + row).text());
		}
	
	</script>
	
	<!-- Date: 2009-11-27 -->
	<cfscript>
		qItems = QueryNew("pomdate,type,text,row,hasTicket", "Date,Varchar,Varchar,numeric,boolean");
		function itemFormatter(stringItem){
			var stringItem = arguments.stringItem;
			stringItem = ticketLinker(stringItem);
			
			return stringItem;
		}
		
		function ticketLinker(stringItem){
			
			stringItem = ReReplace(stringItem, "##(\d+)", "<a href='https://peterbell.unfuddle.com/projects/11713/tickets/by_number/\1?cycle=true' target='new'>\0</a>", "all");
			
			return stringItem;
		}
	
		function hasTicket(stringItem){
			if(ReFind("##([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\b",stringItem)){
				return true;
			}
				return false;
		}
	
		function addItem(thedate,type,text,row,hasTicket=false){
			QueryAddRow(qItems);
			QuerySetCell(qItems,"pomdate",thedate);
			QuerySetCell(qItems,"type",type);
			QuerySetCell(qItems,"text",text);
			QuerySetCell(qItems,"row",row);
			QuerySetCell(qItems,"hasTicket",hasTicket);
		}
	

	
	</cfscript>
	<cfparam name="todofile" type="string" default="#application.todofile#" />
</head>
<body>
<cf_todoParser rTodo="qTodo">

<!--- setup some stats --->
<cfquery name="doneCount" dbtype="query">
	SELECT *
	FROM qTodo
	WHERE type = 'DONE'
</cfquery>
<cfquery name="openPOM" dbtype="query">
	SELECT pomdate,type,text,row,hasTicket
	FROM qTodo
	WHERE type = 'POM'
</cfquery>
<cfquery name="openTODO" dbtype="query">
	SELECT pomdate,type,text,row,hasTicket
	FROM qTodo
	WHERE type = 'TODO'
</cfquery>
<cfquery name="openOther" dbtype="query">
	SELECT pomdate,type,text,row,hasTicket
	FROM qTodo
	WHERE type = 'OTHER'
</cfquery>

<cfquery name="qdateRange" dbType="query">
	SELECT MAX(pomdate) AS maxdate, MIN(pomdate) as mindate
	FROM qTodo
</cfquery>


<cffunction name="getPomInstances" output="true">
	<cfargument name="query">
	<cfargument name="text">
	<cfset var getMatchingPoms = "">
		<cfquery name="getMatchingPoms" dbtype="query">
			SELECT * FROM arguments.query
			WHERE 1=1
			AND type = <cfqueryparam cfsqltype="cf_sql_varchar" value="POM">
				OR type = <cfqueryparam cfsqltype="cf_sql_varchar" value="DONE">
			AND formattedText LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.text#%">
		</cfquery>
		<cfreturn getMatchingPoms.recordcount>
	<cfreturn 0>
</cffunction>
<cfoutput>
<h1 id="todo_list">TODO list (#LSDateFormat(qdateRange.mindate,  "medium")# - #LSDateFormat(qdateRange.maxdate, "medium")#)</h1>

</cfoutput>
<cfquery name="backOrdered" dbtype="query">
	SELECT * FROM qTodo
	WHERE 1=1 
	<cfif ListLen(COOKIE.hideItem)>
	AND type NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#COOKIE.hideItem#" list="true">)
	</cfif>
	AND type != 'DATE'
	ORDER by pomdate DESC
</cfquery>

<div class="newItem">
	<form action="fileupdate.cfm" method="post" accept-charset="utf-8">
		<input type="hidden" name="action" value="newItem">
		<p>
		<label for="additem">
			<h3>Add Item</h3>
			
		</label>		
		</p>
		
		<div id="debug"></div>
		<div class="description">
			<h4>Instructions</h4>
			<div class="description-text">
			You can enter any text you like in this box to be added to your TODO list. There are special cases that allow TodoPomDone to help you plan things out:
			<ul>
				<li>TODO: If you start your sentence with "TODO", it marks it as an item that you have to do (obvious really), but you can add at the end of the sentence the following:
					<ul>
						<li>+: the "+" sign is for you to estimate a pom, so for example you could add "TODO doing the dishes +++" which means you have to do the dishes and you estimate it taking three poms</li>
					</ul>				
				</li>
				<li>POM: if you start your sentence with "POM", it marks it as Pomodoro, this would be completed pomodoro, you can also use the tickboxes in a TODO (from your estimate) to add a Pomodoro</li>
				<li>DONE: this will create an entry that is already finished. if you want to mark an existing entry as done, you just have to click on the tickbox next to it</li>
				<li>Any other items will be marked as "OTHER" automatically and wont contribute to the reporting engine</li>
			</ul>
			</div>
		</div>
		<p>
		<textarea name="newitem" id="newitem" rows="8" cols="80" onKeyUp="checkType(this)"></textarea>
		<div id="pom_icon"></div>
			<div id="todo_icon"></div>
			<div id="done_icon"></div>		
			<div id="other_icon"></div>
		</p>
		<p><input type="submit" value="Continue &rarr;"></p>
	</form>
	
</div>

<cfset tagCloud = {}>
<form action="fileupdate.cfm" method="post" id="actionform">
			<input type="hidden" name="action" value="markAsDone">

<cfset dateCounter = 1>
<div class="back1 itemblock">
<cfoutput query="backOrdered" group="pomdate">
	</div>
	<div class="back#(dateCounter MOD 2) + 1#">
	#LSDateFormat(pomdate, "long")#
		<cfoutput>
			
			<div class="#type#">
				<span class="row"><a href="##line#row#" title="this entry is on line #row#">#row#</a></span>
				<span class="text">
					<a name="line#row#">
						#type#
					<cfif ListFind("POM,TODO", TYPE)>
						<div class="checkboxspacer"><input type="checkbox" name="row" value="#row#" class="pomCheck" title="click me to mark this item as complete" onclick="markAsDone(this)"></div>
						<img src="images/#type#.png" title="#type# entry" border=0>
					<cfelse>
						<div class="checkboxspacer"></div>
						<img src="images/#type#.png" title="#type# entry" border=0>
					</cfif>
					
					<span id="item_#row#">#ticketLinker(formattedtext)#</span>
					
					<cfif ListFindNoCase("TODO,DONE", TYPE) AND originalType EQ "TODO">
					<!--- get the POM occurances of this item --->
					<cfset instances = getPomInstances(backOrdered,formattedtext)>
					<cfloop from="1" to="#estimate#" index="e">
						<cfif e LTE instances>
							<input type="checkbox" name="estimate_#row#" checked="true" disabled="true" title="completed pom"/>
						<cfelse>
							<input type="checkbox" name="estimate_#row#" onClick="addPom(#row#)" title="click me to add a pom"/>
						</cfif>
					</cfloop>
					<cfif instances GTE estimate>
						<cfloop from="#estimate#" to="#instances#" index="over">
							<img src="images/clock_red.png" title="#over-estimate+1# pom over estimate">							
						</cfloop>
						<img src="images/clock_add.png" title="add another pom" onclick="addPom(#row#)">
					</cfif>
					
					</cfif>
					
					
					
					<cfif type EQ "OTHER">
						<a href="deleteLine.cfm?line=#row#" alt="delete" title="delete" onClick="javascript:return confirm('Are you sure you want to delete this item?')"><img src="images/table_row_delete.png" border=0></a>
					</cfif>
					</a>					
					<cfif Len(tags)>
						<img src="images/tags.png"> <em>#tags#</em>
						<cfloop list="#tags#" index="t">
							<cfif Not StructKeyExists(tagCloud,t)>
								<cfset tagCloud[t] = 1>
							<cfelse>
								<cfset tagCloud[t]++>
							</cfif>
						</cfloop>
					</cfif>
				</span>

			</div>
		</cfoutput>
		
	
	<cfset dateCounter++>
</cfoutput>
<cfoutput>
<div class="menu">
	<ul>
		<li><a name="done">Done: #doneCount.recordcount# / #doneCount.recordcount + openPOM.recordcount#</a></li>
		<li><a href="" id="current">Open Poms:#openPOM.recordcount#</a>
			<ul>
				<cfloop query="openPOM" endrow="10">
					<li><a href="#CGI.script_name###line#row#" title="#text#">#text#</a></li>					
					
				</cfloop>
				<cfif openPom.recordcount GT 10>
				<li><a href="">...</a></li>
				</cfif>
		   </ul>
	  </li>
	  <li><a href="">Todo: #openTODO.recordcount#</a>
			<ul>
				<cfloop query="openTODO" endrow="10">
					<li><a href="" title="#text#">#text#</a></li>					
				</cfloop>
				<cfif openTODO.recordcount GT 10>
					<li><a href="">...</a></li>
				</cfif>
		   </ul>
		</li>
	  <li><a href="">Other: #openOther.recordcount#</a>
			<ul>	
				<cfloop query="openOther" endrow="10">
					<li><a href="" title="#text#">#text#</a></li>					
				</cfloop>
				<cfif openTODO.recordcount GT 10>
					<li><a href="">...</a></li>
				</cfif>
			</ul>
		</li>
		<cfinclude template="reportnav.cfm" />
		
		<li><a>Display Options...</a>
			<ul>
				<cfset lHideItems = "TODO,DONE,OTHER,POM">
				<cfloop list="#lHideItems#" index="it">
					<cfif ListFind(COOKIE.hideItem, it)>
						<li> <a href="index.cfm?showItem=#it#">Show #it#</a></li>
					<cfelse>
						<li> <a href="index.cfm?hideItem=#it#">Hide #it#</a></li>
					</cfif>
				</cfloop>

			</ul>
		</li>
	</ul>
</div>
</cfoutput>

<cfset aTagCloud = StructSort(tagCloud,"numeric","DESC")>
<div id="tagCloud">
	<cfset counter = 5>
	<cfloop array="#aTagCloud#" index="tc">
			<cfoutput><span class="tagCloud_#counter#">#tc#</span> </cfoutput>
		<cfif counter GT 1>
		<cfset counter -->
		</cfif>
	</cfloop>
</div>

</div>
</form>
<cfquery name="totalItems" dbtype="query">
	SELECT * FROM qTodo
	WHERE 1=1 
	AND type != 'DATE'
	ORDER by pomdate DESC
</cfquery>
<div id="statusinfo">
<cfoutput>	<a href="file://#application.todofile#" target="new" style="color:white;">file://#application.todofile#</a> - #totalItems.recordcount# Items </cfoutput>
</div>
</body>
</html>
