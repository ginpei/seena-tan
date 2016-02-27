# Description:
#   おはよ

CronJob = require('cron').CronJob
moment = require('moment-timezone')
_ = require('lodash')
ForecastBot = require('./../scripts/forecast.coffee').ForecastBot
Traffic = require('./../scripts/traffic.coffee').Traffic
EventManager = require('./../scripts/event_manager.coffee').EventManager

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
    '(≖x≖) ……'
    '(ृ 　 ु \*`ω､)ु ⋆゜ｽﾔｧ…'
    '(っ ´-` c) -з'
    'ヽ(・ω・)ゝ'
    '(˘ω˘)'
    'ヾ(:3ﾉｼヾ)ﾉｼ三ヾ(ﾉｼヾε:)ﾉ'
    """
    |∧,,∧
    | ･ω･)
    |⊂ ﾉ
    """
  ]

  constructor: (options)->
    @channel = 'random'
    # @cronTime = '*/15 * * * * *'
    @cronTime = '0 30 7 * * *'
    @timezone = process.env.TZ

  start: (robot)->
    job = new CronJob(
      cronTime: @cronTime
      onTick: =>
        @greet(robot)
      start: true
      timeZone: @timezone
    )

    robot.respond /--debug-morning-greet/, (res)=>
      @greet(robot)

  greet: (robot)->
    first_message = 'おはよう～！'
    event_message = @get_event_message(robot.brain)
    if event_message
      first_message += "　今日はイベントがあるよ。\n#{event_message}"

    robot.messageRoom @channel, first_message

    bot = new ForecastBot()
    bot.get_morning_forecast null, (forecast)=>
      message = @build_forecast_message(forecast)
      robot.messageRoom @channel, message

      @get_traffic (message)=>
        robot.messageRoom @channel, message

  build_forecast_message: (forecast)->
    if forecast
      message =
        """
        天気予報はこんな感じ。
        #{forecast}
        """
    else
      message = '今日は天気予報が用意できなかったよ、ごめんね……。'

  get_event_message: (brain)->
    EventManager.get_morning_message(brain)

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
