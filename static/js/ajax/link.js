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