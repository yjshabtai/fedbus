$(document).ready(function() {
	// Have the ajax loader show when ajax is loading
	$('.ajax_loader').hide();
	$('.ajax_loader').ajaxStart(function() {
		$(this).show();
	});
	$('.ajax_loader').ajaxStop(function() {
		$(this).hide();
	});

	$('.departure_field').hide();
	$('.date_select').change(function() {
		get_deps( $(this).val() );
	});

});

// The ajax function to get the departure locations on the given date
function get_deps( date ) {
	$.ajax({
		url: '/tickets/find_deps',
		type: 'get',
		data: { date: date, buying: true },
		success: function(data) {
			$('.departure_field').show();
			$('.departure_field').html(data);
			dep_loader();
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}


// Sets the javascripts for the departure selecting partial _buying2.html.erb
function dep_loader() {
	$('.destination_field').hide();
	$('.dep_select').change(function() {
		get_dests( $(this).val(), $('.date_select').val() );
	});
}

// Finds all of the destinations for the given departure location
function get_dests( dep, date ) {
	$.ajax({
		url: '/tickets/find_dests',
		type: 'get',
		data: { dep_id: dep, date: date, buying: true },
		success: function(data) {
			$('.destination_field').show();
			$('.destination_field').html(data);
			dest_loader();
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

// Sets the javascripts for the destination selecting partial _buying3.html.erb
function dest_loader() {
	$('.ticket_info').hide();
	$('.dest_select').change(function() {
		get_data( $(this).val(), $('.dep_select').val() );
	});
}

// Gets the info for the selected bus
function get_data( bus, dep ) {
	$.ajax({
		url: '/tickets/ticket_data',
		type: 'get',
		data: { bus_id: bus, dep_id: dep, buying: true },
		success: function(data) {
			$('.ticket_info').show();
			$('.ticket_info').html(data);
			info_loader( bus );
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

// Sets the javascripts for the trip info and buy button
function info_loader( bus ) {
	var ret_b = false;

	$('.return_chk').change(function() {
		if ( $(this).attr('checked') ) {
			ret_b = true;
		}
		else {
			ret_b = false;
		}
		$.ajax({
			url: '/tickets/update_price',
			type: 'get',
			data: { bus_id: bus, ret: ret_b },
			success: function(data) {
				$('.ticket_price').html(data);
			},
			error: function(data) {
				alert('The server is not working.');
			}
		});
	});

	$('.cart_ticket').click(function() {
		reserve( $('.dest_select').val(), $('.dep_select').val(), ret_b );
	});
}

// Reserves the ticket for the selected bus and maybe return bus
function reserve( bus, dep, ret_b ) {
	$.ajax({
		url: '/tickets/reserve',
		type: 'post',
		data: { bus_id: bus, dep_id: dep, ret: ret_b, buying: true },
		success: function(data) {
			$('.buybox').html(data);
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}