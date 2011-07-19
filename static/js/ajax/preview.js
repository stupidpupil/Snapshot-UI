function loadPreview(panel) {
    deleteChildren(getElementForPanelAndClass(panel, "previewContent"));
	viewModel.detailsVisible[panel]('preview')
	
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
                old = getElementForPanelAndClass(args[0], "previewContent");
                updated = document.importNode(previewPage.getElementById("preview"), true);
                deleteChildren(old);
                old.appendChild(updated);

            }
        }

        function failurePreview(id, o, args) {
            var loadingP;
            deleteChildren(getElementForPanelAndClass(args[0], "previewContent"));
            loadingP = document.createElement("span");
            loadingP.className = "previewError";
            loadingP.appendChild(document.createTextNode("An error occured while loading the preview."));
            getElementForPanelAndClass(args[0], "previewContent").appendChild(loadingP);
        }
        Y.on('io:success', successPreview, Y, [panel]);
        Y.on('io:failure', failurePreview, Y, [panel]);
        var request = Y.io.queue(uri, cfg);
    });
}