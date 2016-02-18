# Description:
#   天気予報

Forecast = require('forecast.io')
moment = require('moment-timezone')

class ForecastBot
  constructor: ->
    @hourly_limit = 16
    @latitude = process.env.HUBOT_FORECAST_LAT
    @longitude = process.env.HUBOT_FORECAST_LONG
    @timezone = process.env.HUBOT_FORECAST_TZ


  start: (robot)->
    robot.respond /(?:今日の)?天気/, (res)=>
      res.send 'ん。'
      Forecast.get
        APIKey: process.env.HUBOT_FORECAST_API_KEY
        latitude: @latitude
        longitude: @longitude
        units: 'si'
        onsuccess: (data)=>
          hourly_data = data.hourly.data.filter((d,i)=>i<@hourly_limit)
          message = 'こんな感じだよー。\n' + @make_lines(hourly_data).join('\n')
          res.reply message
        onerror: (err)->
          console.error err
          res.reply 'ごめん、えらった！'

  make_lines: (data)->
    message = data.map (d)=>
      time = moment.tz(d.time*1000, @timezone).format('hh:mm')
      temp = Math.floor(d.temperature*10)/10
      temp = "#{temp}.0" if temp is Math.floor(temp)
      temp = " #{temp}" if temp < 10
      precip = Math.floor(d.precipProbability*100)
      precip = " #{precip}" if precip < 10
      icon = @get_weather_icon(d.icon)
      summary = d.summary
      "#{time} #{icon} #{temp}℃ #{precip}% #{summary}"

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
