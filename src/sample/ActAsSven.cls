Class sample.page.ActAsSven Extends %ZEN.Component.page
{

Parameter APPLICATION = "HPardini.LisFront.Atendimento.Base.Aplicacao";

Property Parametro As %String(ZENURL = "Parametro");

Parameter PRIVATE = 0;

XData Style
{
<style type="text/css">

</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen"  title="Sven" id="page_root"  >
<group id="root" />
</page>
}

/// Dispatcher para Get
ClientMethod get(route, params) [ Language = javascript ]
{
	switch (route) {
		case 'rota':
			//return zenPage.ZenMethod(params.idExame, zenPage.IdOperadora);
			break;

		default:
			console.error("No Route with this name");
	}
}

/// Dispatcher para Post
ClientMethod post(route, params) [ Language = javascript ]
{
	switch (route) {
		case 'rota':
			//zenPage.chamaZenMethod(params);
			break;


		default:
			console.error("No Route with this name");
	}
}

ClientMethod onloadHandler() [ Language = javascript ]
{

	sessionStorage.clear();
	if(!sessionStorage.getItem('@CachedSession:CachedStruct')){
		sessionStorage.setItem('@CachedSession:CachedStruct', zenPage.Parametro);
	}


	svelteRun(this);
 	function svelteRun(zenComponent){
	 		 //# Svelte build
	}
}

}
