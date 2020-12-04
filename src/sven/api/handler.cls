Class sven.api.Handler Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/rule/:id" Method="PUT" Call="RuleUpdate"/>
<Route Url="/rule/:id" Method="GET" Call="RuleGet"/>
<Route Url="/rule/:id" Method="DELETE" Call="RuleDelete"/>
<Route Url="/rule/" Method="POST" Call="RuleCreate"/>
<Route Url="/rules" Method="GET" Call="RuleList" Cors="false" />

<Route Url="/project/:id/jurisdiction/:jurisdiction" Method="PUT" Call="ProjectJurisdictionUpdate"/>
<Route Url="/project/:id/jurisdiction/:jurisdiction" Method="GET" Call="ProjectJurisdictionGet"/>
<Route Url="/project/:id/jurisdiction/:jurisdiction" Method="DELETE" Call="ProjectJurisdictionDelete"/>
<Route Url="/project/:id/jurisdiction/" Method="POST" Call="ProjectJurisdictionCreate"/>
<Route Url="/project/:id/jurisdictions" Method="GET" Call="ProjectJurisdictionList" Cors="false" />
<Route Url="/project/:id/bribe/:bribe" Method="PUT" Call="ProjectBribeUpdate"/>
<Route Url="/project/:id/bribe/:bribe" Method="GET" Call="ProjectBribeGet"/>
<Route Url="/project/:id/bribe/:bribe" Method="DELETE" Call="ProjectBribeDelete"/>
<Route Url="/project/:id/bribe/" Method="POST" Call="ProjectBribeCreate"/>
<Route Url="/project/:id/bribes" Method="GET" Call="ProjectBribeList"/>
<Route Url="/project/:id" Method="PUT" Call="ProjectUpdate"/>
<Route Url="/project/:id" Method="GET" Call="ProjectGet"/>
<Route Url="/project/:id" Method="DELETE" Call="ProjectDelete"/>
<Route Url="/project/" Method="POST" Call="ProjectCreate"/>
<Route Url="/projects" Method="GET" Call="ProjectList" Cors="false" />

<Route Url="/session/:id" Method="GET" Call="SessionGet"/>
<Route Url="/sessions" Method="GET" Call="SessionList" Cors="false" />
</Routes>
}

ClassMethod RuleUpdate(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			name = $Get(%request.Data("name",1)),
			badge = $Get(%request.Data("badge",1)),
			offenseLevel = $Get(%request.Data("offenseLevel",1)),
			ruleClass = $Get(%request.Data("rule_class",1)),
			severity = $Get(%request.Data("severity",1)),
			type = $Get(%request.Data("type",1)),
			params = $Get(%request.Data("params",1)),
			documentation = $Get(%request.Data("documentation",1))
		$$$THROWONERROR(tSC, ##class(dredd.dao.Rule).Save(name, ruleClass, severity, type, badge, documentation, params, offenseLevel ))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod RuleCreate()
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			name = $Get(%request.Data("name",1)),
			badge = $Get(%request.Data("badge",1)),
			offenseLevel = $Get(%request.Data("offenseLevel",1)),
			ruleClass = $Get(%request.Data("rule_class",1)),
			severity = $Get(%request.Data("severity",1)),
			type = $Get(%request.Data("type",1)),
			params = $Get(%request.Data("params",1)),
			documentation = $Get(%request.Data("documentation",1))

		Throw:name="" $$$ERROR(5002, "Name is required")
		Throw:severity="" $$$ERROR(5002, "Severity is required")
		Throw:type="" $$$ERROR(5002, "Type is required")
		$$$THROWONERROR(tSC, ##class(dredd.dao.Rule).Save(name, ruleClass, severity, type, badge, documentation, params, offenseLevel ))

		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
		Write $System.Status.GetErrorText(tSC)
	}
	Quit tSC
}

ClassMethod RuleDelete(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Rule).Delete(pId))
		Set resp.status = $$$OK

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod RuleGet(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Rule).Open(pId, .rule))

		If $isobject(rule) {
			Set resp.name = rule.Name, resp.id = pId,
				resp.Badge = rule.Badge,
				resp.OffenseLevel = rule.OffenseLevel,
				resp.RuleClass = rule.RuleClass,
				resp.Severity = rule.Severity,
				resp.Type = rule.Type,
				resp.Params = rule.Params,
				resp.Documentation = rule.Documentation
		}
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod RuleList()
{
    Set tSC = $$$OK
	Try {
    Set Sql = "SELECT ID, Badge, Documentation, Name, OffenseLevel, RuleClass, "_
		" Severity, Type, Params FROM dredd_dad.Rule",
			resp = $$$JsonNew,
			resp.rules = $$$JsonArray
		Set tRS = ##class(%ResultSet).%New()
	$$$THROWONERROR(tSC, tRS.Prepare(Sql))
	$$$THROWONERROR(tSC, tRS.Execute())
	While (tRS.Next()) {
		Set rule = $$$JsonNew,
			rule.id = tRS.Get("ID"),
			rule.name = tRS.Get("Name"),
			rule.badge = tRS.Get("Badge"),
			rule.documentation = tRS.Get("Documentation"),
			rule.offenseLevel = tRS.Get("OffenseLevel"),
			rule.ruleClass = tRS.Get("RuleClass"),
			rule.severity = tRS.Get("Severity"),
			rule.params = tRS.Get("Params"),
			rule.type = tRS.Get("Type")
		$$$JsonAdd(resp.rules, rule)
    }

	$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectUpdate(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			name = $Get(%request.Data("name",1)),
			namespace = $Get(%request.Data("namespace",1)),
			root = $Get(%request.Data("root",1))
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Save(name, namespace, root))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectCreate()
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			name = $Get(%request.Data("name",1)),
			namespace = $Get(%request.Data("namespace",1)),
			root = $Get(%request.Data("root",1))
		Throw:name="" $$$ERROR(5002, "Name is required")

		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Save(name, namespace, root))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
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
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Delete(pId))
		Set resp.status = $$$OK

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectGet(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Open(pId, .project))

		If $isobject(project) {
			Set resp.name = project.Name, resp.id = pId, resp.namespace = project.Namespace
		}
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectList()
{
  Set tSC = $$$OK
	Try {
		Set Sql = "SELECT ID, Name, Namespace, Root FROM dredd_dad.Project",
			resp = $$$JsonNew,
			resp.projects = $$$JsonArray
		Set tRS = ##class(%ResultSet).%New()
		$$$THROWONERROR(tSC, tRS.Prepare(Sql))
		$$$THROWONERROR(tSC, tRS.Execute())
		While (tRS.Next()) {
			Set project = $$$JsonNew,
				project.id = tRS.Get("ID"),
				project.name = tRS.Get("Name"),
				project.namespace = tRS.Get("Namespace")
			$$$JsonAdd(resp.projects, project)
		}

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectJurisdictionCreate(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			rule = $Get(%request.Data("rule",1))
		Throw:rule="" $$$ERROR(5002, "Rule is required")

		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).SaveJurisdiction(pId, rule))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
		Write $System.Status.GetErrorText(tSC)
	}
	Quit tSC
}

ClassMethod ProjectJurisdictionUpdate(pId, pJurisdiction)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			rule = $Get(%request.Data("rule",1))
		Throw:rule="" $$$ERROR(5002, "Rule is required")

		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).SaveJurisdiction(pId, rule, pJurisdiction))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectJurisdictionGet(pId, pJurisdiction)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			jurisdiction = ##class(dredd.dad.Jurisdiction).%OpenId(pJurisdiction, 0, .tSC)
		Throw:($$$ISERR(tSC)) tSC

		If $isobject(jurisdiction) {
			Set resp.rule = jurisdiction.Rule.Name,
				resp.id = pJurisdiction,
				resp.severity = jurisdiction.Rule.Severity
		}
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectJurisdictionDelete(pId, pJurisdiction)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).DeleteJurisdiction(pJurisdiction))
		Set resp.status = $$$OK

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectJurisdictionList(pId)
{
    Set tSC = $$$OK
	Try {
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Open(pId, .project))
		Set resp = $$$JsonNew,
			resp.id = project.%Id(),
			resp.name = project.Name,
			resp.namespace = project.Namespace,
			resp.jurisdictions = $$$JsonArray

		For idx=1:1:project.Jurisdictions.Count() {
			Set jurisdiction = project.Jurisdictions.GetAt(idx),
				aux = $$$JsonNew,
				aux.id = jurisdiction.%Id(),
				aux."rule_id" = jurisdiction.Rule.%Id(),
				aux.rule = jurisdiction.Rule.Name,
				aux.type = jurisdiction.Rule.TypeLogicalToDisplay(jurisdiction.Rule.Type),
				aux.severity = jurisdiction.Rule.Severity,
				aux.level = jurisdiction.Rule.OffenseLevel,
				aux.badge = jurisdiction.Rule.Badge
			$$$JsonAdd(resp.jurisdictions, aux)
		}

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectBribeCreate(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			className = $Get(%request.Data("className",1)),
			reason = $Get(%request.Data("reason",1)),
			userName = $Get(%request.Data("user",1))

		Throw:userName="" $$$ERROR(5002, "User is required")
		Throw:className="" $$$ERROR(5002, "Class is required")
		Throw:reason="" $$$ERROR(5002, "Reason is required")

		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).SaveBribe(pId, className, userName, reason))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
		Write $System.Status.GetErrorText(tSC)
	}
	Quit tSC
}

ClassMethod ProjectBribeUpdate(pId, pBribe)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			className = $Get(%request.Data("className",1)),
			reason = $Get(%request.Data("reason",1)),
			userName = $Get(%request.Data("user",1))

		Throw:userName="" $$$ERROR(5002, "User is required")
		Throw:className="" $$$ERROR(5002, "Class is required")
		Throw:reason="" $$$ERROR(5002, "Reason is required")

		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).SaveBribe(pId, className, userName, reason, pBribe))
		Set resp.mensage = "success"
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectBribeGet(pId, pBribe)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew,
			bribe = ##class(dredd.dad.BlindEye).%OpenId(pBribe, 0, .tSC)
		Throw:($$$ISERR(tSC)) tSC

		If $isobject(bribe) {
			Set resp.class = bribe.ClassName,
				resp.id = pBribe,
				resp.reason = bribe.Reason,
				resp.createdAt = bribe.CreatedAt,
				resp.updatedAt = bribe.UpdatedAt,
				resp.user = bribe.UserName
		}
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectBribeDelete(pId, pBribe)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).DeleteBribe(pBribe))

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod ProjectBribeList(pId)
{
    Set tSC = $$$OK
	Try {
		$$$THROWONERROR(tSC, ##class(dredd.dao.Project).Open(pId, .project))
		Set resp = $$$JsonNew,
			resp.id = project.%Id(),
			resp.name = project.Name,
			resp.namespace = project.Namespace,
			resp.bribes = $$$JsonArray

		For idx=1:1:project.Exceptions.Count() {
			Set bribe = project.Exceptions.GetAt(idx),
				aux = $$$JsonNew,
				aux.class = bribe.ClassName,
				aux.id = bribe.%Id(),
				aux.reason = bribe.Reason,
				aux.createdAt = bribe.CreatedAt,
				aux.updatedAt = bribe.UpdatedAt,
				aux.userName = bribe.UserName
			$$$JsonAdd(resp.bribes, aux)
		}

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod SessionGet(pId)
{
	Set tSC = $$$OK
	Try {
		Set resp = $$$JsonNew
		Set session = ##class(dredd.dad.Session).%OpenId(pId, 0, .tSC)

		If $isobject(session) {
			Set resp.id = pId,
				resp.startedAt = session.Started,
				resp.finishedAt = session.Finished,
				resp.status = session.Status,
				resp.project = session.Project.Name,
				resp.user = session.User,
				resp.offenses = $$$JsonArray
			Set idx = 0
			For idx=1:1:session.Offenses.Count() {
				Set violation = session.Offenses.GetAt(idx),
					offense = $$$JsonNew,
					offense.rule = violation.Rule.Name,
					offense.Location = violation.Location,
					offense.Message = violation.Message,
					offense.Severity = violation.Severity,
					offense.Documentation = violation.Rule.Documentation,
					offense.Badge = violation.Rule.Badge,
					offense.Level = violation.Rule.OffenseLevel
				$$$JsonAdd(resp.offenses, offense)
			}
		}
		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

ClassMethod SessionList()
{
    Set tSC = $$$OK
	Try {
		Set Sql = "SELECT ID, Finished, Project->Name As Project, Requisition, Started, Status, Targets, Token, ""User"" As Username FROM dredd_dad.Session",
			resp = $$$JsonNew,
			resp.sessions = $$$JsonArray
		Set tRS = ##class(%ResultSet).%New()
		$$$THROWONERROR(tSC, tRS.Prepare(Sql))
		$$$THROWONERROR(tSC, tRS.Execute())
		While (tRS.Next()) {
			Set session = $$$JsonNew,
				session.id = tRS.Get("ID"),
				session.startedAt = tRS.Get("Started"),
				session.finishedAt = tRS.Get("Finished"),
				session.status = tRS.Get("Status"),
				session.project = tRS.Get("Project"),
				session.user = tRS.Get("Username"),
				session.target = tRS.Get("Targets")

			$$$JsonAdd(resp.sessions, session)
		}

		$$$JsonOutput(resp)
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

}
