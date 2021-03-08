
function make_fields_editable(compound_id) {

    has_login().then( function(r) {
	if (r.user !==null) {
	    $('#smid_id').prop('disabled', false);
	    $('#smiles_string').prop('disabled', false);
	    $('#curation_status').prop("value", "review");
	    $('#request_review_button').prop('visible', false);
	    $('#formula_input_div').show();
	    $('#formula_static_div').hide();
	    $('#formula').prop('disabled', false);
	    $('#doi').prop('disabled', false);
	    $('#organisms').prop('disabled', false);
	    $('#organisms_static_div').hide();
	    $('#organisms_input_div').css('visibility', 'visible');
	    $('#iupac_name_static_div').hide();
	    $('#iupac_name_input_div').show();
	    $('#iupac_name').prop('disabled', false);
	    //$('#add_dbxref_button').prop('disabled', false);
	    $('#description').prop('disabled', false);
	    $('#description_input_div').show();
	    $('#description_static_div').hide();
	    $('#synonyms').prop('disabled', false);

	    if (compound_id) { embed_compound_images(compound_id, 'medium', 'smid_structure_images'); }

	    $('#add_new_smid_button').prop('disabled', false);

	    $('#add_new_smid_button').click(  function(event) {
		event.preventDefault();
		event.stopImmediatePropagation();
		store_smid().then( function(r) {
		    if (r.error) {
			alert(r.error)
		    }
		    else {
			alert(r.message);
			location.href="/smid/"+r.compound_id;
		    }
		}, function(e) { alert('An error occurred. '+e.responseText) });
	    });

	    //$('#add_hplc_ms_button').prop('disabled', false);


	    $('#update_smid_button').click( function(event) {
		event.preventDefault();
		event.stopImmediatePropagation();
		update_smid().then( function(r) {
		    if (r.error) {
			alert(r.error);
		    }
		    else {
			alert(r.message);
			location.href="/smid/"+r.compound_id;
		    }}, function(e) { alert('An error occurred.' + e.responseText) });
	    });

	    $('#smid_structure_upload_div').attr("visible", "true");

	    $('#input_image_file_upload').fileupload( {
		url : '/rest/image/upload'
	    });

	    $('#delete_smid_button').click( function(event) {
		event.preventDefault();
		var yes = confirm("Are you sure you want to delete this entry? It will be permanently removed from the database.");
		if (yes) {

		    confirm("Please confirm that you want to delete this SMID.");
		    if (yes) {
			var compound_id = $('#compound_id').html();
			//alert('Compound ID to delete: '+compound_id);

			$.ajax( {
			    url : '/rest/smid/'+compound_id+'/delete',
			    error: function(e) { alert('Error... '+e.responseText); },
			    success: function(r) {
				if (r.error) { alert(r.error); }
				else {
				    alert('The smid has been deleted. RIP.');
				    location.href="/smid/"+r.compound_id;
				}
			    }
			});
		    }
		}

	    });
	}
	else {
	    login_dialog();
	}
    })
	.catch( function(error) { alert('An error occurred, sorry. ('+error+')'); });
}

function edit_dbxref_info() {

    $('#add_dbxref_dialog').modal("show");
    db_html_select().then( function(r) {
	if (r.html) {
	    $('#db_id_select_div').html(r.html);
	}
    }, function(e) { alert(e.responseText); });

    $('#save_dbxref_button').click(
	function(event) {
	    event.preventDefault();
	    event.stopImmediatePropagation();
	    store_dbxref();
	});
}

function edit_hplc_ms_data() {
    $('#add_hplc_ms_dialog').modal("show");

    $('#save_hplc_ms_button').click(function(event) {
	event.preventDefault();
	event.stopImmediatePropagation();
	store_hplc_ms_data().then(
	    function(r) {
		if (r.error) { alert(r.error); }
		else {
		    alert("Successfully stored HPLC MS data.");
		    $('#add_hplc_ms_dialog').modal("hide");
		    $('#smid_hplc_ms_table').DataTable().ajax.reload();
		}
	    },
	    function(e) { alert("Error! "+e.responseText); }
	);
    });
}

function edit_ms_spectrum() {
    $('#add_ms_spectrum_dialog').modal("show");

    $('#save_ms_spectrum_button').click(function(event) {
	event.preventDefault();
	event.stopImmediatePropagation();

	store_ms_spectrum_data().then(
	    function(r) {
		if (r.error) {
		    alert(r.error);
		}
		else {
		    alert("Successfully stored MS spectrum data.");
		    $('#add_ms_spectrum_dialog').modal("hide");
		    $('#smid_ms_spectra_table').DataTable().ajax.reload();
		}
	    },
	    function(e) { alert("Error! "+e.responseText); }
	);
    });

}


function store_smid() {

    return $.ajax( {
	url: '/rest/smid/store',
	data: {
	    'smid_id': $('#smid_id').val(),
	    'smiles_string' : $('#smiles_string').val(),
	    'iupac_name' : $('#iupac_name').val(),
	    'formula': $('#formula').val(),
	    'doi': $('#doi').val(),
	    'organisms': $('#organisms').val(),
	    'curation_status' : "unverified",
	    'description': $('#description').val(),
	    'synonyms': $('#synonyms').val()
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
	    'iupac_name' : $('#iupac_name').val(),
	    'doi': $('#doi').val(),
	    'organisms': $('#organisms').val(),
	    'description': $('#description').val(),
	    'synonyms': $('#synonyms').val(),
	    //'input_image_file_upload' : $('input_image_file_upload').val(),

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

    $.ajax( {
	url: '/rest/store/dbxref',
	data: {
	    'compound_id' : $('#compound_id').html(),
	    'db_id' : $('#db_id_select').val(),
	    'dbxref_accession': $('#dbxref_accession').val(),
	    'dbxref_description': $('#dbxref_description').val()
	},
	success : function(r) {
	    if (r.error) { alert(r.error) }
	    else {
		alert("Stored Dbxref successfully!");
	    }

	    $('#add_dbxref_dialog').modal("hide");
	    $('#smid_dbxref_data_table').DataTable().ajax.reload();
	},
	error: function(e) { alert('Error. '+e.responseText); }
    });
}

function delete_dbxref(dbxref_id) {

    var yes = confirm("Are you sure you want to delete the dbxref with id "+dbxref_id+"?");
    if (yes) {

	$.ajax( {
	    url : '/rest/dbxref/delete',
	    data: {
		'dbxref_id' : dbxref_id,
	    },
	    error : function(e) { alert("An error occurred!"+e.responseText); },
	    success: function(r) {
		if (r.error) {
		    alert(r.error)
		}
		else {
		    alert(r.message)
		    $('#smid_dbxref_data_table').DataTable().ajax.reload();
		}
	    }

	});
    }
}

function delete_experiment(experiment_id) {
    var yes = confirm("Are you sure you want to delete the experiment with id "+experiment_id+"?");
    if (yes) {
	$.ajax( {
	    url : '/rest/experiment/'+experiment_id+'/delete',
	    error: function (e) { alert("An error occurred: "+e.responseText); },
	    success: function(r) {
		if (r.error) {
		    alert(r.error);
		}
		else {
		    if (r.experiment_type === "hplc_ms") {
			$('#smid_hplc_ms_table').DataTable().ajax.reload();
		    }
		    else {
			$('#smid_ms_spectra_table').DataTable().ajax.reload();
		    }
		}
	    }
	});
    }
}


function delete_image(image_id, compound_id) {
    var yes = confirm("Are you sure you want to delete the image with id "+image_id+"?");
    if (yes) {
	$.ajax( {
	    url : '/rest/image/'+image_id+'/delete',
	    success: function(r) {
		if (r.error) {
		    alert('Error: '+r.error);
		}
		else {
		    embed_compound_images(compound_id, 'medium', 'smid_structure_images');
		    alert("Image deleted.");
		}
	    },
	    error : function(r) { alert("an error occurred"); }
	});
    }
}

function embed_compound_images(compound_id, image_size, div_name) {

    $.ajax( {
	url : '/rest/smid/'+compound_id+'/images/'+image_size,
	error: function(e) { alert('Image retrieve protocol error.'+e.responseText); },
	success: function(r) {
            if (r.error) { alert('Image retrieve error. '+r.error); }
            else {
		$('#'+div_name).html(r.html);
            }
	}
    });
}


function store_hplc_ms_data() {

    var hplc_ms_retention_time = $('#hplc_ms_retention_time').val();

    if (isNaN(hplc_ms_retention_time)) {
	alert("HPLC MS retention time must be numeric.");
	return;
    }

    var hplc_ms_scan_number = $('#hplc_ms_scan_number').val();

    if (isNaN(hplc_ms_scan_number)) {
	alert("HPLC MS scan number must be numeric.");
	return;
    }

    return $.ajax( {
	url: '/rest/experiment/store',
	data: {
	    'compound_id' : $('#compound_id').html(),
	    'experiment_type': 'hplc_ms',
	    'hplc_ms_author' : $('#hplc_ms_author').val(),
	    'hplc_ms_description': $('#hplc_ms_description').val(),
	    'hplc_ms_method_type': $('#hplc_ms_method_type').val(),
	    'hplc_ms_retention_time' : $('#hplc_ms_retention_time').val(),
	    'hplc_ms_ionization_mode' : $('#hplc_ms_ionization_mode').val(),
	    'hplc_ms_adducts_detected' : $('#hplc_ms_adducts_detected').val(),
	    'hplc_ms_scan_number' : $('#hplc_ms_scan_number').val(),
	    'hplc_ms_link' : $('#hplc_ms_link').val()

	}
    });
}

function store_ms_spectrum_data() {

    var collision_energy = $('#ms_spectrum_collision_energy').val();

    if (isNaN(collision_energy)) {
	alert("Collision energy must be numeric.");
	return;
    }

    let re = /^[0-9., ]*$/;

    var matches = collision_energy.match(re);

    //alert(JSON.stringify(matches));
    if (matches === null) {
	alert("Collision energies must be numeric, separated by commas.");
	return;
    }

    return $.ajax( {
	url: '/rest/experiment/store',
	data: {
	    'compound_id' : $('#compound_id').html(),
	    'experiment_type' : 'ms_spectrum',
	    'ms_spectrum_author' : $('#ms_spectrum_author').val(),
	    'ms_spectrum_description' : $('#ms_spectrum_description').val(),
	    'ms_spectrum_ionization_mode' : $('#ms_spectrum_ionization_mode').val(),
	    'ms_spectrum_adduct_fragmented' : $('#ms_spectrum_adduct_fragmented').val(),
	    'ms_spectrum_collision_energy' : $('#ms_spectrum_collision_energy').val(),
	    'ms_spectrum_mz_intensity' : $('#ms_spectrum_mz_intensity').val(),
	    'ms_spectrum_link' : $('#ms_spectrum_link').val()
	}
    });
}



function populate_smid_data(compound_id) {
    $.ajax( {
	url: '/rest/smid/'+compound_id+'/details',
	error: function(r) { alert("An error occurred. "+r.responseText); },
	success: function(r) {
	    if (r.error) {
		alert(r.error);
		location.href='/browse/';
		return;
	    }
	    else {
		$('#smid_id').val(r.data.smid_id);
		$('#smiles_string').val(r.data.smiles_string);

		$('#organisms_static_div').css('visibility', 'visible');
		$('#organisms_static_div').html(r.data.organisms);
		$('#organisms').val(r.data.organisms);
		$('#organisms_input_div').css('visibility', 'hidden');


		has_login().then( function(p){
		    if(p.user !== null && p.role == "curator"){
			$('#curation_status_manipulate').prop('value', r.data.curation_status);
		    } else {
			$('#curation_status_manipulate').prop('style', "display: none;");
      $('#change_curation_status').prop('style', "display: none;")
		    }


		    if (p.user !== null && (p.user == r.data.dbuser_id || p.role == "curator")) {
			$('#public_status_manipulate').prop('value', r.data.public_status);
		    } else {
			$('#change_public_status').prop('style', "display: none;");
			$('#public_status_manipulate').prop('style', "display: none;");
		    }

		    $('#add_hplc_ms_button').click( function(event) {
			event.preventDefault();
			event.stopImmediatePropagation();
			edit_hplc_ms_data();
		    });

		    // $('#add_ms_spectrum_button').prop('disabled', false);

		    $('#add_ms_spectrum_button').click( function(event) {
			event.preventDefault();
			event.stopImmediatePropagation();
			edit_ms_spectrum();
		    });

		    $('#delete_smid_button').click( function(event) {
			event.preventDefault();
			var yes = confirm("Are you sure you want to delete this entry? It will be permanently removed from the database.");
			if (yes) {

			    confirm("Please confirm that you want to delete this SMID.");
			    if (yes) {
				var compound_id = $('#compound_id').html();
				//alert('Compound ID to delete: '+compound_id);

				$.ajax( {
				    url : '/rest/smid/'+compound_id+'/delete',
				    error: function(e) { alert('Error... '+e.responseText); },
				    success: function(r) {
					if (r.error) { alert(r.error); }
					else {
					    alert('The smid has been deleted. RIP.');
					    location.href="/smid/"+r.compound_id;
					}
				    }
				});
			    }
			}

		    });

		    $('#add_dbxref_button').click(
			function(event) {
			    event.preventDefault();
			    event.stopImmediatePropagation();
			    edit_dbxref_info();

			});




		});



		var curation_status_html = "";
		if(r.data.curation_status == "curated"){
		    curation_status_html = "Verified Entry";
		    $('#curation_status').prop('style',"color:green; font-size:1.5em");
		}
		if(r.data.curation_status == null || r.data.curation_status == "" || r.data.curation_status == "unverified"){
		    curation_status_html = "Unverified Entry";
		    $('#curation_status').prop('style',"color:red; font-size:1.5em");
		}
		if(r.data.curation_status == "review"){
		    curation_status_html = "Marked for Review";
		    $('#curation_status').prop('style',"color:blue; font-size:1.5em");
		}

		$('#curation_status').html(curation_status_html);

		$('#doi').val(r.data.doi);

		if(r.data.curation_status == "" || r.data.curation_status == "unverified" || r.data.curation_status == "review"){
		    $('#request_review_button').prop('style', "display:none");
		} else {$('#request_review_button').prop('disabled', false);}

		$('#formula_static_div').css('visibility', 'visible');
		var formula = r.data.formula;
		var formula_subscripts = formula.replace(/(\d+)/g, '\<sub\>$1\<\/sub\>');
		$('#formula_static_div').html(formula_subscripts + '&nbsp;&nbsp;&nbsp;['+r.data.molecular_weight+' g/mol]');

		$('#formula_input_div').hide();
		$('#formula').val(r.data.formula);

		$('#iupac_name_static_div').show();
		$('#iupac_name_static_div').html(r.data.iupac_name);
		$('#iupac_name').val(r.data.iupac_name);
		$('#iupac_name_input_div').hide();

		$('#smid_title').html(r.data.smid_id);

		$('#description_static_div').show();
		$('#description_static_content_div').html(r.data.description);
		$('#description_input_div').hide();
		$('#description').html(r.data.description);

		$('#synonyms').val(r.data.synonyms);
		$('#modification_history').html('<font size="2">Created: '+r.data.create_date+' Last modified: '+r.data.last_modified_date+'</font>');
		$('#author').html(r.data.author);
	    }
	}
    });

    $('#smid_dbxref_data_table').DataTable( {
	searching: false,
	paging: false,
	info: false,
	"ajax": {
	    url: '/rest/smid/'+compound_id+'/dbxrefs'
	}

    } );

    $('#smid_hplc_ms_table').DataTable( {
	searching: false,
	paging: false,
	info: false,
	"ajax": {
	    url: '/rest/smid/'+compound_id+'/results?experiment_type=hplc_ms'
	}
    });

    $('#smid_ms_spectra_table').DataTable( {
	searching: false,
	paging: false,
	info: false,
	"ajax": {
	    url: '/rest/smid/'+compound_id+'/results?experiment_type=ms_spectrum'
	}
    });

     $('#edit_smid_button').click(
	 function(event) {
	     event.preventDefault();
	     event.stopImmediatePropagation();

	     window.location.href = "/smid/"+compound_id+"/edit";

	 });
    $('#cancel_edit').click(
	function(event) {
	     event.preventDefault();
	     event.stopImmediatePropagation();

	     window.location.href = "/smid/"+compound_id;
	});

}


function mark_smid_for_review(compound_id){
  $.ajax({
    url: '/rest/smid/'+compound_id+'/mark_for_review',
    data: {
      'curation_status' : "review"
    },
    success: function(r){
      if (r.error){alert(r.error);}
      else {
        alert(r.message);
        $('#curation_status').html("Marked for Review");
        $('#curation_status').prop('style',"color:blue; font-size:1.5em");
      }
    }
  });
}

function mark_smid_unverified(compound_id){
  $.ajax({
    url: '/rest/smid/'+compound_id+'/mark_unverified',
    data: {
      'curation_status' : "unverified"
    },
    success: function(r){
      if (r.error){alert(r.error);}
      else {
        alert(r.message);
        $('#curation_status').html("Unverified Entry");
        $('#curation_status').prop('style',"color:red; font-size:1.5em");
      }
    }
  });
}

function curate_smid(compound_id){
  $.ajax({
    url: '/rest/smid/'+compound_id+'/curate_smid',
    data: {
      'curation_status' : "curated"
    },
    success: function(r){
      if (r.error){alert(r.error);}
      else {
        alert(r.message);
        $('#curation_status').html("Verified Entry");
        $('#curation_status').prop('style',"color:green; font-size:1.5em");
      }
    }
  });
}

function change_curation_status(compound_id, new_status){
  if (new_status == "curated"){curate_smid(compound_id);}
  else if (new_status == "unverified"){mark_smid_unverified(compound_id);}
  else if (new_status == "review"){mark_smid_for_review(compound_id);}
}

function display_msms_visual_smid(experiment_id){

  d3.select("svg").remove();
  $('#msms_spectrum_visualizer').modal("show");

  display_msms_visual(experiment_id);
}

function change_public_status(compound_id, new_status){
  $.ajax({
    url: '/rest/smid/'+compound_id+'/change_public_status',
    data: {
      'public_status' : new_status
    },
    success: function(r){
      if(r.error) {alert(r.error);}
      else{
        alert(r.message);
      }
    },
    error: function(r){
      alert("An error occurred."+r.responseText);
    }
  })
}
