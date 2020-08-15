

$(document).ready( function() {
    $.ajax( {	
	url: '/ajax/user/login_button_html',
	error: function(r) { alert('Error! :-( '+r.responseText + ')');  },
	success: function(r) {
	    alert("HTML IS HERE "+r.html);
	    $('#login_button_html_div').html(r.html);
	}
    });
});
