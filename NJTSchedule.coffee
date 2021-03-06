# returns json on success and failure
command: "/usr/local/bin/node /Volumes/Unix/workplace/JavaScriptTest/njt.js"
refreshFrequency: '2m'

render: (output) ->
  result = JSON.parse output
  if result.results == undefined
#    means it contains error
    return result

  schedule = result.results

#  some config
  timeFromOffice = 18 * 60 ;  # how long it takes to walk from office to Penn (in sec)
  earliestHourToDisplay = 11;   # only display departure time on or after this hour, to save some space on the bottom
  leaveSoonThresholdMin = 7;    # when should i indicate "leave soon" by blinking?
  catchUpMin = -3;   # should have left x min ago, but if i walk fast, i may still make it

  now = new Date();
  console.log("now = " + now);

#  calculate ideal time to leave - this is the set time to leave office everyday
  idealHour = 18;
  idealMin = 20;
  idealTime = new Date();
  idealTime.setHours(idealHour, idealMin, 0);
  idealTimeToLeaveInMin = Math.round((idealTime - now) / 1000 / 60);

#  msg = 'leave in ' + idealTimeToLeaveInMin + ' minutes';
#  window.speechSynthesis.speak(new SpeechSynthesisUtterance(msg));

  if idealTimeToLeaveInMin > 0 && idealTimeToLeaveInMin <= 10
    msg = 'leave in ' + idealTimeToLeaveInMin + ' minutes';
    console.log(msg);
    window.speechSynthesis.speak(new SpeechSynthesisUtterance(msg));

  htmlStr = ""
  htmlStr += "<div class='grid-container'>"
  htmlStr += "<div class='grid-item'>"
  htmlStr += "<h2>NYP to New Brunswick</h2>"
  htmlStr += "<h4>" + now + "</h4>"
  htmlStr += "<hr/>"

  htmlStr = htmlStr + """
  <table border='1'>
  <tr>
  <th>Departure</th>
  <th>Arrival</th>
  <th>Train</th>
  <th>Travel Time</th>
  <th>Leave Office</th>
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
    departureTime.setHours(hour, min, 0);

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

#    console.log(departureTimeStr + " " + rowClassStr)
    htmlStr = htmlStr + "<tr" + rowClassStr + ">"
    htmlStr = htmlStr + "<td>" + departureTimeStr + "</td>"
    htmlStr = htmlStr + "<td>" + item.arrivalTime + "</td>"
    htmlStr = htmlStr + "<td>" + item.origin.trainNumber + "</td>"
    htmlStr = htmlStr + "<td>" + item.travelTime + " min</td>"
    htmlStr = htmlStr + "<td>" + leaveInMinStr + "</td>"

    htmlStr = htmlStr + "</tr>"

  htmlStr = htmlStr + "</table></div></div>"

  return htmlStr

style: """
  font-family: sans-serif
  position: fixed
  left: 80px
  top: 20px
  color: black

  .leaveSoon
    animation: blinker 2s ease-in-out infinite

  .express
    color: red

  @keyframes blinker {
    50% {
      opacity: 0
    }
  }

  .grid-container
    display: inline-grid
    grid-template-columns: 450px

  .grid-item
    background-color: rgba(255, 255, 255, 0.8)
    border: 1px solid rgba(0, 0, 0, 0.8)
    padding: 5px

"""
#  .nextTrain
#    animation: blinker 2s linear infinite
