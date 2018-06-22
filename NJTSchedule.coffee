# returns json on success and failure
command: "/usr/local/Cellar/node@8/8.11.1/bin/node /Volumes/Unix/workplace/JavaScriptTest/njt.js"
refreshFrequency: '2m'

render: (output) ->
  result = JSON.parse output
  if result.results == undefined
#    means it contains error
    return result

  schedule = result.results

#  some config
  timeFromOffice = 1200;  # how long it takes to walk from office to Penn (in sec)
  earliestHourToDisplay = 11;   # only display departure time on or after this hour, to save some space on the bottom
  leaveSoonThresholdMin = 7;    # when should i indicate "leave soon" by blinking?
  catchUpMin = -3;   # should have left x min ago, but if i walk fast, i may still make it

  now = new Date();
  console.log(now)

  s = """
  <h2>NYP to New Brunswick</h2>
  <table border='1'>
  <tr>
  <th>Departure</th>
  <th>Arrival</th>
  <th>Train</th>
  <th>Travel Time</th>
  <th>Leave in (min)</th>
  </tr>
  """

  for item in schedule

    # parse the departure time
    departureTimeStr = item.origin.time;
    m = departureTimeStr.match(/(\d\d):(\d\d)\s*([aApP][mM])/); # departureTimeStr = 10:05 AM
    hour = parseInt(m[1]);
    min = parseInt(m[2]);
    if m[3].toLowerCase() == 'pm' && hour != 12
      hour = hour + 12;

    departureTime = new Date();
    departureTime.setHours(hour);
    departureTime.setMinutes(min);
    departureTime.setSeconds(0);

    # only print if the departure time is after 10am (to save some space on the bottom)
    if hour < earliestHourToDisplay
      continue

    rowClasses = []
    if item.travelTime <= 45
      rowClasses.push("express")

#    now - 0 to force it to do a date subtraction instead of string concat
    arriveAtStationTime = now - 0 + timeFromOffice * 1000         # in epoch time (sec)
    timeUntilLeaveOffice = Math.round((departureTime - arriveAtStationTime) / 1000 / 60) # in min

    # only show "leave in x min" for the next hour
    leaveInMinStr = ""
    if timeUntilLeaveOffice >= 0 && timeUntilLeaveOffice <= 60
#      rowClasses.push("leaveSoon")
#      nextTrainFlag = true
      leaveInMinStr = "Leave in " + timeUntilLeaveOffice + " min"

    # if i need to leave within x min, then blink
    if timeUntilLeaveOffice >= catchUpMin && timeUntilLeaveOffice <= leaveSoonThresholdMin
      rowClasses.push("leaveSoon")

    if timeUntilLeaveOffice < 0 && timeUntilLeaveOffice >= catchUpMin
      leaveInMinStr = "Leave NOW!!"

#      if this row in table has class attached to it
    rowClassStr = ""
    if rowClasses.length > 0
      rowClassStr = ' class="' + rowClasses.join(" ") + '"'

    console.log(departureTimeStr + " " + rowClassStr)
    s = s + "<tr" + rowClassStr + ">"
    s = s + "<td>" + departureTimeStr + "</td>"
    s = s + "<td>" + item.arrivalTime + "</td>"
    s = s + "<td>" + item.origin.trainNumber + "</td>"
    s = s + "<td>" + item.travelTime + " min</td>"
    s = s + "<td>" + leaveInMinStr + "</td>"

    s = s + "</tr>"


  s = s + "</table>"
  s = s + """
    <script>
      console.log('hello world');
      let msg = new SpeechSynthesisUtterance('hello world');
      window.speechSynthesis.speak(msg);

    </script>
  """
  return s

style: """
  font-family: sans-serif
  font-weight: 300
  position: fixed
  left: 100px
  top: 20px
  color: white

  .leaveSoon
    animation: blinker 2s ease-in-out infinite

  .express
    color: red

  @keyframes blinker {
    50% {
      opacity: 0
    }
  }


"""
#  .nextTrain
#    animation: blinker 2s linear infinite
