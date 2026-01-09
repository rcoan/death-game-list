import Chart from "chart.js/auto"

document.addEventListener("DOMContentLoaded", function() {
  // Top Players Chart
  const topPlayersCanvas = document.getElementById('topPlayersChart')
  if (topPlayersCanvas) {
    const ctx = topPlayersCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.topPlayersData,
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Top 10 Jogadores'
          }
        },
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    })
  }

  // Deaths Timeline Chart
  const deathsTimelineCanvas = document.getElementById('deathsTimelineChart')
  if (deathsTimelineCanvas) {
    const ctx = deathsTimelineCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'line',
      data: window.deathsTimelineData,
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Mortes ao Longo do Tempo'
          }
        },
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    })
  }
})

