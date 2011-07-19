function showError(title, description) {
    document.getElementById("errorHeader").textContent = title;
    document.getElementById("errorDescription").textContent = description;
    orderSheetOut("errorSheet", true);
}

function orderSheetOut(sheetID, bool) {
    var sheet = document.getElementById(sheetID);
    var header = document.getElementById("header");
    YUI().use('anim', function (Y) {
		var shownTop = (header.offsetHeight + gPathComponentsSpan.offsetHeight - 5);
		var hiddenTop = -(sheet.offsetHeight);
	
        var anim1 = new Y.Anim({
            node: '#' + sheetID,
            from: {
                top: !bool ? shownTop : hiddenTop
            },
            to: {
                top: bool ? shownTop : hiddenTop
            },
            duration: 0.25,
            easing: Y.Easing.easeIn
        });
        anim1.on('end', function (ev) {
            if (!bool) {
                sheet.style.top = -window.innerWidth + "px";
            }
        });
        anim1.run();
    });
}

/* Right Panel */

function showRightPanel(bool, load) {
    gShowingRightPanel = bool;
    if (bool === true) {
        if (load) {
            changeSnapshot('rightPanel', viewModel.selectedSnapshot.leftPanel());
        }
    } else {
        if (viewModel.selectedSnapshot.rightPanel()) { //HORRIBLE HORRIBLE HACK
            //updateHistory(); //Got to get rid of the last part of the link
        }
		
		if (viewModel.detailsVisible.leftPanel() == 'diff'){
			setDetailsViewToDefault('leftPanel')
		}
		
    }
    animateRightPanel(bool);
}


function animateRightPanel(show) {
    YUI().use('anim', function (Y) {	
        var anim1 = new Y.Anim({
            node: gPanels.rightPanel,
            from: {
                right: !show ? 0 : -gPanels.rightPanel.offsetWidth
            },
            to: {
                right: show ? 0 : -gPanels.rightPanel.offsetWidth
            },
            duration: 0.25,
            easing: Y.Easing.easeIn
        });

        anim1.on('tween', function (ev) {
            setWidths();
        });


        var anim2 = new Y.Anim({
            node: gPanels.rightPanel.sidebar,
            from: {
                right: !show ? 0 : -gPanels.rightPanel.sidebar.offsetWidth
            },
            to: {
                right: show ? 0 : -gPanels.rightPanel.sidebar.offsetWidth
            },
            duration: 0.3,
            easing: Y.Easing.easeOut
        });

        anim2.on('end', function (ev) {
            setWidths();
        });

        anim1.run();
        anim2.run();
    });
}


/* Resizing */

function resize() {
	//Not great
    gPanels.rightPanel.style.right = gShowingRightPanel ? 0 : - Math.floor(window.innerWidth / 2) + "px";
    gPanels.rightPanel.sidebar.style.right = gShowingRightPanel ? 0 : (gPanels.leftPanel.sidebar.offsetWidth + 1) + "px";
    
	setWidths();
    setHeights();
}

function setHeights() {
    var panelHeight, infoBoxHeight, i, nodes;
 
   	panelHeight = (window.innerHeight - (header.offsetHeight + gPathComponentsSpan.offsetHeight)) + 3;
    gPanels.leftPanel.style.height = panelHeight + "px";
    gPanels.rightPanel.style.height = panelHeight + "px";

    for (i = gPanelArr.length - 1; i >= 0; i--) {
        nodes = gPanels[gPanelArr[i]];
        nodes.sidebar.style.height = panelHeight + "px";
        nodes.notSidebar.style.height = panelHeight + "px";
        nodes.detailsContainer.style.height = (panelHeight - nodes.infoBox.offsetHeight) + "px";
    }

    infoBoxHeight = 85 //Math.max(gPanels.leftPanel.infoBox.offsetHeight, gPanels.rightPanel.infoBox.offsetHeight);
    document.getElementById("diffContainer").style.height = panelHeight - (infoBoxHeight - 3) + "px";
}

function setWidths() {
    var leftPanelWidth, diffContainerWidth, leftNotSideBarWidth, i, nodes, leftSideCol;

	if(gPanels.rightPanel.offsetLeft < 1){
		leftPanelWidth = window.innerWidth;
	}else{
		leftPanelWidth = gPanels.rightPanel.offsetLeft;
	}
	
    gPanels.rightPanel.style.width = Math.floor(window.innerWidth / 2) + "px";
    gPanels.leftPanel.style.width = leftPanelWidth + "px";

    leftNotSideBarWidth = leftPanelWidth - gPanels.leftPanel.sidebar.offsetWidth;
    gPanels.leftPanel.notSidebar.style.width = leftNotSideBarWidth + "px";
    gPanels.rightPanel.notSidebar.style.width = leftNotSideBarWidth + "px"; //Works, even if you can see why it's a bad idea
   
    for (i = gPanelArr.length - 1; i >= 0; i--) {
        nodes = gPanels[gPanelArr[i]];
        nodes.detailsContainer.style.width = (nodes.notSidebar.offsetWidth) + "px";
    }

    diffContainerWidth = (leftNotSideBarWidth * 2) + 1;
    document.getElementById("diffContainer").style.width = diffContainerWidth + "px";
    leftSideCol = document.getElementById("leftDiffCol");
    if (leftSideCol) {
        leftSideCol.style.width = leftNotSideBarWidth - 35 + "px";
    }


}