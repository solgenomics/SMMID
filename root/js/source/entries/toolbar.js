

$(document).ready( function() {
    $.ajax( {	
	url: '/rest/user/login_button_html',
	error: function(r) { alert('Error! :-( '+r.responseText + ')');  },
	success: function(r) {
	    $('#login_button_html_div').html(r.html);
	}
    });
});
