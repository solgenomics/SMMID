
function browse_html() {

    $.ajax( {
	url: '/rest/browse/html',
	error: function(r) { alert('An error occurred.'+r.responseText); },
	success: function(r) {
	    if (r.error) {
		alert('Error ('+r.error+')');
	    }
	    else {
		$('#browse_smid_data_div').html(r.html);
	    }
	}
    });

}

