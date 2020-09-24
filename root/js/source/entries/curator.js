function curator_html() {

  $.ajax( {
    url: 'rest/curator/html',
    error: function(r) { alert('An error occurred.'+r.responseText); },
  	success: function(r) {
  	    if (r.error) {
  		alert('Error ('+r.error+')');
  	    }
  	    else {
  		$('#browse_c_smid_data_div').html(r.html);
      //$('#browse_c_smid_data_div').DataTable({
      //   data: r.datatable
      //    })
  	    }
  	}
      });

}
