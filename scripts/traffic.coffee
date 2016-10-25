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
  official_url: 'http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx'

  constructor: (options)->
    @channel = 'random-1'
    @cronTime = '0 */6 * * * *'
    @timezone = process.env.TZ

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
          message = 'ごめん、えらった。\n' + @official_url
        else
          res.reply @make_message(alerts)

    robot.respond /--debug-traffic$/, (res)=>
      Traffic.get_morning_message (message)=>
        res.reply message

    robot.respond /--debug-traffic-update$/, (res)=>
      @regular_report(robot)

  translink_alerts: (callback)->
    translink_alerts.get (data)->
      callback(null, [data.train, data.bus])

  make_message: (alerts)->
    [train, bus] = alerts
    if train.fine and bus.fine
      message = '大丈夫そうだよー。'
    else
      message = '乱れてるみたい……。'
    message += '\n' +
      """
      #{@format_alert(train)}
      #{@format_alert(bus)}
      http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
      """

  format_alert: (data)->
    if data.fine
      "✔ #{data.title}"
    else
      "✘ #{data.title} : [#{data.outline}] #{data.description}"

  get_morning_message: (callback)->
    @translink_alerts (err, alerts)=>
      if err
        callback('交通情報はよくわかりませんでした。\n' + @official_url)
        return

      callback(@make_morning_message(alerts))

  make_morning_message: (alerts)->
    [train] = alerts
    if train.fine
      message = 'SkyTrainは平常運転みたいです。'
    else
      message =
        """
        交通機関が乱れてるみたいだよ。気を付けてね。
        #{@format_alert(train)}
        #{@official_url}
        """

  regular_report: (robot)->
    @translink_alerts (err, alerts)=>
      return if err
      @tell_status(robot, alerts)

  tell_status: (robot, alerts)->
    [train] = alerts

    train_updated = @update_status(robot, train)
    if train_updated
      if train.fine
        message = '平常運転に戻りました。'
      else
        message = '交通機関が乱れてるみたいだよ。気を付けてね。'
      message += '\n' +
        """
        #{@format_alert(train)}
        #{@official_url}
        """
      robot.messageRoom @channel, message

  # returns {Boolean} `true`=Something is changed.
  update_status: (robot, data)->
    key = "traffic-status-#{data.title}"
    json = JSON.stringify(data)
    last_json = robot.brain.get(key)
    last_data = JSON.parse(last_json || '{}')

    if json isnt last_json
      robot.brain.set(key, json)
      if !last_json or data.fine and last_data.fine
        return false
      else
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
