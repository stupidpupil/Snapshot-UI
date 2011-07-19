function initialize() {
    var i, j, nodeArr;
    header = document.getElementById("header");
    gPathComponentsSpan = document.getElementById("pathComponents");
    gPanels = [];
    
	gPanelArr = ["leftPanel", "rightPanel"];
    nodeArr = ["sidebar", "notSidebar", "detailsContainer", "infoBox", "filePreview", "snapshots"];
    
	for (i = gPanelArr.length - 1; i >= 0; i--) {
        gPanels[gPanelArr[i]] = document.getElementById(gPanelArr[i]);
        for (j = nodeArr.length - 1; j >= 0; j--) {
            gPanels[gPanelArr[i]][nodeArr[j]] = getElementForPanelAndClass(gPanelArr[i], nodeArr[j]);
        }
    }

	gShowingRightPanel = false
	gPathInfo = []
	
	resize();
	window.addEventListener('resize', resize, false);
	
	
    loadAbout();
	window.addEventListener('popstate', parseLocation, false);
	
	
	
}

window.addEventListener('pageshow', initialize, false);
