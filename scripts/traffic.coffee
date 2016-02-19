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
    robot.hear /(?:traffic|電車|バス|交通)/, (res)=>
      res.send 'んーどうかな'
      @translink_alerts (err, alerts)=>
        if err
          message = 'ごめん、えらった。'
        else
          res.reply @make_message(alerts)

  translink_alerts: (callback)->
    translink_alerts callback

  make_message: (alerts)->
    bus = _.findWhere(alerts, title:'Bus')
    train = _.findWhere(alerts, title:'SkyTrain')
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

module.exports = (robot)->
  traffic = new Traffic()
  traffic.start(robot)

module.exports.Traffic = Traffic
