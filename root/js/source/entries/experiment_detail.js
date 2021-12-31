
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

function get_compound_id(experiment_id){
  return $.ajax({
    url:"/rest/experiment/"+experiment_id+"/get_compound_id_from_experiment",
    // success: function(r){
    //   //alert(JSON.stringify(r.data));
    //   data = r.data;
    // }
  });
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

      //Format data to ensure that there are no gaps between peaks
      var xdata = [];
      var ydata = [];
      var tooltipData = [];
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
        //tooltipData.push({ x: +rawdata[i][0], y:+rawdata[i][1]});
        prev = +rawdata[i][0];
      }
      for(i = 0; i < xdata.length; i++){
        tooltipData.push({ x: +xdata[i], y: +ydata[i]});
      }

      console.log(tooltipData);

      //Set up drawing area
      var margin = {top: 100, bottom: 100, left: 100, right: 100};
      var width = document.querySelector('#msms_svg_container').offsetWidth*0.90;
      var height = document.querySelector('#msms_svg_container').offsetHeight*0.90;

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

      ////
      var yscale = d3.scaleLinear()
      .domain([0, d3.max(ydata) + 0.1*(d3.max(ydata) - d3.min(ydata))])
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
      var path = svg.append("path").attr("fill", "none").attr("stroke", "blue").attr("stroke-width", "1.5").attr("d", pathString);

      ////Add mouseover effect

      //Event handlers on window for mouse position and scrolling/resizing events
      var mouse_x = 0;
      var mouse_y = 0;
      var box = document.getElementById("svg").getBoundingClientRect();
      var tooltipIndex = 0;

      window.addEventListener('mousemove', function(e){
        mouse_x = e.x;
        mouse_y = e.y;
        tooltipIndex = find_closest(mouse_x - box.x, mouse_y - box.y);
      });

      //Find the index of the closest data value to the mouse
      function find_closest(x, y){
        var ref = 0;
        var val = 100000;
        var placeholder = 0;

        for (var i = 0; i != tooltipData.length; i++){
          placeholder = Math.abs(revxscale(x) - tooltipData[i].x);
          if (placeholder < val){
            ref = i;
            val = placeholder;
          }
        }
        var h = ref;
        for (var j = h-3; j<h+3; j++){
          if (j > 0 && j < tooltipData.length && tooltipData[j].y > tooltipData[ref].y){
            ref = j;
          }
        }
        var increasingLeft = false;
        var increasingRight = false;
        var h = ref;

        if (ref > 0 && ref < tooltipData.length - 1){
          if (tooltipData[ref-1].y > tooltipData[ref].y){
            while(ref > 0){
              if (tooltipData[ref-1].y < tooltipData[ref].y){
                return ref;
              } else {ref--;}
            }
          }
          else if (tooltipData[ref+1].y > tooltipData[ref].y){
            while(ref < tooltipData.length- 1){
              if (tooltipData[ref+1].y > tooltipData[ref].y){
                return ref;
              } else {ref++;}
            }
          }
          else return ref;
        }

        return ref;
      }

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
      })
      .on('mouseout', function(){
        tooltip.style("opacity", 0);
        tooltip_text.style("opacity", 0);
        crosshair_x.style("opacity", 0);
        crosshair_y.style("opacity", 0);
      })
      .on('mousemove', function(){
        tooltip_text.text("m/z: " +tooltipData[tooltipIndex].x.toFixed(4) + ", " + "Intensity: " + (tooltipData[tooltipIndex].y.toFixed(0)));
        crosshair_x.attr("d", "M"+margin.left+","+(yscale(tooltipData[tooltipIndex].y))+" L"+xscale(width-margin.right)+","+(yscale(tooltipData[tooltipIndex].y)));
        crosshair_y.attr("d", "M"+(xscale(tooltipData[tooltipIndex].x))+","+(height-margin.bottom)+"L"+(xscale(tooltipData[tooltipIndex].x))+","+(margin.top));
      });

    }
  });
}
