function showDataInPanel(panelId) {
    var data = gPathInfo[panelId];


    if (data.mtime) {
        data.mtime = new Date(parseInt(data.mtime, 10) * 1000);
    }

	viewModel.info[panelId](data)

    if (data.entries) {

		viewModel.entries[panelId](data.entries);
	
    }

}


function smartResetDetailsView(panelId){
	if (viewModel.detailsVisible[panelId]() == 'entries' && viewModel.info[panelId]().mimetype != "application/x-directory"){
		setDetailsViewToDefault(panelId)
		return;
	}


	if (viewModel.detailsVisible[panelId]() == 'preview' && !(viewModel.info[panelId]().preview)){
		setDetailsViewToDefault(panelId)
		return;
	}

	if (viewModel.detailsVisible[panelId]() == 'preview'){
		loadPreview(panelId)
		return;
	}
	

	if (viewModel.detailsVisible[panelId]() == null){
		setDetailsViewToDefault(panelId)
		return;
	}
}

function setDetailsViewToDefault(panelId){
	if(viewModel.info[panelId]() == null){
		return;
	}
	
	if (viewModel.info[panelId]().mimetype == "application/x-directory") {
		viewModel.detailsVisible[panelId]('entries')
	}else{
		viewModel.detailsVisible[panelId]('info')
	}
}

function loadInfo(pathChanged, panel) {
	
	
	if(panel == 'both'){
		viewModel.info['leftPanel'](null)
		viewModel.info['rightPanel'](null)
		viewModel.entries['leftPanel'].removeAll()
		viewModel.entries['rightPanel'].removeAll()
		
		viewModel.needsSnapshotSelection["leftPanel"](false)
		viewModel.needsSnapshotSelection["rightPanel"](false)
		
	}else{
		viewModel.info[panel](null)
		viewModel.entries[panel].removeAll()
		viewModel.needsSnapshotSelection[panel](false)
	}
	
	viewModel.diffable(false)
	
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/info";
        var cfg;
        if (!gShowingRightPanel) {
            cfg = {
                method: "GET",
                data: {
                    "path": gPath,
                    "snapshot": viewModel.selectedSnapshot.leftPanel()
                }
            };
        } else {
            cfg = {
                method: "GET",
                data: {
                    "path": gPath,
                    "snapshot": viewModel.selectedSnapshot.leftPanel(),
                    "snapshot2": viewModel.selectedSnapshot.rightPanel()
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

				//Panel-sensitivity
                if (args[1] === "both" || args[1] === "leftPanel") {
                    if (data.info) {
                        gPathInfo.leftPanel = data.info;
                        showDataInPanel("leftPanel");
                    }else{
						viewModel.needsSnapshotSelection.leftPanel(true);
					}
                }
                if (args[1] === "both" || args[1] === "rightPanel") {
                    if (data.info2) {
                        gPathInfo.rightPanel = data.info2;
                        showDataInPanel("rightPanel");
                    }else{
						viewModel.needsSnapshotSelection.rightPanel(true);
					}
                }

				viewModel.diffable(data.diffable)


                if (args[0]) { //Path Changed
                    if ((data.info && data.info.mimetype !== "application/x-directory")
 					|| (data.info2 && data.info2.mimetype !== "application/x-directory")) {
                        loadVersions();
                    }

	                if (args[1] === "both" || args[1] === "leftPanel") {
						setDetailsViewToDefault("leftPanel")
					}
					
					if (args[1] === "both" || args[1] === "rightPanel") {
						setDetailsViewToDefault("rightPanel")
					}
					
				}else{
					
					if (args[1] === "both" || args[1] === "leftPanel") {
						smartResetDetailsView("leftPanel")
					}
					
					if (args[1] === "both" || args[1] === "rightPanel") {
						smartResetDetailsView("rightPanel")
					}
					
					
					if (viewModel.detailsVisible.leftPanel() == 'diff' && viewModel.detailsVisible.leftPanel() == 'diff'){
						if (viewModel.diffable()){
							loadDiff()
						}else{
							setDetailsViewToDefault("leftPanel")
							setDetailsViewToDefault("rightPanel")
						}
					}
				}
				
				 updateHistory(); 
					
            });
        }

        function failurePathInfo(transactionid, response, args) {
            if (response.status === 404) {
                showError("No snapshots for path!", "No snapshots could be found for the specified path. This might result from a server configuration error, or you may have requested an outdated link.");
            }else{
				showError("Error loading path info!", "Status:" + response.status + ", Text:" + response.text);
			}
        }
        Y.on('io:success', successPathInfo, Y, [pathChanged, panel]);
        Y.on('io:failure', failurePathInfo, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}