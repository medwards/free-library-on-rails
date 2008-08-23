function checkISBN10(isbn) {
	var sum = 0;

	for(var i = 10; i > 0; i--) {
		var character = isbn[10-i];

		if(character == 'x' || character == 'X') {
			if(i != 1)
				/* Xs can only be at the end */
				return false;

			sum += 10;
		} else {
			sum += (parseInt(character) * i)
		}
	}

	return (sum % 11) == 0;
};

function checkISBN13(isbn) {
	var sum = 0;
	var weight;

	for(var i = 0; i < 12; i++) {
		var character = isbn[i];

		if(i % 2 == 0)
			weight = 1;
		else
			weight = 3;

		sum += (parseInt(character) * weight);
	}

	var checkDigit = parseInt(isbn[12]);

	var mod = sum % 10;
	if(mod == 0)
		return checkDigit == 0;
	else
		return (checkDigit + mod) == 10;
};

function validateISBN() {
	var fieldValue = $("isbn").getValue();
	var stripped = fieldValue.gsub(/[^0-9Xx]/, '');

	var verdict = "bad length";
	if (stripped.length == 10) {
		if(checkISBN10(stripped))
			verdict = "good";
		else
			verdict = "bad checksum";
	} else if (stripped.length == 13) {
		if(checkISBN13(stripped))
			verdict = "good";
		else
			verdict = "bad checksum";
	}

	$("isbn-validation").innerHTML = verdict;
}

/* set up the validation code */
Event.observe(window, 'load', function(){
	var isbnValidation = new Element('span');
	isbnValidation.writeAttribute('id', 'isbn-validation');
	$("isbn").up().insert(isbnValidation);

	validateISBN();

	new Form.Element.Observer($("isbn"), 1, function(){
		validateISBN();
	});
});
