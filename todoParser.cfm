<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Copyright (c) 2009 Railo Technologies. All rights reserved. --->
<!--- @@License: --->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.file" default="#application.todofile#">
	<cfif NOT FileExists(attributes.file)>
		<cffile action="write" file="#attributes.file#" output="">
	</cfif>
	
	<cfscript>
		qItems = QueryNew("pomdate,type,text,formattedText,row,hasTicket,estimate,internalInter,externalInter,tags,originaltype", "Date,Varchar,Varchar,Varchar,numeric,boolean,numeric,numeric,numeric,VarChar,VarChar");
		function addItem(thedate,type,text,row,hasTicket=false,original=""){
			
			var dbDate = CreateDate(ListGetAt(thedate,3,"/"), ListGetAt(thedate,2,"/"), ListGetAt(thedate,1,"/"));
			var estimate = 0;
			var intInt = 0;
			var extInt = 0;
			var formattedString = text;
			
			//Find the estimates and interruptions
			if(ListFind("TODO,DONE", type)){
				var foundSpecial = false;
				var TodoBackString = Reverse(text); 
					formattedString = TodoBackString;
				for(var c=1;c LTE Len(TodoBackString); c++){
					var char = Mid(TodoBackString,c,1);				
					if(NOT ListFind("',+,-, ", char)){
						break;
					}
					
					//add the characters to estimates and what have you
					if(char EQ "+"){ //This is for DONE and TODO
						estimate++;
						formattedString = Right(formattedString,Len(formattedString)-1);
					}
					if(char EQ "'"){ //THIS is for a POM, interruption!
						intInt++;
						formattedString = Right(formattedString,Len(formattedString)-1);
					}
					if(char EQ "-"){ //This is for a POM too!
						extInt++;
						formattedString = Right(formattedString,Len(formattedString)-1);
					}
					if(char EQ " "){
						formattedString = Right(formattedString,Len(formattedString)-1);						
					}
					
				}
			formattedString = Reverse(formattedString);				
			}

			//Add string cleaning here
			formattedString = removeStartText(formattedString,"DONE:");
			formattedString = removeStartText(formattedString,"DONE");
			formattedString = removeStartText(formattedString,"TODO:");
			formattedString = removeStartText(formattedString,"TODO");
			formattedString = removeStartText(formattedString,"POM:");
			formattedString = removeStartText(formattedString,"POM");
			
			QueryAddRow(qItems);
			QuerySetCell(qItems,"pomdate",CreateODBCDate(dbDate));
			QuerySetCell(qItems,"type",type);
			QuerySetCell(qItems,"text",text);
			QuerySetCell(qItems,"formattedText",formattedString);
			QuerySetCell(qItems,"row",row);
			QuerySetCell(qItems,"hasTicket",hasTicket);
			QuerySetCell(qItems,"estimate", estimate);
			QuerySetCell(qItems,"internalInter", intInt);
			QuerySetCell(qItems,"externalInter", extInt);
			QuerySetCell(qItems,"tags", findTags(formattedString));
			QuerySetCell(qItems, "originalType", original);
			
			
		}
		
		
		//Returns a string without the text at the front 
		function removeStartText(string,text){
			if(string.startsWith(text)){
				return Trim(Right(string,Len(string)-Len(text)));			
			}
			return string;
		}
		
		
		function REGet(str,regex) {
			    var results = arrayNew(1);
			    var test = REFind(regex,str,1,1);
			    var pos = test.pos[1];
			    var oldpos = 1;
			    while(pos gt 0) {
			        arrayAppend(results,mid(str,pos,test.len[1]));
			        oldpos = pos+test.len[1];
			        test = REFind(regex,str,oldpos,1);
			        pos = test.pos[1];
			    }
		    return results;
			}
		
		//find strings like [some tag] and returns an array of tags
		function findTags(string){
			var tagString = "";
			var tags = REGet(string,"\[(\w*)\]");
			
			tagString = ArrayToList(tags);
			tagString = Replace(tagString,"[","", "all");
			tagString = Replace(tagString,"]","", "all");
			return tagString;
		
		}
		
		function hasTicket(stringItem){
			if(ReFind("##(\d)+",stringItem)){
				return true;
			}
				return false;
		}
		
		function getItemType(stringItem){
			if(stringItem.toLowerCase().startsWith("done")){
				return "DONE";
			}
			if(stringItem.toLowerCase().startsWith("todo")){
				return "TODO";
			}
			if(stringItem.toLowerCase().startsWith("pom")){
				return "POM";
			}
			
			return "OTHER";
		
		}
		
	</cfscript>
	<cfset linecount = 1>
	<cfset currentDate = "">
	
	<cfloop file="#attributes.file#" index="item">
			<cfif isDate(trim(item))>
				<cfset currentDate = item>
				<cfset addItem(currentDate,"DATE",item,lineCount,false)>
			<cfelseif getItemType(item) EQ 	"DONE">
				<!---
					DONE: 
					Try and find out what it was originally too, 
				--->
				<cfscript>
					reparsed = Trim(Mid(item,4+1,Len(item)));
					if(reparsed.startsWith(":")){
						reparsed = Trim(Mid(reparsed,2,Len(reparsed)));
					}	
				</cfscript>
			
				<cfset addItem(currentDate,"DONE",item,lineCount,hasTicket(item),getItemType(reparsed))>
			<cfelseif Left(item,3) EQ "POM">
				<!--- POM: --->
					<cfset addItem(currentDate,"POM",item,lineCount)>
			<cfelseif Left(item,4) EQ "TODO">
			<!--- TODO: --->
					<cfset addItem(currentDate,"TODO",item,lineCount,hasTicket(item))>		
			<cfelse>
				<cfif Len(Trim(item))>
					<cfset addItem(currentDate,"OTHER",item,lineCount, hasTicket(item))>		
				</cfif>
			</cfif>

		<cfset linecount++>
	</cfloop>
	
	<cfset caller[attributes.rTodo] = qItems>
</cfif>

<cfif thistag.executionmode eq "End">
	<cfexit method="exittag" />
</cfif>

<cfsetting enablecfoutputonly="No">