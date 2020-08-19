
function make_fields_editable() {

    has_login().then( function(r) {
	if (r.user !==null) {
	    alert("Has login!"+r.user);
	    $('#smid_id').prop('disabled', false);
	    $('#smiles_string').prop('disabled', false);
	    $('#curation_status').val('unverified');
	    $('#formula').prop('disabled', false);
	    $('#organisms').prop('disabled', false);
	    $('#add_dbxref_button').prop('disabled', false);
	}
	else {
	    login_dialog();
	}
    })
	.catch( function(error) { alert('An error occurred ??? '+error); });
}

function populate_smid_data(smid_id) { 
    //alert("GETTING DATA...:-) for smid id "+smid_id);
    $.ajax( {
	url: '/rest/compound/'+smid_id+'/details',
	error: function(r) { alert('Error! '+r.responseText); },
	success: function(r) {
	    if (r.error) { alert(r.error); }
	    else {
		//alert(JSON.stringify(r));
		$('#smid_id').val(r.data.smid_id);
		$('#smiles_string').val(r.data.smiles);
		$('#curation_status').val(r.data.curation_status);
		$('#formula').val(r.data.formula);
		alert("here!");
		$('#smid_title').html(r.data.smid_id);
		alert("there!");
	    }
	}
    });

    
    $('#smid_dbxref_data_table').DataTable( {
	"ajax": {
	    url: '/rest/compound/'+smid_id+'/dbxrefs'
	},
     
    } );   
}



