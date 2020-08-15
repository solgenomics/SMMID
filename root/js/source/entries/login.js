




jQuery(document).on('submit', 'form[name="login_form"]', function(event) { 
    event.preventDefault();
    alert("HELLO 444");
    login_user();
});

jQuery(document).on('click', 'button[name="submit_password"]', function(event) {
        event.preventDefault();
    alert('HELLO 333');
    login_user();
});




jQuery(document).on('click', 'button[name="site_login_button"]', function(event) {
    jQuery('#site_login_dialog').modal("show");
});



function login_user() {
    alert("HELLO 5555");
    var form_data = jQuery('#login_form').serialize();
    if (!jQuery('#username').val() || !jQuery('#password').val()) { 
        alert('Please enter a username and password');
        return;
    }

    jQuery.ajax( { 
        url: '/ajax/user/login',
        data: form_data,
        error: function(r) { alert('An error occurred! Sorry!');  },
        success: function(r) {
            if (r.error) { 
                alert(r.error);
                return;
            }
            if (r.goto_url) { 
                location.href=r.goto_url;
            }
            else {
		alert("Login successful!");
                //location.reload();
            }
        }
    });
}


function logout() {
    $.ajax( {
	url: '/ajax/user/logout',
	error: function(r) { alert('An error occurred logging out'); },
	success: function(r) {
	    if (r.error) {
		alert(r.error);
	    }
	    else {
		alert(r.message);
		location.reload();
	    }
	}
    });

}
