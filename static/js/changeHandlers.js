function writeOutPathComponents() {
    var components, clickFunction, i;
	deleteChildren(gPathComponentsSpan)

    components = gPath.split("/");
    clickFunction = function () {
        changePath(this.id);
    };
    for (i = 0; i < components.length; i++) {
        link = document.createElement("a");
        link.appendChild(document.createTextNode(components[i]));
        link.id = components.slice(0, i + 1).join("/");
        link.addEventListener("click", clickFunction, false);
        gPathComponentsSpan.appendChild(link);
    }
}

function changePath(newPath) {
    var snapDiv, h2, i;

    gPath = newPath;

	loadInfo(true, "both");
    loadSnapshots();
    writeOutPathComponents();
}

function changeSnapshot(panel, newSnapshot) {
    viewModel.selectedSnapshot[panel](newSnapshot);
    loadInfo(false, panel);
}