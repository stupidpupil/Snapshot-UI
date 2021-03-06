function deleteChildren(elem) {
    if (elem.hasChildNodes()) {
        while (elem.childNodes.length >= 1) {
            elem.removeChild(elem.firstChild);
        }
    }
}

function NSResolver(prefix) {
    if (prefix === "xhtml") {
        return "http://www.w3.org/1999/xhtml";
    }
    return null;
}

function getElementForPanelAndClass(panelId, className) {
    var expression = "//xhtml:div[@id='" + panelId + "']//node()[contains(concat(' ',normalize-space(@class),' '),' " + className + " ')]";
    var xpathResult = document.evaluate(expression, document, NSResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    return xpathResult.singleNodeValue;
}

function sortEntries(panel, sortBy){
	var entries = viewModel.entries[panel]().slice();
	
	entries = entries.sort(function(a,b){
		 if (a[sortBy] < b[sortBy]) return -1;
		    if (a[sortBy] > b[sortBy]) return 1;
		    return 0;	
	});
	
	if (viewModel.entries[panel]()[0] == entries[0]){//This is obviously terrible but it'll do. I believe the worst outcome is curiously reversed ordering at times.
		entries = entries.reverse()
	}
	
	viewModel.entries[panel](entries);
}

function bytesToSize(bytes) {
    if (isNaN(bytes)) {
        return "--";
    }
    var sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes === 0) {
        return 'n/a';
    }
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10);
    return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[[i]];
}

function getPreviewable(){
	for (var i=0; i < viewModel.activePanels().length; i++) {
		var panel = viewModel.activePanels()[i];
		if(viewModel.info[panel]() != null && viewModel.info[panel]().preview){
			return true;
		}
	}
	return false;
}

function getEntreable(){
	for (var i=0; i < viewModel.activePanels().length; i++) {
		var panel = viewModel.activePanels()[i];
		if(viewModel.info[panel]() != null && viewModel.info[panel]().directory){
			return true;
		}
	}
	return false;
}

function switchToPreview(){
	if(!(viewModel.previewable())){
		return;
	}
	
	viewModel.detailsView('preview')
	for (var i=0; i < viewModel.activePanels().length; i++) {
		var panel = viewModel.activePanels()[i]
		if(viewModel.previewXML[panel]() == null && viewModel.info[panel]().preview){
			loadPreview(panel)
		}
	};
	resize;
}

function switchToDiff(){
	if(!(viewModel.diffable())){
		return;
	}
	
	viewModel.detailsView('diff')
	resize;
	loadDiff()
}