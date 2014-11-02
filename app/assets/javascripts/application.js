//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require jquery-ui/autocomplete
//= require jquery.tagsinput
//
//= require isbnvalidation
//
//= require_self

$(document).ready(function() {
	$("input.return-date").datepicker({
		minDate:    0,
		dateFormat: 'yy-mm-dd'
	});

	$("input.tags").tagsInput({
		autocomplete_url: '/tags/autocomplete',
		autocomplete: {minLength: 2},
		minChars: 2,
		height: 'inherit',
		width: 'inherit'
	});
});
