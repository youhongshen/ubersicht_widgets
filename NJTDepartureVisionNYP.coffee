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
      <h2>NYP Departure Vision</h2>
      """ + "<h4>" + new Date() + "</h4>" + """
      <div class="grid-container">
        <div class="grid-item">
      """ + output + """
        </div>
      </div>
  """

  return s

#update: (output, dom) ->
#  $(dom).find('#GridView1')
#  $(dom).find('table')

style: """
  font-family: sans-serif
  position: fixed
  left: 1250px
  top: 20px
  color: black

  .grid-item
    font-size: 2px
    background-color: rgba(255, 255, 255, 0.8)
    border: 1px solid rgba(0, 0, 0, 0.8)
    padding: 5px
"""

#  .grid-container
#  display: inline-grid
#  grid-template-columns: 650px
