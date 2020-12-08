
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
      var width = document.querySelector('#msms_visual_table').offsetWidth;
      var height = document.querySelector('#msms_visual_table').offsetHeight;

      var svg = d3.select('#msms_svg').append("svg");

      svg.attr('width', width).attr('height', height);

      //Draw axes and set scales
      var xscale = d3.scaleLinear()
      .domain([d3.min(xdata), d3.max(xdata) + 10])
      .range([margin.left, width]);
      var xaxis = d3.axisBottom().scale(xscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(0)+","+(height-margin.bottom+2)+")").call(xaxis.ticks(10)).attr("stroke-width","2");
      ////
      var yscale = d3.scaleLinear()
      .domain([0, d3.max(ydata) + 1000])
      .range([height-margin.bottom, margin.top]);
      var yaxis = d3.axisLeft().scale(yscale);
      svg.append("g").attr("class", "axis").attr("transform", "translate("+(margin.left - 2)+","+(0)+")").call(yaxis.ticks(10)).attr("stroke-width","2");

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
      //var tooltip = svg.append("rect").attr("width", "30px").attr("height", "20px").style("opacity", 0);

    }
  });
}
