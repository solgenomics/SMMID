

jQuery(document).ready( function() {
    alert("FETCHING LOGIN HTML...");
    $.ajax( {	
	url: '/ajax/user/login_button_html',
	error: function(r) { alert('Error! :-( '+r.responseText()) },
	success: function(r) {
	    $('#login_button_html').html(r.html);
	}
    });
});
