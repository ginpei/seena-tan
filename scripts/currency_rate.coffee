# Description:
#   為替
# Description:
#   Get currency exchange information.
#
# Commands:
#   hubot currency - Show usage
#   hubot currency CAD JPY - Show the rate for CAD vs JPY

http = require('http')

class CurrencyRate
  api_end_point: 'http://api.fixer.io/latest'

  constructor: (options)->

  start: (robot)->
    robot.respond /(?:currency (\w\w\w) (\w\w\w))/, (res)=>
      base = res.match[1].toUpperCase()
      symbol = res.match[2].toUpperCase()

      res.send 'んーどうかな'
      @fetch base, symbol, (err, data)=>
        if err
          message = 'ごめん、えらった。'
        else
          message = @make_message(data)
        res.reply message

  fetch: (base, symbol, callback)->
    url = @get_fetch_url(base, symbol)
    http.get url, (res)=>
      if res.statusCode is 200
        responseText = ''
        res.on 'responseText', (v)->responseText+=v
        res.on 'end', ()->
          try
            data = JSON.parse(responseText)
            callback(null, data)
          catch error
            callback(error, null)
      else
        error = new Error("#{res.statusCode} ")
        callback(error, null)

  get_fetch_url: (base, symbol)->
    "#{@api_end_point}?base=#{base}&symbols=#{symbol}"

  make_message: (data)->
    symbol = Object.keys(data.rates)[0]
    if symbol
      rate = data.rates[symbol]
      message = "1 #{data.base} = #{rate} #{symbol}"
    else
      message = 'そういうのないみたい'

    message

  # Instant interface
  @fetch: (base, symbole, callback)->
    currency_rate = new CurrencyRate()
    currency_rate.fetch(base, symbole, callback)

module.exports = (robot)->
  currency_rate = new CurrencyRate()
  currency_rate.start(robot)

module.exports.CurrencyRate = CurrencyRate
