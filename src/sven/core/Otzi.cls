Class sven.core.Otzi
{

/// Validate the ClassMethod Project arguments
ClassMethod Validate(args...) As %Status
{
	Set tSC = $$$OK
	Try {
		Set:$Get(args(1))="" tSC = $$$ERROR(6404, "Namespace")
		Throw:$$$ISERR(tSC)
		Set:$Get(args(2))="" tSC = $$$ERROR(6404, "Template")
		Throw:$$$ISERR(tSC)
		Set:$ClassName(args(2))'="sven.templates.Default" tSC = $$$ERROR(6405,"Template","sven.templates.Default")
		Throw:$$$ISERR(tSC)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

/// Load all classes from a template project and create
ClassMethod Project(args...) As %Status
{
	Set tSC = ..Validate(args...)
	Quit:$$$ISERR(tSC) tSC


	Set pNamespace = args(1),
	    pTemplate = args(2),
	    pPackage = $Get(args(3)),
	    pProject = $Get(args(4)),
	    pIgnore = $Get(args(5))
	Set:pIgnore="" pIgnore = 1

	Try {
		For k=1:1:pTemplate.Classes.Count() {

			$$$THROWONERROR(tSC, ..Class(pNamespace, pTemplate.Classes.GetAt(k), pPackage, pProject, pIgnore))
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod Class(args...) As %Status [ Private ]
{
	Set ns=$Namespace, tSC = $$$OK
	/*
	 pNamespace As %String,
	 pTemplate As sven.templates.Default.Class,
	 pPackage As %String = "",
	 pProject As %String = "",
	 pIgnore As %Boolean = 1
	*/
	Set pNamespace = args(1),
	    pTemplate = $Get(args(2)),
	    pPackage = $Get(args(3)),
	    pProject = $Get(args(4)),
	    pIgnore = $Get(args(5))
	Set:pIgnore="" pIgnore = 1

	#Dim pTemplate As sven.templates.Default.Class

	Try {
		Set:pTemplate="" tSC = $$$ERROR(6404, "Template Class")
		Throw:$$$ISERR(tSC)

		Set className = pTemplate.Name, newClass = ""

		If $Extract(className,1,1)="." {
			Set className = ""
			Set:pPackage'="" $List(className,*+1) = pPackage
			Set:pProject'="" $List(className,*+1) = pProject

			Set className = $ListToString(className,".")_pTemplate.Name
		}

		Set className = ..Replace(pPackage, pProject, className)
		Set superClass = ..Replace(pPackage, pProject, pTemplate.Super)

		ZNSpace pNamespace
			Set newClass = ##class(%Dictionary.ClassDefinition).%OpenId(className)
		ZNSpace ns

		Set:((newClass'="")&&(pIgnore=0)) tSC = $$$ERROR(5805)
		If newClass="" {
			W !,className,!

			ZNSpace pNamespace
			Set newClass = ##class(%Dictionary.ClassDefinition).%New()
			Set newClass.Name = className
			Set newClass.Super = superClass
			Set newClass.ProcedureBlock = 1
			Do newClass.%Save()

			If ((pTemplate.Name["utl.Instalador")||(pTemplate.Name["Install")) {
				// If this was an install class (used to create web aplication)
				// then add a projection
				Set projection = ##class(%Dictionary.ProjectionDefinition).%New()
				Set projection.Name = "Reference"
				Set projection.Type = "Instalador"
				Do newClass.Projections.Insert(projection)
				Do newClass.%Save()
			}

			// Properties
			For p=1:1:pTemplate.Properties.Count() {
				ZNSpace ns
					$$$THROWONERROR(tSC, ..AddProperty(pNamespace, pPackage, pProject, pTemplate.Methods.GetAt(p), .property))
				ZNSpace pNamespace

				$$$THROWONERROR(tSC, newClass.Properties.Insert(property) )


				// Create simple Index
				If pTemplate.Properties.GetAt(p).Index'="" {
					ZNSpace ns
						$$$THROWONERROR(tSC, ..AddSimpleIndex(pNamespace, pTemplate.Properties.GetAt(p).Name, .indice))
					ZNSpace pNamespace

					$$$THROWONERROR(tSC, newClass.Indices.Insert(indice) )
				}
			}
			$$$THROWONERROR(tSC, newClass.%Save() )

			// Methods
			For m=1:1:pTemplate.Methods.Count() {

				ZNSpace ns
					$$$THROWONERROR(tSC, ..AddMethod(pNamespace, pPackage, pProject, pTemplate.Methods.GetAt(m), .method))
				ZNSpace pNamespace

				$$$THROWONERROR(tSC, newClass.Methods.Insert(method) )
			}
			$$$THROWONERROR(tSC, newClass.%Save() )


			// Parameters
			For p=1:1:pTemplate.Parameters.Count() {
				Set parameter = ##class(%Dictionary.ParameterDefinition).%New()

				ZNSpace ns
					Set parameter.Name = ..Replace(pPackage, pProject, pTemplate.Parameters.GetAt(p).Name)
					Set:pTemplate.Parameters.GetAt(p).Value'="" parameter.Default = ..Replace(pPackage, pProject, pTemplate.Parameters.GetAt(p).Value)
				ZNSpace pNamespace

				Set parameter.Expression = ""

				$$$THROWONERROR(tSC, newClass.Parameters.Insert(parameter) )
			}
			$$$THROWONERROR(tSC, newClass.%Save() )


			// Routes
			Set routes = ""
			If pTemplate.Routes.Count() > 0 {
				For p=1:1:pTemplate.Routes.Count() {
					ZNSpace ns
						Set routes = routes _ "<Route Url=""/"_ ..Replace(pPackage, pProject, pTemplate.Routes.GetAt(p).Name )
						Set routes = routes _ """ Method="""_..Replace(pPackage, pProject, pTemplate.Routes.GetAt(p).Value) _""" Call="""_..Replace(pPackage, pProject, pTemplate.Routes.GetAt(p).Call) _"""/>"
					ZNSpace pNamespace
				}

				Set routes = "<Routes>" _ routes _ "</Routes>"
				Set route = ##class(%Dictionary.XDataDefinition).%New()
				Set route.Name = "UrlMap"
				Do route.Data.Write(routes)
				$$$THROWONERROR(tSC, newClass.XDatas.Insert(route))
			}
			$$$THROWONERROR(tSC, newClass.%Save() )

			If pTemplate.Bpl.Read() '="" {
				Do pTemplate.Bpl.Rewind()
				Set xdata = ##class(%Dictionary.XDataDefinition).%New()
				Set xdata.Name = "BPL"
				Set xdata.Description = "BPL Definition"

				ZNSpace ns
					Do xdata.Data.Write(..Replace(pPackage, pProject, pTemplate.Bpl.Read()))
				ZNSpace pNamespace

				$$$THROWONERROR(tSC, newClass.XDatas.Insert(xdata))
			}
			$$$THROWONERROR(tSC, newClass.%Save() )

			If ((pTemplate.Page.Style.Read()'="")||(pTemplate.Page.Content.Read()'="")) {

				Set content = ##class(%GlobalCharacterStream).%New(),
					page = $ListBuild("Style","Contents")

				For p=1:1:$ListLength(page) {
					Do:p=1 content.CopyFrom(pTemplate.Page.Style)
					Do:p=2 content.CopyFrom(pTemplate.Page.Content)
					Do content.Rewind()
					If content.Read()'="" {
						Do content.Rewind()
						Set xdata = ##class(%Dictionary.XDataDefinition).%New()
						Set xdata.Name = $List(page, p)
						;Set xdata.Description = ""

						ZNSpace ns
							Do xdata.Data.Write(..Replace(pPackage, pProject, content.Read()))
						ZNSpace pNamespace

						$$$THROWONERROR(tSC, newClass.XDatas.Insert(xdata))
					}
				}
				$$$THROWONERROR(tSC, newClass.%Save() )
			}

			Do:((newClass.Name'["Instalador")||(newClass.Name'["Install")) $system.OBJ.Compile(newClass.Name)
		}

	} Catch tException {
		Set:$$$ISOK(tSC) tSC=tException.AsStatus()
	}

	ZNSpace ns

	Quit tSC
}

/// The <b>Replace</b> method add the package and project names to classname
ClassMethod Replace(pPackage As %String = "", pProject As %String = "", pParam As %String) As %String [ Private ]
{
	Set output = pParam
	Set lowText = $ZConvert(pProject,"l")
	Set camelText = $Extract($ZConvert(lowText,"U"),1,1) _ $Extract($ZConvert(lowText,"l"),2,*)

	Set pkgPrj = ""
	Set:pPackage'="" $List(pkgPrj,*+1) = pPackage
	Set:pProject'="" $List(pkgPrj,*+1) = pProject
	Set pkgPrj = $ListToString(pkgPrj,".")

	Set output = $Replace(output,"#{package.project}",pkgPrj)
	Set output = $Replace(output,"#{project}",pProject)
	Set output = $Replace(output,"#{Camelcase.project}", camelText)
	Set output = $Replace(output,"#{camel.project}", camelText)
	Set output = $Replace(output,"#{package}", pPackage)
	Set output = $Replace(output,"#{database.packagename}", $Replace(pPackage,".","_"))
	Quit output
}

ClassMethod AddMethod(pNamespace As %String = "", pPackage As %String = "", pProject As %String = "", pTemplateMethod As sven.templates.Default.Method, Output pMethod As %Dictionary.MethodDefinition) As %Status [ Private ]
{
	Set ns=$Namespace, tSC = $$$OK
	Try {
		ZNSpace pNamespace

		Set pMethod = ##class(%Dictionary.MethodDefinition).%New()
		Set pMethod.ClassMethod = 0, parameter = ""

		Set:pTemplateMethod.Type="Class" pMethod.ClassMethod = 1
		Set:pTemplateMethod.Type="Client" pMethod.ClientMethod = 1

		If pTemplateMethod.Type = "Zen" {
			Set pMethod.ClassMethod = 1,
				pMethod.ZenMethod = 1
		}

		If pTemplateMethod.Type = "Javascript" {
			Set pMethod.ClientMethod = 1,
				pMethod.Language = "javascript"
		}

		Set:pTemplateMethod.Parameters'="" parameter = pTemplateMethod.Parameters

		ZNSpace ns
			Set pMethod.Name = ..Replace(pPackage, pProject, pTemplateMethod.Name)
			Set:pTemplateMethod.Value'="" pMethod.ReturnType = ..Replace(pPackage, pProject, pTemplateMethod.Value)
			Do pMethod.Implementation.Write( ..Replace(pPackage, pProject, pTemplateMethod.Implementation.Read()) )
			Set:parameter'="" pMethod.FormalSpec = ..Replace(pPackage, pProject, parameter)
		ZNSpace pNamespace
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	ZNSpace ns
	Quit tSC
}

ClassMethod AddProperty(pNamespace As %String = "", pPackage As %String = "", pProject As %String = "", pTemplateProperty As sven.templates.Default.Property, Output pProperty As %Dictionary.PropertyDefinition) As %Status [ Private ]
{
	Set ns=$Namespace, tSC = $$$OK
	Try {
		ZNSpace pNamespace
		Set pProperty = ##class(%Dictionary.PropertyDefinition).%New()

		ZNSpace ns
			Set pProperty.Name = ..Replace(pPackage, pProject, pTemplateProperty.Name)
			Set pProperty.Type = ..Replace(pPackage, pProject, pTemplateProperty.Value)
		ZNSpace pNamespace

		Set:pTemplateProperty.List'="" pProperty.Collection = "list"
		If (pTemplateProperty.Parameters.Count() > 0) {
			For param=1:1:pTemplateProperty.Parameters.Count() {
				#Dim parameter As otzi.core.vo.Parameter
				Set parameter = pTemplateProperty.Parameters.GetAt(param)

				Set paramValue ="",paramName =""
				ZNSpace ns
					Set paramValue = ..Replace(pPackage, pProject, parameter.Value)
					Set paramName = ..Replace(pPackage, pProject, parameter.Name)
				ZNSpace pNamespace
				Do pProperty.Parameters.SetAt(paramValue, paramName)
			}
		}

	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	ZNSpace ns
	Quit tSC
}

ClassMethod AddSimpleIndex(pNamespace As %String = "", pPropertyName As %String, Output pIndex As %Dictionary.IndexDefinition) As %Status [ Private ]
{
	Set ns=$Namespace, tSC = $$$OK
	Try {
		ZNSpace pNamespace
		Set indice = ##class(%Dictionary.IndexDefinition).%New()
		Set indice.Name = "Idx"_pPropertyName
		Set indice.Properties = pPropertyName
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	ZNSpace ns
	Quit tSC
}

}
