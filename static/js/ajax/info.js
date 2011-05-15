function showDataInPanel(panelId) {
    var data = gPathInfo[panelId];
    if (data.entries) {
        var entries = data.entries;
        var l = entries.length;
        var i;
        var tbody = getElementForPanelAndClass(panelId, "directoryEntriesBody");
        var textNode;
        deleteChildren(tbody);
        var onclickFunction = function () {
                changePath(gPath + "/" + this.id);
            };
        for (i = 0; i < l; i++) {
            tr = document.createElement("tr");
            td = document.createElement("td");
            tr.appendChild(td);
            td.appendChild(document.createTextNode(entries[i].filename));
            td.className = entries[i].folder ? "folder" : "document";
            td = document.createElement("td");
            tr.appendChild(td);
            date = new Date(parseInt(entries[i].mtime, 10) * 1000);
            td.appendChild(document.createTextNode(date.toUTCString()));
            td = document.createElement("td");
            tr.appendChild(td);
            textNode = document.createTextNode(bytesToSize(parseInt(entries[i].size, 10)));
            td.appendChild(textNode);
            tbody.appendChild(tr);
            tr.id = entries[i].filename;
            tr.addEventListener("click", onclickFunction, false);
        }
    }
    fdTableSort.prepareTableData(getElementForPanelAndClass(panelId, "directoryEntriesBody").parentNode);
    fdTableSort.jsWrapper(getElementForPanelAndClass(panelId, "directoryEntriesBody").parentNode.id, 0);
    details = getElementForPanelAndClass(panelId, "fileDetailsTable");
    deleteChildren(details);
    if (data.filename) {
        getElementForPanelAndClass(panelId, "filenameSpan").textContent = data.filename;
    }
    if (data.mtime) {
        date = new Date(parseInt(data.mtime, 10) * 1000);
        getElementForPanelAndClass(panelId, "mtimeSpan").textContent = "Modified: " + date.toUTCString();
    }
    if (data.kind) {
        tr = document.createElement("tr");
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode("Kind"));
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode(data.kind));
        details.appendChild(tr);
    }
    if (data.mtime) {
        tr = document.createElement("tr");
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode("Modified"));
        td = document.createElement("td");
        tr.appendChild(td);
        date = new Date(parseInt(data.mtime, 10) * 1000);
        td.appendChild(document.createTextNode(date.toUTCString()));
        details.appendChild(tr);
    }
    if (data.ctime) {
        tr = document.createElement("tr");
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode("Created"));
        td = document.createElement("td");
        tr.appendChild(td);
        date = new Date(parseInt(data.ctime, 10) * 1000);
        td.appendChild(document.createTextNode(date.toUTCString()));
        details.appendChild(tr);
    }
    if (data.size) {
        tr = document.createElement("tr");
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode("Size"));
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode(bytesToSize(parseInt(data.size, 10)) + " (" + data.size + " bytes)"));
        details.appendChild(tr);
    }
    if (data.mimetype) {
        tr = document.createElement("tr");
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode("Mime-type"));
        td = document.createElement("td");
        tr.appendChild(td);
        td.appendChild(document.createTextNode(data.mimetype));
        details.appendChild(tr);
        if (data.mimetype === "application/x-directory") {
            tr = document.createElement("tr");
            td = document.createElement("td");
            tr.appendChild(td);
            td.appendChild(document.createTextNode("Contents"));
            td = document.createElement("td");
            tr.appendChild(td);
            td.appendChild(document.createTextNode(data.entries.length + " items"));
            details.appendChild(tr);
            setPanelClass(panelId, "dirContents");
            getElementForPanelAndClass(panelId, "infoBox").className = "infoBox directory";
        } else {
            if (data.preview === true) {
                getElementForPanelAndClass(panelId, "infoBox").className = "infoBox file previewable";
                setPanelClass(panelId, "fileInfo");
            } else {
                getElementForPanelAndClass(panelId, "infoBox").className = "infoBox file";
                setPanelClass(panelId, "fileInfo");
            }
        }
    }
    getElementForPanelAndClass(panelId, "downloadLink").href = "/download/" + data.link;
}

function loadInfo(shouldLoadVersions, panel) {
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/info";
        var cfg;
        if (!gShowingRightPanel) {
            cfg = {
                method: "GET",
                data: {
                    "path": gPath,
                    "snapshot": gSelectedSnapshot.leftPanel
                }
            };
        } else {
            cfg = {
                method: "GET",
                data: {
                    "path": gPath,
                    "snapshot": gSelectedSnapshot.leftPanel,
                    "snapshot2": gSelectedSnapshot.rightPanel
                }
            };
        }

        function successPathInfo(id, o, args) {
            YUI().use('json-parse', function (Y) {
                var data;
                var jsonString = o.responseText;
                try {
                    data = Y.JSON.parse(jsonString);
                } catch (e) {
                    alert("Invalid path info");
                }
                if (args[1] === "both" || args[1] === "leftPanel") {
                    if (data.info) {
                        gPathInfo.leftPanel = data.info;
                        showDataInPanel("leftPanel");
                    } else {
                        setPanelClass("leftPanel", "nosnapshot");
                    }
                }
                if (args[1] === "both" || args[1] === "rightPanel") {
                    if (data.info2) {
                        gPathInfo.rightPanel = data.info2;
                        showDataInPanel("rightPanel");
                    } else {
                        setPanelClass("rightPanel", "nosnapshot");
                    }
                }
                updateHistory();
                if (args[0]) { //loadVersions
                    if ((data.info && data.info.mimetype !== "application/x-directory")
 					|| (data.info2 && data.info2.mimetype !== "application/x-directory")) {
                        loadVersions();
                    }
                }
                if (data.diffable) {
                    var infoBox = gPanels.rightPanel.infoBox;
                    infoBox.className = "diffable " + infoBox.className;
                    if (gShowingDiff) {
                        loadDiff();
                    }
                } else {
                    if (gShowingDiff) {
                        showDiff(false);
                    }
                }
            });
        }

        function failurePathInfo(transactionid, response, args) {
            if (response.status === 404) {
                showError("No snapshots for path!", "No snapshots could be found for the specified path. This might result from a server configuration error, or you may have requested an outdated link.");
            }else{
				showError("Error loading path info!", "Status:" + response.status + ", Text:" + response.text);
			}
        }
        Y.on('io:success', successPathInfo, Y, [shouldLoadVersions, panel]);
        Y.on('io:failure', failurePathInfo, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}