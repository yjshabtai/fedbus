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
		if ( $(this).val().length > 0 ) {
			get_deps( $(this).val() );
		}
		else {
			$('.departure_field').html('');
			$('.departure_field').hide();
		}
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
		if ( $(this).val().length > 0 ) {
			get_dests( $(this).val(), $('.date_select').val() );
		}
		else {
			$('.destination_field').html('');
			$('.destination_field').hide();
		}
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
		if ( $(this).val().length > 0 ) {
			get_data( $(this).val(), $('.dep_select').val() );
		}
		else {
			$('.ticket_info').html('');
			$('.ticket_info').hide();
		}
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
			info_loader();
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

// Sets the javascripts for the trip info and buy button
function info_loader() {

	$('.return_time').change(function() {
		if ( $(this).val().length > 0 ) {

			var ret_date = $(this).val();
			var bus = $('.dest_select').val();
			var dep = $('.dep_select').val();
			
			$.ajax({
				url: '/tickets/find_returns',
				type: 'get',
				data: { bus_id: bus, dep_id: dep, ret_date: ret_date },
				success: function(data) {
					$('.return_from').show();
					$('.return_from').html(data);
					return_loader();
				},
				error: function(data) {
					alert('There is something wrong here. Get an admin.');
				}
			});
		}
		else {
			$('.return_from').html('');
			$('.return_from').hide();
			price_change();
		}

	});

	$('.info_pane').click(function() {
		pane_info(this);
	});

	$('.cart_ticket').click(function() {
		reserve( $('.dest_select').val(), $('.dep_select').val(), ret_b );
	});
}

function return_loader() {
	price_change();
	return_info_change();
	$('.return_bus').change(function() {
		price_change();
		return_info_change();
	});
}

function price_change() {
	var bus = $('.dest_select').val();
	var r_bus = $('.return_bus').val();

	var returning = false;
	if ( $('.return_time').val().length > 1 ) {
		returning = true;
	}

	$.ajax({
		url: '/tickets/update_price',
		type: 'get',
		data: { bus_id: bus, rbus_id: r_bus, ret: returning },
		success: function(data) {
			$('.ticket_price').html(data);
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

function return_info_change() {
	var r_bus = $('.return_bus').val();
	var dep = $('.dep_select').val();

	$.ajax({
		url: '/tickets/ticket_data_r',
		type: 'get',
		data: { rb_id: r_bus, dep_id: dep },
		success: function(data) {
			$('.rbus_info').html(data);
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
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

function pane_info( pane ) {
	$(pane).animate({ "padding-right": "50px"});
}