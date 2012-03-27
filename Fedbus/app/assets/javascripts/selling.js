$(document).ready(function() {
	$('.stud_num').focus();
	$('.ajax_loader').hide();
	$('.hidden_fields').hide();

	$('.stud_num').keyup(function() {
		if ( $('.stud_num').val().length == 8 ) {
			search_user($('.stud_num').val());
		}
	});

	ajax_loader();
});

function search_user( stud_num ) {
	$.ajax({
		url: '/tickets/find_user',
		type: 'get',
		data: { student_num: stud_num},
		success: function(data) {
			if ( data == 'false') {
				$('.hidden_fields').show();
				$('.userid').focus();
			}
			else {
				$('.sellbox').html(data);
				pg1_loader();
			}
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

function ajax_loader() {
	$('.ajax_loader').ajaxStart(function() {
		$(this).show();
	});
	$('.ajax_loader').ajaxStop(function() {
		$(this).hide();
	});
}

// Loads up the javascript for the 1st ticket selling partial (date select)
function pg1_loader() {
	$('.departure_field').hide();
	$('.date_select').change(function() {
		get_deps( $(this).val() );
	});
}

// Loads up the javascript for the 2nd ticket selling page (destination select)
function pg2_loader() {
	$('.destination_field').hide();
	$('.dep_select').change(function() {
		get_dests( $(this).val(), $('.date_select').val() );
	});
}

// Loads up the javascript for the 3rd ticket selling page (info)
function pg3_loader() {
	$('.ticket_info').hide();
	$('.dest_select').change(function() {
		get_data( $(this).val(), $('.dep_select').val() );
	});
}

// Finds all of the destinations for departure on the given date
function get_deps( date ) {
	$.ajax({
		url: '/tickets/find_deps',
		type: 'get',
		data: { date: date },
		success: function(data) {
			$('.departure_field').show();
			$('.departure_field').html(data);
			pg2_loader();
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

// Finds all of the destinations for the given departure location
function get_dests( dep, date ) {
	$.ajax({
		url: '/tickets/find_dests',
		type: 'get',
		data: { dep_id: dep, date: date },
		success: function(data) {
			$('.destination_field').show();
			$('.destination_field').html(data);
			pg3_loader();
		},
		error: function(data) {
			alert('There is something wrong here. Get an admin.');
		}
	});
}

// Gets the info for the selected bus
function get_data( bus, dep ) {
	$.ajax({
		url: '/tickets/ticket_data',
		type: 'get',
		data: { bus_id: bus, dep_id: dep },
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

	//$('.cart_ticket').click(function() {
	//	reserve( $('.dest_select').val(), $('.dep_select').val(), ret_b );
	//});
}