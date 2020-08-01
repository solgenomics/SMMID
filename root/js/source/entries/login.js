
jQuery('#login_form').submit( function(event) { 
    event.preventDefault();
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
                location.reload();
            }
        }
    });
});


jQuery(document).on('click', 'button[name="site_login_button"]', function(event) { 
    jQuery('#site_login_dialog').modal("show");
});

