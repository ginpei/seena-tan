# Description:
#   get traffic
#
# Commands:
#   hubot traffic - Show current traffic information.
#   hubot 電車 - 交通情報を表示する。
#   hubot バス - 交通情報を表示する。
#   hubot 交通 - 交通情報を表示する。

CronJob = require('cron').CronJob
translink_alerts = require('translink-alerts')
_ = require('underscore')

class Traffic
  constructor: (options)->
    @channel = 'random'
    @cronTime = '0 */6 * * * *'
    @timezone = 'America/Vancouver'

  start: (robot)->
    job = new CronJob(
      cronTime: @cronTime
      onTick: =>
        @regular_report(robot)
      start: true
      timeZone: @timezone
    )

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

    robot.respond /--debug-traffic-update/, (res)=>
      @regular_report(robot)

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
    message += '\n'
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

  regular_report: (robot)->
    @translink_alerts (err, alerts)=>
      return if err
      @tell_status(robot, alerts)

  tell_status: (robot, alerts)->
    [bus, train] = alerts

    bus_updated = @update_status(robot, bus)
    train_updated = @update_status(robot, train)
    if bus_updated or train_updated
      if bus.fine and train.fine
        message = '平常運転に戻りました。'
      else
        message = '電車が止まったりしてるみたい。'
      message += '\n' +
        """
        #{@format_alert(bus)}
        #{@format_alert(train)}
        """
      robot.messageRoom @channel, message

  # returns {Boolean} `true`=Something is changed.
  update_status: (robot, data)->
    key = "traffic-status-#{data.title}";
    json = JSON.stringify(data)
    last_json = robot.brain.get(key)

    if json isnt last_json
      robot.brain.set(key, json)
      return true
    else
      return false

  # Instant interface
  @get_morning_message: (callback)->
    traffic = new Traffic()
    traffic.get_morning_message(callback)

module.exports = (robot)->
  traffic = new Traffic()
  traffic.start(robot)

module.exports.Traffic = Traffic
