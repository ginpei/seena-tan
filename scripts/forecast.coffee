# Description:
#   天気予報
# Commands:
#   hubot 今日の天気を教えて - 16時間分の天気予報
#   hubot 今週の天気を教えて - 7日間分の天気予報

Forecast = require('forecast.io')
moment = require('moment-timezone')

class ForecastBot
  constructor: ->
    @hourly_limit = 16
    @daily_limit = 7
    @latitude = process.env.HUBOT_FORECAST_LAT
    @longitude = process.env.HUBOT_FORECAST_LONG
    @timezone = process.env.HUBOT_FORECAST_TZ

  start: (robot)->
    robot.respond /(?:今日の)?天気/, (res)=>
      res.send 'ん。'
      @get_forecast res, (data)=>
        hourly_data = data.hourly.data.filter((d,i)=>i<@hourly_limit)
        lines = @make_lines(hourly_data, 'hh:mm')
        message = 'こんな感じだよー。\n' + lines.join('\n')
        res.reply message

    robot.respond /(?:今週|一週間)の天気/, (res)=>
      res.send 'ん。'
      @get_forecast res, (data)=>
        daily_data = data.daily.data.filter((d,i)=>i<@daily_limit)
        lines = @make_lines(daily_data, 'M/DD')
        message = 'こんな感じだよー。\n' + lines.join('\n')
        res.reply message

  get_forecast: (res, callback)->
    Forecast.get
      APIKey: process.env.HUBOT_FORECAST_API_KEY
      latitude: @latitude
      longitude: @longitude
      units: 'si'
      onsuccess: (data)=>
        callback(data)
      onerror: (err)->
        console.error err
        res.reply 'ごめん、えらった！'

  make_lines: (data, time_format)->
    message = data.map (d)=>
      time = moment.tz(d.time*1000, @timezone).format(time_format)
      temp = @get_tempreture(d)
      precip = Math.floor(d.precipProbability*100)
      precip = " #{precip}" if precip < 10
      icon = @get_weather_icon(d.icon)
      summary = d.summary
      "#{time} #{icon} #{temp}℃ #{precip}% #{summary}"

  get_tempreture: (data)->
    if data.temperature
      @n_to_s(data.temperature)
    else if data.temperatureMin
      "#{@n_to_s(data.temperatureMin)}～#{@n_to_s(data.temperatureMax)}"

  n_to_s: (n)->
    n = Math.floor(n*10)/10
    n = "#{n}.0" if n is Math.floor(n)
    n = " #{n}" if n < 10 and n >= 0
    n

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
      when 'partly-cloudy-day', 'partly-cloudy-night'
        '⛅'
      when 'wind'
        '🍃'
      else
        '？'

module.exports = (robot)->
  forecast = new ForecastBot()
  forecast.start(robot)

module.exports.ForecastBot = ForecastBot
