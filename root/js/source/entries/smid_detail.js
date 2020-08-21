
function make_fields_editable() {

    has_login().then( function(r) {
	if (r.user !==null) {
	    $('#smid_id').prop('disabled', false);
	    $('#smiles_string').prop('disabled', false);
	    $('#curation_status').val('unverified');
	    $('#formula').prop('disabled', false);
	    $('#organisms').prop('disabled', false);

	    $('#add_dbxref_button').prop('disabled', false);
	    $('#add_dbxref_button').click(
		function(event) {
		    event.preventDefault();
		    $('#add_dbxref_dialog').modal("show");
		    db_html_select().then( function(r) {
			if (r.html) {
			    $('#db_id_select_div').html(r.html);
			}
		    }, function(e) { alert(e.responseText); });
		    
		    $('#save_dbxref_button').click(
			function(event) {
			    event.preventDefault();
			    store_dbxref().then(function(r) {
				if (r.error) { alert(r.error) }
				else {
				    alert("Stored Dbxref successfully!");
				}
				$('#add_dbxref_dialog').modal("hide");
				$('#smid_dbxref_data_table').DataTable().ajax.reload();
			    } , function(e) { alert("An error occurred "+e.responseText); }) 
		    });
		
	    });
	    
	    $('#add_new_smid_button').prop('disabled', false);
	    $('#add_new_smid_button').click(  function(event) {
		event.preventDefault();
		store_smid().then( function(r) {
		    if (r.error) {
			alert(r.error)
		    }
		    else {
			alert(r.message);
		    }
		    location.href="/smid/"+r.compound_id;
		}, function(e) { alert('An error occurred. '+e.responseText) });			    
	    });
	    $('#update_smid_button').click( function(event) {
		event.preventDefault();
		update_smid().then( function(r) {
		    if (r.error) {
			alert(r.error);
		    }
		    else {
			alert(r.message);
		    }}, function(e) { alert('An error occurred.' + e.responseText) });
	    });


	}
	else {
	    login_dialog();
	}
    })
	.catch( function(error) { alert('An error occurred, sorry. ('+error+')'); });
}

function store_smid() {

    return $.ajax( {
	url: '/rest/smid/store',
	data: {
	    'smid_id': $('#smid_id').val(),
	    'smiles_string' : $('#smiles_string').val(),
	    'formula': $('#formula').val(),
	    'organisms': $('#organisms').val(),
	    'curation_status' : $('#curation_status').val(),
	    'organisms': $('#organisms').val()
	}
    });
}

function update_smid() {

    var compound_id = $('#compound_id').html();
    return $.ajax( {
	url: '/rest/smid/'+compound_id+'/update',
	data: {
	    'smid_id' : $('#smid_id').val(),
	    'smiles_string' : $('#smiles_string').val(),
	    'formula': $('#formula').val(),
	    'curation_status' : $('#curation_status').val(),
	    'organisms': $('#organisms').val()
	}
    });
}



function db_html_select() {

    return $.ajax( {
	'url': '/rest/db/select',
	'data': { div_name : 'db_id_select' }
    });

}


function store_dbxref() {

    return $.ajax( {
	url: '/rest/dbxref/store',
	data: {
	    'compound_id' : $('#compound_id').html(),
	    'db_id' : $('#db_id_select').val(),
	    'accession': $('#accession').val(),
	    'description': $('#description').val()
	}
    });
}
    
function populate_smid_data(compound_id) { 

    $.ajax( {
	url: '/rest/smid/'+compound_id+'/details',
	error: function(r) { alert("An error occurred. "+r.responseText); },
	success: function(r) {
	    if (r.error) { error_message("No smid exists with id "+smid_id); }
	    else {
		$('#smid_id').val(r.data.smid_id);
		$('#smiles_string').val(r.data.smiles_string);
		$('#organisms').val(r.data.organisms);
		$('#curation_status').val(r.data.curation_status);
		$('#formula').val(r.data.formula);
		$('#smid_title').html(r.data.smid_id);
	    }
	}
    });

    
    $('#smid_dbxref_data_table').DataTable( {
	"ajax": {
	    url: '/rest/smid/'+compound_id+'/dbxrefs'
	},
     
    } );   
}


