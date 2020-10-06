
function browse_html() {

    $.ajax( {
	url: '/rest/browse/datatable',
	error: function(r) { alert('An error occurred.'+r.responseText); },
	success: function(r) {
	    if (r.error) {
		alert('Error ('+r.error+')');
	    }
	    else {
		//$('#browse_smid_data_div').html(r.html);

    $('#browse_smid_data_div').DataTable({
      'paging': false,
      //'lengthMenu': [[10, 25, 50, 100, -1],[10, 25, 50, 100, "All"]],
      'searching': true,
      'info': true,
      data: r.data,
      columns:
      [
        {title: "Compound ID"},
        {title: "SMID ID"},
        {title: "Formula"},
        {title: "Molecular Weight"},
        {title: "Curation Status"}
      ]
    });
	    }
	}
    });

}
