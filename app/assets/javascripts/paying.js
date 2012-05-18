$(document).ready(function() {
	// Have the ajax loader show when ajax is loading
	$('.ajax_loader').hide();
	$('.ajax_loader').ajaxStart(function() {
		$(this).show();
	});
	$('.ajax_loader').ajaxStop(function() {
		$(this).hide();
	});

	$('.cart_pay').click(function() {
		
	});

});