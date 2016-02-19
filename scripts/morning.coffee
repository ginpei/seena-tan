# Description:
#   おはよ

CronJob = require('cron').CronJob
moment = require('moment-timezone')
_ = require('lodash')
ForecastBot = require('./../scripts/forecast.coffee').ForecastBot

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

  build_message: (forecast)->
    if forecast
      message =
        """
        おはよう～！　天気予報だよ。
        #{forecast}
        """
    else
      message = 'おはよう～！　今日は天気予報が用意できなかったよ、ごめんね。'

  @first_channel: 'seena_tan'

  @say_good_morning: (robot)->
    candidates = [
      '(´ぅω・`)'
      '(:3[＿＿]'
      '_:(´ཀ`」 ∠):_'
      '(-ω-)Zzz...　Σ(ﾟωﾟ)!'
      '( ³ω³ )｡oO'
      ':(∩ˇωˇ∩):'
    ]
    message = _.sample(candidates)
    robot.messageRoom Morning.first_channel, message

module.exports = (robot) ->
  morning = new Morning()
  morning.start(robot)

  Morning.say_good_morning(robot)

module.exports.Morning = Morning
