function generatePathComponentsForPath(path){
	basic = path.split("/")
	
	ret = []
	
	for (var i=0; i < basic.length; i++) {
		comp = []
		comp.basename = basic[i]
		comp.path = basic.slice(0,i+1).join("/")
		ret.push(comp)
	};
	return ret
}


function changePath(newPath) {
    var snapDiv, h2, i;

    gPath = newPath;

	viewModel.detailsView(null)
	
	loadInfo(true, "leftPanel");
	loadInfo(true, "rightPanel");
	
    loadSnapshots();
    viewModel.pathComponents(generatePathComponentsForPath(gPath));
}

function changeSnapshot(panel, newSnapshot) {
    viewModel.selectedSnapshot[panel](newSnapshot);
    loadInfo(false, panel);
}