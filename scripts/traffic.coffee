# Description:
#   get traffic
#
# Commands:
#   hubot traffic - Show current traffic information.
#   hubot 電車 - 交通情報を表示する。
#   hubot バス - 交通情報を表示する。
#   hubot 交通 - 交通情報を表示する。

translink_alerts = require('translink-alerts')
_ = require('underscore')

class Traffic
  start: (robot)->
    robot.respond /(?:traffic|電車|バス|交通)/, (res)=>
      res.send 'んーどうかな'
      @translink_alerts (err, alerts)=>
        if err
          message = 'ごめん、えらった。'
        else
          res.reply @make_message(alerts)

    robot.respond /--debug-traffic/, (res)=>
      Traffic.get_morning_message (message)=>
        res.reply message

  translink_alerts: (callback)->
    translink_alerts (err, alerts)->
      if alerts
        bus = _.findWhere(alerts, title:'Bus')
        train = _.findWhere(alerts, title:'SkyTrain')
      callback(err, [bus, train])

  make_message: (alerts)->
    [bus, train] = alerts
    if bus.fine and train.fine
      message = '大丈夫そうだよー。'
    else
      message = '乱れてるみたい……。'
    message +=
      """

      #{@format_alert(bus)}
      #{@format_alert(train)}
      """

  format_alert: (data)->
    if data.fine
      "✔ #{data.title}"
    else
      "✘ #{data.title} : [#{data.status}] #{data.detail}"

  get_morning_message: (callback)->
    @translink_alerts (err, alerts)=>
      if err
        callback('交通情報はよくわかりませんでした。')
        return

      callback(@make_morning_message(alerts))

  make_morning_message: (alerts)->
    [bus, train] = alerts
    if bus.fine and train.fine
      message = '電車とバスは平常運転みたいです。'
    else
      message =
        """
        電車が止まったりしてるみたい。
        #{@format_alert(bus)}
        #{@format_alert(train)}
        """

  # Instant interface
  @get_morning_message: (callback)->
    traffic = new Traffic()
    traffic.get_morning_message(callback)

module.exports = (robot)->
  traffic = new Traffic()
  traffic.start(robot)

module.exports.Traffic = Traffic
