
$(document).ready(function() {
  createPieChart();
});

function createPieChart() {
  google.charts.load("current", { "packages": ["corechart"] } );
  google.charts.setOnLoadCallback(drawChart);

  function drawChart() {

    var data = google.visualization.arrayToDataTable([
      ["Page", "Amount"],
      ["Menu Types", 1],
      ["Learn More", 1],
      ["How It Works", 1],
      ["Menu Builder", 1]
    ]);

    var backgroundColorHex = getComputedStyle(document.body).getPropertyValue("--main-background-color").replace(/ /g, "");
    var options = {
      title: "",
      legend: "none",
      pieSliceText: "label",
      enableInteractivity: "true",
      tooltip: { trigger: "none" },
      pieSliceTextStyle: {
        color: "white",
        fontSize: 14
      },
      slices: {
        0: {
          color: "#d46b29",
          offset: 0.1
        },
        1: {
          color: "#574185",
          offset: 0.1,
          fontSize: 24
        },
        2: {
          color: "#14a64b",
          offset: 0.1
        },
        3: {
          color: "#cf212a",
          offset: 0.1
        }
      },
      backgroundColor: backgroundColorHex,
      pieSliceBorderColor: "transparent",
      chartArea:{
        width: '90%',
        height: '100%'
      }
    };

    var chart = new google.visualization.PieChart(document.getElementById("piechart"));

    function selectHandler() {
      var selectedItem = chart.getSelection()[0];
      if (selectedItem) {
        var selectedOption = data.getValue(selectedItem.row, 0);
        var pageName = selectedOption.toLowerCase().replace(/ /g, "-");
        var route = `/${pageName}`;
        window.open(route, "_self")
      }
    }

    function resizeChart () {
      chart.draw(data, options);
    }
    if (document.addEventListener) {
      window.addEventListener('resize', resizeChart);
    }
    else if (document.attachEvent) {
      window.attachEvent('onresize', resizeChart);
    }
    else {
      window.resize = resizeChart;
    }

    google.visualization.events.addListener(chart, "select", selectHandler);
    chart.draw(data, options);
  }
}
