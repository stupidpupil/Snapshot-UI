function aElemFromSnapshot(panel, snapshot) {
    link = document.createElement("a");
    link.appendChild(document.createTextNode(snapshot.name));
    link.snapId = snapshot.snapId;
    link.addEventListener("click", function () {
        changeSnapshot(panel, snapshot.snapId);
    }, false);
    if (snapshot.ctime) {
        link.title = new Date(parseInt(snapshot.ctime, 10) * 1000).toUTCString();
    }
    return link;
}

function showSnapshotAsSelected() {
    var snapDiv, l, i, j;
    for (i = 0; i < gPanelArr.length; i++) {
        snapDiv = getElementForPanelAndClass(gPanelArr[i], "snapshots");
        if (snapDiv.hasChildNodes()) {
            l = snapDiv.childNodes.length;
            for (j = 0; j < l; j++) {
                snapDiv.childNodes[j].className = "";
                if (snapDiv.childNodes[j].snapId === gSelectedSnapshot[gPanelArr[i]]) {
                    snapDiv.childNodes[j].className = "selected";
                    gSelectedSnapshotName[gPanelArr[i]] = snapDiv.childNodes[j].textContent;
                }
            }
        }
    }
}

function loadSnapshots() {
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/snapshots";
        var cfg = {
            method: "GET",
            data: {
                "path": gPath
            }
        };

        function completeSnapshots(id, o, args) {
            YUI().use('json-parse', function (Y) {
                var snapshot, snapDiv, h2, data, i;
                var jsonString = o.responseText;
                try {
                    data = Y.JSON.parse(jsonString);
                } catch (e) {
                    alert("Invalid snapshot info");
                }
                snapshots = data.snapshots;
                snapDiv = getElementForPanelAndClass("leftPanel", "snapshots");
                deleteChildren(snapDiv);
                deleteChildren(getElementForPanelAndClass("rightPanel", "snapshots"));
                h2 = document.createElement("h2");
                h2.appendChild(document.createTextNode("Snapshots"));
                snapDiv.appendChild(h2);
                getElementForPanelAndClass("rightPanel", "snapshots").appendChild(h2.cloneNode(true));
                for (i = 0; i < snapshots.length; i++) {
                    snapDiv.appendChild(aElemFromSnapshot("leftPanel", snapshots[i]));
                    getElementForPanelAndClass("rightPanel", "snapshots").appendChild(aElemFromSnapshot("rightPanel", snapshots[i]));
                }
                showSnapshotAsSelected();
                loadInfo(true, "both");
            });
        }

        function failureSnapshots(id, o, args) {
			showError("Error loading snapshots!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', completeSnapshots, Y, []);
        Y.on('io:failure', failureSnapshots, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}

function loadVersions() {
    var i;
    for (i = 0; i < gPanelArr.length; i++) {
        var expression = "//xhtml:div[@id='" + gPanelArr[i] + "']//xhtml:div[@class='snapshots']/xhtml:h2";
        var xpathResult = document.evaluate(expression, document, NSResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        xpathResult.singleNodeValue.textContent = "Loading Versions…";
    } //FFS
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/snapshots";
        var cfg = {
            method: "GET",
            data: {
                "path": gPath,
                "versions": "true"
            }
        };

        function completeVersions(id, o, args) {
            YUI().use('json-parse', function (Y) {
                var data, versions, j, i, snapshots, snapDiv, h2;
                var jsonString = o.responseText;
                try {
                    data = Y.JSON.parse(jsonString);
                } catch (e) {
                    alert("Invalid version info");
                }
                versions = data.versions;
                snapDiv = getElementForPanelAndClass("leftPanel", "snapshots");
                deleteChildren(snapDiv);
                deleteChildren(getElementForPanelAndClass("rightPanel", "snapshots"));
                for (j = 0; j < versions.length; j++) {
                    snapshots = versions[j];
                    h2 = document.createElement("h2");
                    h2.appendChild(document.createTextNode("Version " + (versions.length - j)));
                    snapDiv.appendChild(h2);
                    getElementForPanelAndClass("rightPanel", "snapshots").appendChild(h2.cloneNode(true)); //FIXME
                    for (i = 0; i < snapshots.length; i++) {
                        snapDiv.appendChild(aElemFromSnapshot("leftPanel", snapshots[i]));
                        getElementForPanelAndClass("rightPanel", "snapshots").appendChild(aElemFromSnapshot("rightPanel", snapshots[i])); //FIXME
                    }
                }
                showSnapshotAsSelected();
            });
        }

        function failureVersions(id, o, args) {
			showError("Error loading versions!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', completeVersions, Y, []);
        Y.on('io:failure', failureVersions, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}