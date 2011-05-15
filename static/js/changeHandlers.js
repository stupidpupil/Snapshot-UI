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
    for (i = 0; i < gPanelArr.length; i++) {
        setPanelClass(gPanelArr[i], "loading");
        gPanels[gPanelArr[i]]["infoBox"].className = "infoBox loading";
        snapDiv = gPanels[gPanelArr[i]]["snapshots"];
        deleteChildren(snapDiv);
        h2 = document.createElement("h2");
        h2.className = "snapshotH2Header";
        h2.appendChild(document.createTextNode("Loading…"));
        snapDiv.appendChild(h2);
    }
    showDiff(false);
    gPath = newPath;
    showingPreview = false;
    loadSnapshots();
    writeOutPathComponents();
}

function changeSnapshot(panel, newSnapshot) {
	setDiffMessage("Loading…");
    setPanelClass(panel, "loading");
    gPanels[panel]["infoBox"].className = "infoBox loading";
    gSelectedSnapshot[panel] = newSnapshot;
    loadInfo(false, panel);
    showSnapshotAsSelected();
}