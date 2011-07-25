function loadPreview(panel) {
	
	//FIXME Add 'Loading..' somehow to preview view

    YUI().use("io-queue", "querystring-stringify-simple", function (Y) {
        var uri = "/preview";
        var cfg = {
            method: "GET",
            data: {
                "path": gPath,
                "snapshot": viewModel.selectedSnapshot[panel]()
            }
        };

        function successPreview(id, o, args) {
            var previewPage, old, updated;
            if (o.responseXML === null) {
                failurePreview(id, o, args);
            } else {	
                previewPage = o.responseXML;
				viewModel.previewXML[args[0]](previewPage)
            }
        }

        function failurePreview(id, o, args) {

        }
        Y.on('io:success', successPreview, Y, [panel]);
        Y.on('io:failure', failurePreview, Y, [panel]);
        var request = Y.io.queue(uri, cfg);
    });
}