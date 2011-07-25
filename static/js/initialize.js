function initialize() {
    var i, j, nodeArr;
    header = document.getElementById("header");
    gPathComponentsSpan = document.getElementById("pathComponents");
    gPanels = [];
    
	gPanelArr = ["leftPanel", "rightPanel"];
    
	for (i = gPanelArr.length - 1; i >= 0; i--) {
        gPanels[gPanelArr[i]] = document.getElementById(gPanelArr[i]);

    }

	gPathInfo = []
			
    loadAbout();
	window.addEventListener('popstate', parseLocation, false);
	
	
	
}

window.addEventListener('pageshow', initialize, false);
