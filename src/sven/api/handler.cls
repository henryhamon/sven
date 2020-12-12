Class sven.api.Handler Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/build/" Method="PUT" Call="EmbeddBuild"/>
	<Route Url="/new/" Method="POST" Call="ProjectNew"/>

	<Route Url="/project/:id" Method="PUT" Call="ProjectUpdate"/>
	<Route Url="/project/:id" Method="GET" Call="ProjectGet"/>
	<Route Url="/project/:id" Method="DELETE" Call="ProjectDelete"/>
	<Route Url="/project/" Method="POST" Call="ProjectCreate"/>
	<Route Url="/projects" Method="GET" Call="ProjectList" Cors="false" />

</Routes>
}

ClassMethod EmbeddBuild()
{
	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectNew()
{
	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}


ClassMethod ProjectUpdate(pId)
{
	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectCreate()
{
	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
		Write $System.Status.GetErrorText(tSC)
	}
	Quit tSC
}

ClassMethod ProjectDelete(pId)
{

	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectGet(pId)
{
	Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectList()
{
  Set tSC = $$$OK
	Try {

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}
}
