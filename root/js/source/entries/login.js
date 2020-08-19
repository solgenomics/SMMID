
$(document).on('submit', 'form[name="login_form"]', function(event) { 
    event.preventDefault();
    login_user();
});

$(document).on('click', 'button[name="submit_password"]', function(event) {
    event.preventDefault();
    login_user();
});

$(document).on('click', 'button[name="site_login_button"]', function(event) {
    login_dialog();
});


function login_dialog() {
    $('#site_login_dialog').modal("show");
}


function login_user() {
    var form_data = jQuery('#login_form').serialize();
    if (!jQuery('#username').val() || !jQuery('#password').val()) { 
        alert('Please enter a username and password.');
        return;
    }

    $.ajax( { 
        url: '/rest/user/login',
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
		//alert("Login successful!");
                location.reload();
            }
        }
    });
}


function logout() {

    var yes = confirm("Really log out?");
    if (! yes) { return; }
    
    document.cookie='smmid_session_id=;  expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    $.ajax( {
	url: '/rest/user/logout',
	error: function(r) { alert('An error occurred logging out'); },
	success: function(r) {
	    if (r.error) {
		alert(r.error);
	    }
	    else {
		//alert(r.message);
		location.reload();
	    }
	}
    });

}

function has_login() {
    return  new Promise((resolve, reject) => {
	$.ajax( {
	    url: '/rest/user/has_login',
	    error: function(r) { reject('An error has occurred '+r.responseText)},
	    success: function(r) {
		if (r.error) { reject(r.responseText); }
		else {
		    resolve(r);
		}
	    }
	});
    })
}
		
		
	    
