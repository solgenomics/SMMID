
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
	    $('#add_dbxref_button').prop('disabled', false);
	    $('#description').prop('disabled', false);
	    $('#description_input_div').show();
	    $('#description_static_div').hide();
	    $('#synonyms').prop('disabled', false);
	    $('#add_dbxref_button').click(
		function(event) {
		    event.preventDefault();
		    event.stopImmediatePropagation();
		    edit_dbxref_info();

		});

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

	    $('#add_hplc_ms_button').prop('disabled', false);

	    $('#add_hplc_ms_button').click( function(event) {
		event.preventDefault();
		event.stopImmediatePropagation();
		edit_hplc_ms_data();
	    });

	    $('#add_ms_spectrum_button').prop('disabled', false);

	    $('#add_ms_spectrum_button').click( function(event) {
		event.preventDefault();
		event.stopImmediatePropagation();
		edit_ms_spectrum();
	    });

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
		    var compound_id = $('#compound_id').html();
		    alert('Compound ID to delete: '+compound_id);

		    $.ajax( {
			url : '/rest/smid/'+compound_id+'/delete',
			error: function(e) { alert('Error... '+e.responseText); },
			success: function(r) { alert('The smid has been deleted. RIP.'); }
		    });
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
    let re = /^[0-9., ]*$/;

    var matches = collision_energy.match(re);

    alert(JSON.stringify(matches));
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

		$('#organisms_static_div').css('visibility', 'visible');
		$('#organisms_static_div').html(r.data.organisms);
		$('#organisms').val(r.data.organisms);
		$('#organisms_input_div').css('visibility', 'hidden');


    has_login().then( function(p){
      if(p.user !== null && p.role == "curator"){
        $('#curation_status_manipulate').prop('value', r.data.curation_status);
      } else {$('#curation_status_manipulate').prop('style', "display: none;");}
    })

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
		$('#formula_static_div').html(r.data.formula + '&nbsp;&nbsp;&nbsp;['+r.data.molecular_weight+' g/mol]');

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

function display_msms_visual(experiment_id){

  $('#msms_spectrum_visualizer').modal("show");
  d3.select("svg").remove();

  //Collect and format data
  //Note for learning: ajax requests are asynchronous, so attempting to treat the event as a one-time sequential operation
  //will not work. If you wish for some code to execute upon successfully gathering data from a foreign url, place
  //that code in the success parameter of the ajax request.
  $.ajax({
    url: "/rest/experiment/"+experiment_id+"/msms_spectrum",
    success: function(r){
      var rawdata = r.data;
      console.log(rawdata);

      //Format data to ensure that there are no gaps between peaks
      var xdata = [];
      var ydata = [];
      var i;
      var prev = +rawdata[0][0];
      for(i = 0; i < rawdata.length; i++){
        if(rawdata[i][0] - prev > 1 && i != 0){
          xdata.push((+rawdata[i-1][0])+0.00001);
          xdata.push((+rawdata[i][0])-0.00001);
          ydata.push(0);
          ydata.push(0);
        }
        xdata.push(+rawdata[i][0]);
        ydata.push(+rawdata[i][1]);
        prev = +rawdata[i][0];
      }

      //Set up drawing area
      var margin = {top: 100, bottom: 100, left: 100, right: 100};
      var width = document.querySelector('#msms_spectrum_modal').offsetWidth*0.90;
      var height = document.querySelector('#msms_spectrum_modal').offsetHeight*0.90;

      var svg = d3.select('#msms_svg').append("svg").attr("id", "svg");

      svg.attr('width', width).attr('height', height);

      //Draw axes and set scales
      var xscale = d3.scaleLinear()
      .domain([d3.min(xdata), d3.max(xdata) + 10])
      .range([margin.left, width]);
      var xaxis = d3.axisBottom().scale(xscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(0)+","+(height-margin.bottom+2)+")").call(xaxis.ticks(10)).attr("stroke-width","2");

      var revxscale = d3.scaleLinear()
      .domain([margin.left, width])
      .range([d3.min(xdata), d3.max(xdata) + 10]);

      //
      var yscale = d3.scaleLinear()
      .domain([0, d3.max(ydata) + 1000])
      .range([height-margin.bottom, margin.top]);
      var yaxis = d3.axisLeft().scale(yscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(margin.left - 2)+","+(0)+")").call(yaxis.ticks(10)).attr("stroke-width","2");

      var revyscale = d3.scaleLinear()
      .domain([height-margin.bottom, margin.top])
      .range([0, d3.max(ydata) + 1000]);

      //Draw x and y axis labels
      svg.append("text").attr("x", width/2).attr("y", height - (margin.bottom/2)).style("text-anchor", "middle").text("m/z");
      svg.append("text").attr("x", 0).attr("y", height/2).style("text-anchor", "middle").text("Intensity").attr("transform", "rotate(270, 20,"+(height/2)+")");

      //Create string representing the path the chart should take. This needs to be done because there are gaps in the data over the domain.
      var pathString = ["M"+(xscale(xdata[0]))+","+(height-margin.bottom)];
      for (i = 1; i < xdata.length; i++){
          pathString.push("L"+(xscale(xdata[i])+","+(yscale(ydata[i]))));
      }

      pathString = pathString.join("");

      console.log(pathString);

      svg.append("path").attr("fill", "none").attr("stroke", "blue").attr("stroke-width", "1.5").attr("d", pathString);

      //Add mouseover effect
      var mouse_x = 0;
      var mouse_y = 0;
      var box = document.getElementById("svg").getBoundingClientRect();

      window.addEventListener('mousemove', function(e){
        mouse_x = e.x;
        mouse_y = e.y;
      });

      function findOffset(){
        box = document.getElementById("svg").getBoundingClientRect();
      }

      window.onscroll = function(e){findOffset();}
      window.onresize = function(e){findOffset();}

      var g2 = svg.append("g").attr("id", "g2");
      var tooltip = g2.append("rect").attr("class", "tooltip").attr("transform", "translate(100, 0)");
      var tooltip_text = g2.append("text").attr("transform", "translate(100, 20)").style("opacity", 0);
      var crosshair_x = svg.append("path").style("opacity", 0).attr("stroke-dasharray", "10,10").attr("stroke", "red").attr("stroke-width", "1");
      var crosshair_y = svg.append("path").style("opacity", 0).attr("stroke-dasharray", "10,10").attr("stroke", "red").attr("stroke-width", "1");
      svg.on('mouseover', function(){
        tooltip.style("opacity", 0.2);
        tooltip_text.style("opacity", 1);
        crosshair_x.style("opacity", 1);
        crosshair_y.style("opacity", 1);
        console.log("Why is this not working??");
      })
      .on('mouseout', function(){
        tooltip.style("opacity", 0);
        tooltip_text.style("opacity", 0);
        crosshair_x.style("opacity", 0);
        crosshair_y.style("opacity", 0);
      })
      .on('mousemove', function(){
        tooltip_text.text("m/z: " +revxscale(mouse_x - box.x).toFixed(4) + ", " + "Intensity: " + revyscale(mouse_y - box.y).toFixed(0));
        crosshair_x.attr("d", "M"+margin.left+","+(mouse_y - box.y)+" L"+xscale(width-margin.right)+","+(mouse_y - box.y));
        crosshair_y.attr("d", "M"+(mouse_x - box.x)+","+(height-margin.bottom)+"L"+(mouse_x-box.x)+","+(margin.top));
      });

    }
  });
}
