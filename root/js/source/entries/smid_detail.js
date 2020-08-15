


function populate_smid_data(smid_id) { 
    alert("GETTING DATA...:-) for smid id "+smid_id);
    $.ajax( {
	url: '/rest/compound/'+smid_id+'/details',
	error: function(r) { alert('Error! '+r.responseText); },
	success: function(r) {
	    if (r.error) { alert(r.error); }
	    else {
		alert(JSON.stringify(r));
		$('#smid_id').val(r.data.smid_id);
		$('#smiles_string').val(r.data.smiles);
		$('#curation_status').val(r.data.curation_status);
		$('#formula').val(r.data.formula);
	    }
	}
    });

    
    $('#smid_dbxref_data_table').DataTable( {
	"ajax": {
	    url: '/rest/compound/'+smid_id+'/dbxrefs'
	},
        "columns": [
            { "data": "database" },
            { "data": "accession" },
            { "data": "link" },
        ]
    } );   
}



