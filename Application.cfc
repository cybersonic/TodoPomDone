<cfcomponent output="false" >
	
	<!--- Application name, should be unique --->
	<cfset this.name = "todoManager">
	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
	<!--- Should client vars be enabled? --->
	<cfset this.clientManagement = false>
	<!--- Where should we store them, if enable? --->
	<cfset this.clientStorage = "registry">
	<!--- Where should cflogin stuff persist --->
	<cfset this.loginStorage = "session">
	<!--- Should we even use sessions? --->
	<cfset this.sessionManagement = true>
	<!--- How long do session vars persist? --->
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
	<cfset this.setClientCookies = true>
	<!--- should cookies be domain specific, ie, *.foo.com or www.foo.com --->
	<cfset this.setDomainCookies = false>
	
	<!--- Run when application starts up --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		
		<cfset application.todofile = "/Volumes/iDisk/Documents/TODO/TODO.txt">
		<cfreturn true>
	</cffunction>


</cfcomponent>