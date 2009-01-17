function dont_send_sms() {
	$$('.sms_input').each(Element.hide);
	$('user_cellphone').setValue(null);
	$('user_cellphone_provider').setValue(null);
}

function do_send_sms() {
	$$('.sms_input').each(Element.show);
	$('user_cellphone').enable();
	$('user_cellphone_provider').enable();
}

Event.observe(window, 'load', function() {
	var tr = '<tr><td><label for="send_sms">Send SMS notifications?</label></td>'
	tr += '<td><input type="checkbox" id="send_sms"></td></tr>'

	$$('.sms_input')[0].insert({before: tr});

	var send_sms = $("send_sms");

	if($('user_cellphone').getValue().empty())
		dont_send_sms();
	else
		send_sms.setValue(true);

	send_sms.observe('click', function() {
		if(send_sms.getValue())
			do_send_sms();
		else
			dont_send_sms();
	});
});
