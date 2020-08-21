

$(document).ready( function() {
    $.ajax( {	
	url: '/rest/user/login_button_html',
	error: function(r) { alert('Error! :-( '+r.responseText + ')');  },
	success: function(r) {
	    $('#login_button_html_div').html(r.html);
	}
    });
});

function show_working_dialog() {
    $('#working_modal').modal("show");
}

function hide_working_dialog() {
    $('#working_modal').modal("hide");
}

function error_message(message) {
    $('#error_message_modal').modal("show");
    $('#error_message').html(message);
}
