(function($) {
  'use strict';

  var lineChartData = {
    labels: [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July'
    ],
    datasets: [
      {
        label: 'Profit',
        borderColor: '#f3f3f3',
        backgroundColor: '#f3f3f3',
        fill: true,
        data: [
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor()
        ],
        yAxisID: 'y-axis-1'
      }, {
        label: 'Revenue',
        borderColor: '#F74F22',
        backgroundColor: '#F74F22',
        fill: true,
        data: [
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor(),
          randomScalingFactor()
        ],
        yAxisID: 'y-axis-2'
      }
    ]
  };

  var ctx = document.getElementById('myChart').getContext('2d');
  window.myLine = Chart.Line(ctx, {
    data: lineChartData,
    options: {
      responsive: true,
      hoverMode: 'index',
      stacked: true,
      title: {
        display: false,
      },
      scales: {
        yAxes: [
          {
            type: 'linear', // only linear but allow scale type registration. This allows extensions to exist solely for log scale for instance
            display: true,
            position: 'left',
            id: 'y-axis-1'
          }, {
            type: 'linear', // only linear but allow scale type registration. This allows extensions to exist solely for log scale for instance
            display: true,
            position: 'right',
            id: 'y-axis-2',

            // grid line settings
            gridLines: {
              drawOnChartArea: false, // only want the grid lines for one axis to show up
            }
          }
        ]
      }
    }
  });

})(jQuery);
