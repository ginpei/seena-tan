# Description:
#   おはよ

CronJob = require('cron').CronJob
moment = require('moment-timezone')
_ = require('lodash')
ForecastBot = require('./../scripts/forecast.coffee').ForecastBot
Traffic = require('./../scripts/traffic.coffee').Traffic

class Morning
  @morning_messages: [
    '(´ぅω・`)'
    '(:3[＿＿]'
    '\_:(´ཀ`」 ∠):\_'
    '(-ω-)Zzz...　Σ(ﾟωﾟ)!'
    '( ³ω³ )｡oO'
    ':(∩ˇωˇ∩):'
    '[▓▓] \_˙³˙)\_'
    'c(・ω・`c⌒)つ'
    '|∧,,∧\n| ･ω･)\n|⊂ ﾉ'
  ]

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

  @first_channel: 'seena_tan'

  @say_good_morning: (robot)->
    message = _.sample(Morning.morning_messages)
    robot.messageRoom Morning.first_channel, message

module.exports = (robot) ->
  morning = new Morning()
  morning.start(robot)

  Morning.say_good_morning(robot)

module.exports.Morning = Morning
