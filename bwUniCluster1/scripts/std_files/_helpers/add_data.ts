export const pie_chart_opt = {
  titleAnnual: "HAWs utilized cluster capacity (UCC) distribution in",
  title: "HAWs utilized cluster capacity (UCC) in ",
  headerCard: "HAWs UCC distribution",
  columnNames: ['University', 'Percentage'],
  width: 800,
  height: 500,
  pieHole: 0.4,
  fontName: 'K2D',
  fontSize: 18,
  colors: ['#ff1744', '#651fff', '#0091ea', '#43a047', '#78909c', '#ad1457',
           '#00796b', '#827717', '#2962ff', '#8d6e63', '#d500f9'],
  legend: {
    position: 'bottom'
  }
}

export const users_chart_opt = {
  columnNames: ['User ID', 'Total costs'],
  options: {
    pieHole: 0.4,
    fontName: 'K2D',
    fontSize: 18,
    colors: ['#ff1744', '#651fff', '#0091ea', '#43a047', '#78909c', '#ad1457',
             '#00796b', '#827717', '#2962ff', '#8d6e63', '#d500f9'],
    legend: {
      position: 'right'
    }
  },
  width: 800,
  height: 500,
}

export const total_opt = {
  titile: "Utilized cluster capacity (UCC) by all HAWs in",
  headerCard: "Monthly HAWs UCC in percentage",
  fontName: 'K2D',
  fontSize: 16,
  colors: ['#00897b'],
  columnNames: ['Month', 'Percentage'],
  chartWidth: 900,
  chartHeight: 500
}

export const months = [
  'December', 'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];

export const monthsDict = {
  'Jan': 'January', 'Feb': 'February', 'Mar': 'March', 'Apr': 'April',
  'May': 'May', 'Jun': 'June', 'Jul': 'July', 'Aug': 'August', 'Sep': 'September',
  'Oct': 'October', 'Nov': 'November', 'Dec': 'December', 'Year': 'Total'
}
