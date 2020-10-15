

function curator_html() {

  // $.ajax( {
  //   url: 'rest/curator/datatable',
  //   error: function(r) { alert('An error occurred.'+r.responseText); },
  // 	success: function(r) {
  // 	    if (r.error) {
  // 		alert('Error ('+r.error+')');
  // 	    }
  // 	    else {

  		//$('#browse_c_smid_data_div').html(r.html);

      $('#browse_c_smid_data_div').DataTable({
        'ajax': 'rest/curator/datatable',
        'paging': true,
        'lengthMenu': [[10, 25, 50, 100, -1],[10, 25, 50, 100, "All"]],
        'searching': true,
        'info': true,
        //data: r.data,
        columns: [
          {title: "Compound ID"},
          {title: "SMID ID"},
          {title: "Formula"},
          {title: "SMILES"},
          {title: "  "},
          {title: "  "},
          {title: "Status"}
        ]
      });
        //   }
  	    // }
  	}

  function curate_smid(compound_id){
    $('#curate_'+compound_id).prop('disabled', true);
    $('#unverify_'+compound_id).prop('disabled', false);
    $.ajax({
      url: 'rest/smid/'+compound_id+'/curate_smid',
      data: {
  	    'curation_status' : "curated",
      },
      success: function(r){
        if (r.error) {alert(r.error);}
        else{
          $('#browse_c_smid_data_div').DataTable().ajax.reload();
        }
      }
    });
    //$('#browse_c_smid_data_div').DataTable().ajax.reload();
    //$(document).reload();
  }

  function mark_smid_unverified(compound_id){
    $('#curate_'+compound_id).prop('disabled', false);
    $('#unverify_'+compound_id).prop('disabled', true);
    $.ajax({
      url: 'rest/smid/'+compound_id+'/curate_smid',
      data: {
  	    'curation_status' : "unverified"
      },
      success: function(r){
        if (r.error){alert(r.error);}
        else {
        $('#browse_c_smid_data_div').DataTable().ajax.reload();
      }
    }
    });
    //$('#browse_c_smid_data_div').DataTable().ajax.reload();
    //$(document).reload();
  }
