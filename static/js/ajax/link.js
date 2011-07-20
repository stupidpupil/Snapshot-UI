function decryptLink(linkID, panel) {
    YUI().use("io-queue", function (Y) {
        var uri = "/decrypt";
        var cfg = {
            method: "GET",
            data: "id=" + linkID
        };

        function successDecrypt(id, o, args) {
            YUI().use('json-parse', function (Y) {
                var data;
                var jsonString = o.responseText;
                try {
                    data = Y.JSON.parse(jsonString);
                } catch (e) {
                    alert("Invalid snapshot info");
                }
                viewModel.selectedSnapshot[args[0]](data.snapshot);
                if (viewModel.selectedSnapshot.leftPanel() && (!gShowingRightPanel || viewModel.selectedSnapshot.rightPanel())) {
                    changePath(data.path);
                }
				ko.applyBindings(viewModel);

            });
        }

        function failureDecrypt(id, o, args) {
            showError("Unable to decrypt link!", "The link requested could not be decrypted. The server key may have changed since the link was generated or the the link may have been entered incorrectly.");
        }
        Y.on('io:success', successDecrypt, Y, [panel]);
        Y.on('io:failure', failureDecrypt, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}

// Helpers?

function updateHistory() { /* Errors abound */
	var title, linkURI;
    title = ""
	linkURI = ""

	if(viewModel.info.leftPanel() != null){
		title = title + gPath + " @ " + viewModel.selectedSnapshot.leftPanel();
		linkURI = linkURI + "/link/" + viewModel.info.leftPanel().link;
	}
	
	if(viewModel.info.rightPanel() != null){
		title = title + " & " + viewModel.selectedSnapshot.rightPanel();
		linkURI = linkURI + "/" + viewModel.info.rightPanel().link;
	}
	
    window.history.pushState(null, title, linkURI);
    document.title = title;
}

function parseLocation() {
    decryptLink(location.pathname.split("/")[2], "leftPanel");
    if (location.pathname.split("/")[3]) {
        showRightPanel(true, false);
        decryptLink(location.pathname.split("/")[3], "rightPanel");
    } else {
		if(gShowingRightPanel === true){
        	showRightPanel(false);
		}
    }
}