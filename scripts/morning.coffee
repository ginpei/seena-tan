# Description:
#   おはよ

CronJob = require('cron').CronJob
moment = require('moment-timezone')

class Morning
  constructor: (options)->
    @channel = 'random'
    @cronTime = '0 30 7 * * *'
    @timezone = 'America/Vancouver'

  start: (robot)->
    job = new CronJob(
      cronTime: @cronTime
      onTick: =>
        @forecast(robot)
      start: true
      timeZone: @timezone
    )

  forecast: (robot)->
    @get_forecast robot, (data)=>
      robot.messageRoom @channel, @build_message(data.daily)

  get_forecast: (robot, callback)->
    robot.http(@forecast_url()).query(units:'ca').get() (err, res, body)=>
      if err
        console.error robot.send 'Could not get weather forecast.'
        return

      try
        data = JSON.parse(body)
      catch err
        console.error 'Unable to parse forecast data.'
        return

      callback(data)

  forecast_url: ()->
    key = process.env.HUBOT_FORECAST_API_KEY
    lat = '49.2604'
    lng = '-123.1134'
    url = "https://api.forecast.io/forecast/#{key}/#{lat},#{lng}"

  build_message: (daily_forecast)->
    summary = daily_forecast.summary
    [today, tomorrow, days_after_tomorrow...] = daily_forecast.data
    icons = days_after_tomorrow.map (data)=>@get_weather_icon(data.icon)
    message =
      """
      Good morning! You need weather report? #{summary}
      - #{@format_forecast(today)}
      - #{@format_forecast(tomorrow)}
      - And #{icons.join ' '}
      """

  format_forecast: (data)->
    time = moment.tz(data.time * 1000, @timezone)
    icon = @get_weather_icon(data.icon)
    temp_min = Math.round(data.temperatureMin)
    temp_max = Math.round(data.temperatureMax)
    "#{time.format 'M/D'} #{icon} #{data.summary} #{temp_min}-#{temp_max}℃"

  get_weather_icon: (name)->
    switch name
      when 'clear-day', 'clear-night'
        '☀'
      when 'rain'
        '☂'
      when 'snow', 'sleet'
        '☃'
      when 'fog', 'cloudy'
        '☁'
      when 'partly-cloudy-day', 'partly-cloudy-nigh'
        '⛅'
      when 'wind'
        '🍃'
      else
        '？'

module.exports = (robot) ->
  morning = new Morning()
  morning.start(robot)

  robot.messageRoom 'seena_tan', '(´ぅω・`) おはよ'

module.exports.Morning = Morning
