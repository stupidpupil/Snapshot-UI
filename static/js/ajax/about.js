function loadAbout() {
	
    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/about";

        function successAbout(id, o, args) {
            YUI().use('json-parse', function (Y) {
                var data, jsonString;
                jsonString = o.responseText;
                try {
                    data = Y.JSON.parse(jsonString);
                } catch (e) {
                    alert("Invalid version info");
                }
 
               	if (location.pathname.split("/")[1] === "link") {
                    parseLocation();
                } else {
					viewModel.selectedSnapshot.leftPanel(data.startingSnapshot)
					changePath(data.startingPath)
					ko.applyBindings(viewModel);
                }

				
            });
        }

        function failureAbout(id, o, args) {
			//showError("Error contacting server!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', successAbout, Y, []);
        Y.on('io:failure', failureAbout, Y, []);

        var request = Y.io.queue(uri);
    });
}