# returns json on success and failure
command: "/usr/local/Cellar/node@8/8.11.1/bin/node /Volumes/Unix/workplace/JavaScriptTest/njt.js"
refreshFrequency: '12h'

render: (output) ->
  schedule = JSON.parse output
  result = schedule.results

  s = """
  <h2>NYP to New Brunswick</h2>
  <table border='1'>
  <tr>
  <th>Departure</th>
  <th>Arrival</th>
  <th>Train</th>
  <th>Travel Time</th>
  </tr>"
  """
  for item in result
    if item.travelTime <= 45
      s = s + "<tr id='express'>"
    else
      s = s + "<tr>"

    s = s + "<td>" + item.origin.time + "</td>"
    s = s + "<td>" + item.arrivalTime + "</td>"
    s = s + "<td>" + item.origin.trainNumber + "</td>"
    s = s + "<td>" + item.travelTime + "</td>"
    s = s + "</tr>"


  s = s + "</table>"
  return s

style: """
  font-family: sans-serif
  font-weight: 300
  position: fixed
  left: 100px
  top: 50px
  color: white

  #express
    color: red
"""
