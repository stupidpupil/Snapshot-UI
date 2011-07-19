function loadDiff() {
	viewModel.detailsVisible['leftPanel']('diff') 
	viewModel.detailsVisible['rightPanel']('diff') 
	
    setDiffMessage("Loading…");
	
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/diff";
        var cfg = {
            method: "GET",
            data: {
                "path": gPath,
                "snapshot": viewModel.selectedSnapshot.leftPanel(),
                "snapshot2": viewModel.selectedSnapshot.rightPanel()
            }
        };

        function successDiff(id, o, args) {
			var contentContainer;			
            var diffPage, updated;
            if (o.responseXML === null) {
                failureDiff(id, o, args);
            } else {
				contentContainer = document.getElementById("diffContent");
                diffPage = o.responseXML;
                updated = document.importNode(diffPage.getElementById("diff"), true);
                deleteChildren(contentContainer);
                contentContainer.appendChild(updated);
                setWidths();
            }
        }

        function failureDiff(id, o, args) {
            var data = o.responseText;
			setDiffMessage("Unable to show diff");
			showError("Error loading diff!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', successDiff, Y, []);
        Y.on('io:failure', failureDiff, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}

function setDiffMessage(message){
	var contentContainer, span;
	contentContainer = document.getElementById("diffContent");
	deleteChildren(contentContainer);
    span = document.createElement("span");
	span.className = "info";
	
	
    span.appendChild(document.createTextNode(message));
	contentContainer.appendChild(span);
}