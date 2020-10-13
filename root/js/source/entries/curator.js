

function curator_html() {

  $.ajax( {
    url: 'rest/curator/datatable',
    error: function(r) { alert('An error occurred.'+r.responseText); },
  	success: function(r) {
  	    if (r.error) {
  		alert('Error ('+r.error+')');
  	    }
  	    else {

  		//$('#browse_c_smid_data_div').html(r.html);

      $('#browse_c_smid_data_div').DataTable({
        'paging': true,
        'lengthMenu': [[10, 25, 50, 100, -1],[10, 25, 50, 100, "All"]],
        'searching': true,
        'info': true,
        data: r.data,
        columns: [
          {title: "Compound ID"},
          {title: "SMID ID"},
          {title: "Formula"},
          {title: "SMILES"},
          {title: "Action"}
        ]
      });
          }
  	    }
  	})
  }

  function is_curator() {

  }

  function curate_smid(compound_id){
    return $.ajax({
      url: 'rest/smid/'+compound_id+'/curate_smid',
      data: {
        'smid_id' : $('#smid_id').val(),
  	    'smiles_string' : $('#smiles_string').val(),
  	    'formula': $('#formula').val(),
  	    'curation_status' : true,
  	    'iupac_name' : $('#iupac_name').val(),
  	    'organisms': $('#organisms').val(),
  	    'description': $('#description').val(),
  	    'synonyms': $('#synonyms').val(),
      }
    });
  }
