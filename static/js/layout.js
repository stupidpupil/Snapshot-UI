function resize(){
	if(document.getElementById("panes")){
		document.getElementById("panes").style.height = (document.body.clientHeight-document.getElementById("header").offsetHeight)+"px";
	}
	
	if(document.getElementById("leftDetailsView")){
		document.getElementById("leftDetailsView").style.height = (document.getElementById("leftNotsidebar").clientHeight-document.getElementById("leftSummary").offsetHeight)+"px";
	}
	
	if(document.getElementById("rightDetailsView")){
		document.getElementById("rightDetailsView").style.height = (document.getElementById("rightNotsidebar").clientHeight-document.getElementById("rightSummary").offsetHeight)+"px";
	}
	
	if(document.getElementById("diffContainer")){
		document.getElementById("diffContainer").style.height = document.getElementById("leftDetailsView").offsetHeight + "px"
		document.getElementById("diffContainer").style.width = document.getElementById("leftDetailsView").offsetWidth + document.getElementById("rightDetailsView").offsetWidth -1 + "px"
	}

}

function animateRightPanelTo(num){
	$('#leftpane').animate({'marginRight':num+'%'},500);
	resize();
}


function showRightPanel(bool){
	
	if (bool === true) {
		animateRightPanelTo(50)
		viewModel.activePanels(["leftPanel","rightPanel"])
        changeSnapshot('rightPanel', viewModel.selectedSnapshot.leftPanel());
    } else {
		animateRightPanelTo(0)
		viewModel.activePanels(["leftPanel"])
	
		viewModel.diffable(false)
		updateHistory();
		
		if (viewModel.detailsView() == 'diff'){
			setDetailsViewToDefault('leftPanel')
		}
    
	}
}

window.addEventListener('resize', resize, false);
window.addEventListener('pageshow', resize, false);
