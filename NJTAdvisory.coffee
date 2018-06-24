#command: (callback) ->
#  fetch 'http://www.njtransit.com/rss/RailAdvisories_feed.xml', (error, data) ->
#    callback(error, data)

command: "curl -s https://www.njtransit.com/rss/RailAdvisories_feed.xml "
refreshFrequency: '5m'

render: (xml) ->

  convert = require('xml-js')
  jsonStr = convert.xml2json(xml,{compact: true, spaces: 2})
  console.log(jsonStr)
  json = JSON.parse(jsonStr)
  items = json['rss']['channel']['item']
  console.log(items)

#  items is a list of obj that look like this
#  {
#     'description': the text we want to capture,
#     'title': the published timestamp (Jun 23, 2018 06:01:18 PM)
#     'time': parse the title field and add the date there <-- added later
#     ...
#  }

  todayBegin = new Date()
  todayBegin.setHours(0, 0, 0)    # today midnight

#  parse date and add to the item object
  items.map((item) ->
    time = Date.parse(item.title._text)
    item['time'] = time   # of type number
  )

  items = items.filter((item) -> item.time > todayBegin)    # only keep today's advisory

  #  build the advisory object
  advisory = {}
  for item in items
    timestamp = item.title._text
    advisory[timestamp] = item.description._text

#    build html

  htmlStr = "<h2>NJT Advisory</h2>"
  htmlStr += "<h4>" + new Date() + "</h4>"

  htmlStr += "<div class='grid-container'>"
  htmlStr += "<div class='grid-item'>"
  htmlStr += "<table>"
  for timestamp, description of advisory
    htmlStr += "<tr class='timestamp'><td>" + timestamp + "</td></tr>"
    htmlStr += "<tr class='description'><td>" + description + "</td></tr>"

  htmlStr += "</table></div></div>"

  return htmlStr


style: """
  font-family: sans-serif
  position: fixed
  left: 550px
  top: 20px
  color: black

  .timestamp
    font-weight: bold

  .grid-container
    display: inline-grid
    grid-template-columns: 650px

  .grid-item
    background-color: rgba(255, 255, 255, 0.8)
    border: 1px solid rgba(0, 0, 0, 0.8)
    padding: 5px
"""

