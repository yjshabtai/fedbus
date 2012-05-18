# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


`
// :( I don't know coffeescript very well yet. I am sorry. ): ~ Joe

$(document).ready(function(){

	$.get('/tickets/update_destinations', { dep: "0", date: $('#date_sel').val() }, function(data) {
		$("#destination").html(data);
	});

	// Choosing departure location ajax
	$('#departure').live('change', function(){
		var departureId = $('#departure').val();
		if (departureId == "") departureId = "0";
		var depDate = $('#date_sel').val();
		
		$.get('/tickets/update_destinations', { dep: departureId, date: depDate }, function(data) {
			$("#destination").html(data);
			$("#ticket_data").html("");
		});
	});
	
	// Choosing destination/bus ajax
	$('#bus_id').live('change', function(){
		var departureId = $('#departure').val();
		if (departureId == "") departureId = "0";
		var busId = $('#bus_id').val();
		if ($('#bus_id') == "") $("ticket_data").html("");
		
		$.get('/tickets/update_ticket_data', { dep: departureId, bus: busId }, function(data) {
			$("#ticket_data").html(data);
		});
	});
	
	// Updating price on checkbox select
	$('#trip_return').live('change', function(){
		checked = $('#trip_return').attr('checked');
		if(checked == 'checked') {
			$('#ticket_cost').hide();
			$('#ticket_cost2').show();
		}
		else {
			$('#ticket_cost2').hide();
			$('#ticket_cost').show();
		}
	});
	
});`