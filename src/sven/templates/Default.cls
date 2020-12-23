Class sven.templates.Default
{

XData LoadJSONData [ MimeType = application/json ]
{
{
    "classes": [
      {
        "super": "",
        "parameters": [
          {"name": "", "value": "", "type": ""}
        ],
        "properties": [
          {"name": "", "value": ""}
        ],
        "methods": [
          {"name": "", "implementation": ""}
        ]
      }
    ]
  }
}

ClassMethod Load(Output template As %DynamicObject) As %Status
{
  Set tSC = $$$OK
	Try {

    // Get a stream of JSON from the XData block contained in this class
    Set xdataID="sven.templates.Default||LoadJSONData"
    Set compiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
    Set tStream=compiledXdata.Data
    If '$IsObject(tStream) Set tSC=%objlasterror Quit

    // Create a dynamic object from the JSON content and write it as a string
    Set template = {}.%FromJSON(tStream)
    //Set template = dynObject.%ToJSON()

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod Test()
{
    D ..Load(.json)
    set iterator = json.%GetIterator()

    while iterator.%GetNext(.key, .classes) {
      //W !, key," ", classes
      s classIterator = classes.%GetIterator()
      while classIterator.%GetNext(.k, .c) {
        W !, c.super
        S propertyIterator = c.properties.%GetIterator()
      }
    }
}

}
