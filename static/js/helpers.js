function deleteChildren(elem) {
    if (elem.hasChildNodes()) {
        while (elem.childNodes.length >= 1) {
            elem.removeChild(elem.firstChild);
        }
    }
}

function NSResolver(prefix) {
    if (prefix === "xhtml") {
        return "http://www.w3.org/1999/xhtml";
    }
    return null;
}

function getElementForPanelAndClass(panelId, className) {
    var expression = "//xhtml:div[@id='" + panelId + "']//node()[contains(concat(' ',normalize-space(@class),' '),' " + className + " ')]";
    var xpathResult = document.evaluate(expression, document, NSResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
    return xpathResult.singleNodeValue;
}


function bytesToSize(bytes) {
    if (isNaN(bytes)) {
        return "--";
    }
    var sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes === 0) {
        return 'n/a';
    }
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10);
    return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[[i]];
}