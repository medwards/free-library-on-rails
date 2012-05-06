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

function validateISBN(isbnInput) {
	var isbn = isbnInput.val();

	var verdict = "bad length";
	if (isbn.length == 10) {
		if(checkISBN10(isbn))
			verdict = "good";
		else
			verdict = "bad checksum";
	} else if (isbn.length == 13) {
		if(checkISBN13(isbn))
			verdict = "good";
		else
			verdict = "bad checksum";
	}

	$("#isbn-validation").text(verdict);
}
