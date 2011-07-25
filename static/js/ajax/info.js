
function allPanelsLoaded(){
	var panel;
	for (var i=0; i < viewModel.activePanels().length; i++) {
		panel = viewModel.activePanels()[i];
		if(viewModel.info[panel]() == null){
			return false;
		}
	};
	return true
}


function smartResetDetailsView(){
	var panel;
	
	panelId = 'leftPanel'
	if (viewModel.detailsView() == 'entries'){
		for (var i=0; i < viewModel.activePanels().length; i++) {
			panel = viewModel.activePanels()[i];
			if(viewModel.info[panel]().mimetype == "application/x-directory"){
				return;
			}
		};
		resetDetailsView()
		return;
	}


	if (viewModel.detailsView() == 'preview'){
		if(!(viewModel.previewable)){
			resetDetailsView()
		}
		return;
	}

	if (viewModel.detailsView() == 'diff'){
		if(!(viewModel.diffable)){
			resetDetailsView()
		}else{
			loadDiff()
		}
		return;
	}
	

	if (viewModel.detailsView() == null){
		 resetDetailsView()
		return;
	}
}

function resetDetailsView(){
	var panel;
	
	for (var i=0; i < viewModel.activePanels().length; i++) {
		panel = viewModel.activePanels()[i];
		if(viewModel.info[panel]().mimetype == "application/x-directory"){
			viewModel.detailsView('entries')
			return;
		}
	};
	
	viewModel.detailsView('info')
}

function loadInfo(pathChanged, panel) {
	

	viewModel.info[panel](null)
	viewModel.entries[panel].removeAll()
	viewModel.previewXML[panel](null)
			
	viewModel.diffXML(null)
	
	viewModel.diffable(false)
	
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/info";
        var cfg;
        if (viewModel.activePanels.indexOf("rightPanel") == -1) {
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

				var panel = args[1];
				
				var info;
				
				if(panel == 'leftPanel'){
					 info = data.info;
				}else{
					 info = data.info2;
				}			
				
				if(!info){//FIXME
					return;
				}
                
                
				if (info.mtime) {
				    info.mtime = new Date(parseInt(info.mtime, 10) * 1000);
				}

				viewModel.info[panel](info)

				if (info.entries) {
						viewModel.entries[panel](info.entries);
				}

			
				
				if(allPanelsLoaded()){
					viewModel.diffable(data.diffable)
					viewModel.previewable(getPreviewable());
					
					if (args[0]) { //Path Changed
	                	if (info && info.mimetype !== "application/x-directory") {
	                        loadVersions();
	                    }
						resetDetailsView()	
					}else{
						smartResetDetailsView()
						
					}
				}
				
				if(viewModel.detailsView() == 'preview' && info.preview){
					loadPreview(panel);
				}
				

				resize();
				//updateHistory(); 
					
            });
        }

        function failurePathInfo(transactionid, response, args) {
            if (response.status === 404) {
                //showError("No snapshots for path!", "No snapshots could be found for the specified path. This might result from a server configuration error, or you may have requested an outdated link.");
            }else{
				//showError("Error loading path info!", "Status:" + response.status + ", Text:" + response.text);
			}
        }
        Y.on('io:success', successPathInfo, Y, [pathChanged, panel]);
        Y.on('io:failure', failurePathInfo, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}