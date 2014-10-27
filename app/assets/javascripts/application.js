//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//
//= require isbnvalidation
//
//= require_self

$(document).ready(function() {
	$("input.return-date").datepicker({
		minDate:    0,
		dateFormat: 'yy-mm-dd'
	});
});
