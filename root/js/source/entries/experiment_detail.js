
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
    //display_msms_visual(experiment_id);
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

function display_msms_visual(experiment_id){
  //Collect and format data
  //Note for learning: ajax requests are asynchronous, so attempting to treat the event as a one-time sequential operation
  //will not work. If you wish for some code to execute upon successfully gathering data from a foreign url, place
  //that code in the success parameter of the ajax request.
  $.ajax({
    url: "/rest/experiment/"+experiment_id+"/msms_spectrum",
    success: function(r){
      var data = r.data;
      console.log(data);

      var xdata = [];
      var ydata = [];
      var i;
      var prev = +data[0][0];
      for(i = 0; i < data.length; i++){
        if(data[i][0] - prev > 1 && i != 0){
          xdata.push((+data[i-1][0])+0.00001);
          xdata.push((+data[i][0])-0.00001);
          ydata.push(0);
          ydata.push(0);
        }
        xdata.push(+data[i][0]);
        ydata.push(+data[i][1]);
        prev = +data[i][0];
      }
      console.log(xdata);
      console.log(ydata);


      //Set up drawing area
      var margin = {top: 50, bottom: 50, left: 100, right: 100};
      var width = document.querySelector('#msms_svg').offsetWidth;
      var height = document.querySelector('#msms_svg').offsetHeight;

      var svg = d3.select('#msms_svg').append("svg");

      svg.attr('width', width);
      svg.attr('height', height);

      //Draw axes
      var xscale = d3.scaleLinear()
      .domain([d3.min(xdata), d3.max(xdata)])
      .range([margin.left, width]);
      var xaxis = d3.axisBottom().scale(xscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(0)+","+(height-margin.bottom+2)+")").call(xaxis.ticks(10)).attr("stroke-width","2");
      //
      var yscale = d3.scaleLinear()
      .domain([d3.min(ydata), d3.max(ydata)])
      .range([height-margin.bottom, margin.top]);
      var yaxis = d3.axisLeft().scale(yscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(margin.left - 2)+","+(0)+")").call(yaxis.ticks(10)).attr("stroke-width","2");

      //Create string representing the path the chart should take. This needs to be done because there are gaps in the data over the domain.
      var pathString = ["M"+xscale(d3.min(xdata))+","+(yscale(0))];
      for (i = 0; i < data.length; i++){
          pathString.push("L"+(xscale(xdata[i]))+","+(yscale(ydata[i])));
      }

      pathString = pathString.join(" ");

      console.log(pathString);

      svg.append("path").attr("fill", "none").attr("stroke", "blue").attr("stroke-width", "1").attr("d", pathString);
    }
  });
}
