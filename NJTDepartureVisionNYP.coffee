#command: (callback) ->
#  fetchData 'http://dv.njtransit.com/mobile/tid-mobile.aspx?sid=NY', (error, data) ->
#    callback(error, data)

# remove everything after google_ad_action
# remove everything before GridView1
# remove everything all </div> -- there's only one

command: "/usr/bin/curl -s http://dv.njtransit.com/mobile/tid-mobile.aspx?sid=NY | sed -e '/google_ad_action/,$d' | sed -e '/GridView1/,$!d' | sed -e 's/<\\/div>//' "
refreshFrequency: '2m'

render: (output) ->
  s = """
<html>

<head>
    <style>
        .grid-container {
            display: inline-grid;
            grid-template-columns: 800px;
        }
        .grid-item {
            background-color: rgba(255, 255, 255, 0.8);
            border: 1px solid rgba(0, 0, 0, 0.8);
            padding: 5px;
        }
    </style>
</head>
<body>
<h2>NYP Departure Vision</h2>
<div class="grid-container">
    <div class="grid-item">
  """ + output + """
    </div>
</div>
</body>
</html>
  """
  return s

#update: (output, dom) ->
#  $(dom).find('#GridView1')
#  $(dom).find('table')


style: """
  position: fixed
  left: 1500px
  top: 100px
  color: white
  font-size: 2px

  h2
    font-size: 22px
"""
#  font-size: 2px

#  .grid-container
#    display: grid
#    grid-template-columns: auto auto auto
#    background-color: #2196F3
#    padding: 10px
#
#  .grid-item
#    background-color: rgba(255, 255, 255, 0.8)
#    border: 1px solid rgba(0, 0, 0, 0.8)
#    padding: 20px
#    font-size: 30px
#    text-align: center

