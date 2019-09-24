import Chart from "chart.js"

let SentimentGauge = {
    buildChart() {
        let ctx = document.getElementById("sentimentGauge");
        let genres = ["one", "two", "three"];
        let counts = [1, 2, 3];
        let chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: genres,
                datasets: [{
                label: '# of Genres',
                data: counts,
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(255, 206, 86, 0.2)'
                ]
                }]
            },
            options: {
                scales: {
                yAxes: [{
                    ticks: {
                    beginAtZero:true
                    }
                }]
                }
            }
        });
    }
}

export default SentimentGauge