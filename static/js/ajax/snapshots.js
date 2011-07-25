function loadSnapshots() {
	viewModel.snapshots.removeAll();				
	viewModel.versions.removeAll();				
	
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

             	viewModel.snapshots(snapshots);		
                
            });
        }

        function failureSnapshots(id, response, args) {
			//showError("Error loading snapshots!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', completeSnapshots, Y, []);
        Y.on('io:failure', failureSnapshots, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}

function loadVersions() {

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
				viewModel.versions.removeAll();				
			
                for (j = 0; j < versions.length; j++) {
					newVer = ko.observableArray(versions[j])
					newVer().i = versions.length-j	
		       		viewModel.versions.push(newVer);
				}
            });
        }

        function failureVersions(id, response, args) {
			//showError("Error loading versions!", "Status:" + response.status + ", Text:" + response.text);
        }

        Y.on('io:success', completeVersions, Y, []);
        Y.on('io:failure', failureVersions, Y, []);
        var request = Y.io.queue(uri, cfg);
    });
}