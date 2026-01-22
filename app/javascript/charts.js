// Chart.js is loaded via CDN
// The UMD build exposes Chart on window.Chart
let Chart

// Wait for Chart.js to be available
function waitForChart() {
  if (typeof window !== 'undefined' && window.Chart) {
    Chart = window.Chart
    return true
  }
  return false
}

function initializeCharts() {
  // Make sure Chart is available
  if (!waitForChart()) {
    console.error("Chart.js not loaded yet")
    return
  }

  // Top Players Chart
  const topPlayersCanvas = document.getElementById('topPlayersChart')
  if (topPlayersCanvas && window.topPlayersData) {
    const ctx = topPlayersCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.topPlayersData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Top 10 Jogadores',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  // Deaths Timeline Chart (Cumulative)
  const deathsTimelineCanvas = document.getElementById('deathsTimelineChart')
  if (deathsTimelineCanvas && window.deathsTimelineData) {
    const ctx = deathsTimelineCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'line',
      data: window.deathsTimelineData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Mortes Acumuladas ao Longo do Ano',
            font: { size: 16, weight: 'bold' }
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return 'Total acumulado: ' + context.parsed.y + ' mortes'
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 },
            title: {
              display: true,
              text: 'Mortes Acumuladas'
            }
          },
          x: {
            title: {
              display: true,
              text: 'Mês'
            }
          }
        }
      }
    })
  }

  // Points Distribution Chart
  const pointsDistributionCanvas = document.getElementById('pointsDistributionChart')
  if (pointsDistributionCanvas && window.pointsDistributionData) {
    const ctx = pointsDistributionCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'doughnut',
      data: window.pointsDistributionData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Distribuição de Pontuação',
            font: { size: 16, weight: 'bold' }
          },
          legend: {
            position: 'bottom'
          }
        }
      }
    })
  }

  // Deadliest Celebrities Chart
  const deadliestCelebritiesCanvas = document.getElementById('deadliestCelebritiesChart')
  if (deadliestCelebritiesCanvas && window.deadliestCelebritiesData) {
    const ctx = deadliestCelebritiesCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.deadliestCelebritiesData,
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Top 10 Celebridades Mais Mortais',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false }
        },
        scales: {
          x: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  // Points vs Popularity Chart
  const pointsVsPopularityCanvas = document.getElementById('pointsVsPopularityChart')
  if (pointsVsPopularityCanvas && window.pointsVsPopularityData) {
    const ctx = pointsVsPopularityCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'scatter',
      data: window.pointsVsPopularityData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Pontos vs Popularidade (Quantas Listas)',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false },
          tooltip: {
            callbacks: {
              title: function(context) {
                const index = context[0].dataIndex
                return window.pointsVsPopularityLabels ? window.pointsVsPopularityLabels[index] : ''
              },
              label: function(context) {
                return 'Pontos: ' + context.parsed.x + ' | Listas: ' + context.parsed.y
              }
            }
          }
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Pontos da Celebridade'
            },
            beginAtZero: true
          },
          y: {
            title: {
              display: true,
              text: 'Quantidade de Listas'
            },
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  // Age Distribution Chart
  const ageDistributionCanvas = document.getElementById('ageDistributionChart')
  if (ageDistributionCanvas && window.ageDistributionData) {
    const ctx = ageDistributionCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.ageDistributionData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Distribuição de Idades das Mortes',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  // Unique Names Chart
  const uniqueNamesCanvas = document.getElementById('uniqueNamesChart')
  if (uniqueNamesCanvas && window.uniqueNamesData) {
    const ctx = uniqueNamesCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.uniqueNamesData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Nomes Únicos no Ano',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(context) {
                return 'Total: ' + context.parsed.y + ' nomes únicos'
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  // Name Repetition Distribution Chart
  const nameRepetitionCanvas = document.getElementById('nameRepetitionChart')
  if (nameRepetitionCanvas && window.nameRepetitionData) {
    const ctx = nameRepetitionCanvas.getContext('2d')
    new Chart(ctx, {
      type: 'bar',
      data: window.nameRepetitionData,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: 'Distribuição de Repetições de Nomes',
            font: { size: 16, weight: 'bold' }
          },
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(context) {
                return context.label + ': ' + context.parsed.y + ' nomes'
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 },
            title: {
              display: true,
              text: 'Quantidade de Nomes'
            }
          },
          x: {
            title: {
              display: true,
              text: 'Número de Repetições'
            }
          }
        }
      }
    })
  }
}

function initChartsWhenReady() {
  if (waitForChart()) {
    initializeCharts()
  } else {
    // Try again after a short delay
    setTimeout(initChartsWhenReady, 100)
  }
}

document.addEventListener("DOMContentLoaded", function() {
  initChartsWhenReady()
})

// Also initialize on Turbo navigation
document.addEventListener("turbo:load", function() {
  initChartsWhenReady()
})
