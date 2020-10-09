
function retrieve_experiment(experiment_id) {

    return $.ajax( {
	url : '/rest/experiment/'+experiment_id,
    });

}

function display_experiment(experiment_id) {

    retrieve_experiment(experiment_id).then(
	function(r) {
	    
	    if (r.data.experiment_type === 'hplc_ms') {
		display_hplc_experiment(r);
	    }
	    if (r.data.experiment_type === 'ms_spectrum') {
		display_ms_spectrum_experiment(r);
	    }
	},

	function(e) {
	    alert('An error occurred. '+e.responseText);
	}
    );
}

function display_hplc_experiment(r) {
    alert('displaying hplc experiment!');

}

function display_ms_spectrum_experiment(r) {
    
    $('#experiment_type').html(r.data.experiment_type);
    $('#description').html(r.data.description);
    $('#ms_spectrum_link').html(r.data.ms_spectrum_link);
    $('#ms_spectrum_author').html(r.data.ms_spectrum_author);
    $('#ms_spectrum_ionization_mode').html(r.data.ms_spectrum_ionization_mode);
    $('#ms_spectrum_mz_intensity').html(r.data.ms_spectrum_mz_intensity);
    $('#ms_spectrum_adduct_fragmented').html(r.data.ms_spectrum_adduct_fragmented);
}



	


		  
