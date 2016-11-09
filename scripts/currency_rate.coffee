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
      @fetch base, symbol, (message)=>
        unless message
          message = 'ごめん、えらった。'
        res.reply message

  fetch: (base, symbol, callback)->
    url = @get_fetch_url(base, symbol)
    @http_get url, (res, responseText)=>
      if res.statusCode is 200
        try
          data = JSON.parse(responseText)
          message = @make_message(data)
        catch error
      callback(message)

  http_get: (url, callback)->
    http.get url, (res)=>
      responseText = ''
      res.on 'responseText', (v)->responseText+=v
      res.on 'end', ()->
        callback(res, responseText)

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
