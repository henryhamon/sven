Class sven.ins.Installer Extends %Projection.AbstractProjection
{

Parameter Application = "sven";

Parameter Dispatch = "sven.api.Handler";

Projection Reference As Installer;

/// This method is invoked when a class is compiled.
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    Set ns = $Namespace
    ZNSpace:ns'="%SYS" "%SYS"
    Do ##class(Security.System).GetInstallationSecuritySetting(.security)
    If (security="None") {
        Set cspProperties("AutheEnabled") = 64 // Unauthenticated
    } Else {
        Set cspProperties("AutheEnabled") = 32 // Password
    }
    Set cspProperties("NameSpace") = ns
    Set cspProperties("Description") = "Aplicação WEB para o sistema RESTful"
    Set cspProperties("IsNameSpaceDefault") = 1
    Set cspProperties("DispatchClass") = ..#Dispatch
    If ('##class(Security.Applications).Exists("/" _ ..#Application)) {
        Write !, "Criando a Aplicação Web ""/"""_..#Application_"..."
        Set tSC = ##class(Security.Applications).Create("/" _ ..#Application, .cspProperties)
        If $$$ISERR(tSC) Throw ##class(%Installer.Exception).CreateFromStatus(tSC)
        Write !, "Aplicação Web ""/"_..#Application_""" criada com sucesso."
    } Else {
        Write !, "Aplicação Web ""/"_..#Application_""" já existe, e está pronta para uso."
    }
    ZNSpace:ns'="%SYS" ns
    Quit $$$OK
}

/// This method is invoked when a class is 'uncompiled'.
ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
    Set ns = $Namespace
    ZNSpace:ns'="%SYS" "%SYS"
    If (##class(Security.Applications).Exists("/" _ ..#Application)) {
        Write !, "Removendo a aplicação Web ""/"_..#Application_"""..."
        Do ##class(Security.Applications).Delete("/" _ ..#Application)
        Write !, "Aplicação Web ""/"_..#Application_""" foi removida com sucesso."
    }
    ZNSpace:ns'="%SYS" ns
    Quit $$$OK
}

}
