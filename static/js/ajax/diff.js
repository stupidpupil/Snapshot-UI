function loadDiff() {
	
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
  				viewModel.diffXML(o.responseXML);
            }
        }

        function failureDiff(id, o, args) {
            var data = o.responseText;
			//showError("Error loading diff!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', successDiff, Y, []);
        Y.on('io:failure', failureDiff, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}

