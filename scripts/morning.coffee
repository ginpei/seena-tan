# Description:
#   おはよ

CronJob = require('cron').CronJob
moment = require('moment-timezone')
ForecastBot = require('./../scripts/forecast.coffee').ForecastBot
Traffic = require('./../scripts/traffic.coffee').Traffic

class Morning
  constructor: (options)->
    @channel = 'random'
    # @cronTime = '*/15 * * * * *'
    @cronTime = '0 30 7 * * *'
    @timezone = 'America/Vancouver'

  start: (robot)->
    job = new CronJob(
      cronTime: @cronTime
      onTick: =>
        @greet(robot)
      start: true
      timeZone: @timezone
    )

  greet: (robot)->
    bot = new ForecastBot()
    bot.get_morning_forecast null, (forecast)=>
      message = @build_message(forecast)
      robot.messageRoom @channel, message

      @get_traffic (message)=>
        robot.messageRoom @channel, message

  build_message: (forecast)->
    if forecast
      message =
        """
        おはよう～！　天気予報だよ。
        #{forecast}
        """
    else
      message = 'おはよう～！　今日は天気予報が用意できなかったよ、ごめんね。'

  get_traffic: (callback)->
    Traffic.get_morning_message callback

module.exports = (robot) ->
  morning = new Morning()
  morning.start(robot)

  robot.messageRoom 'seena_tan', '(´ぅω・`) おはよ'

module.exports.Morning = Morning
