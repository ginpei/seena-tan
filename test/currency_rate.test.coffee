Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')

PATH = './../scripts/currency_rate.coffee'
CurrencyRate = require(PATH).CurrencyRate

describe 'CurrencyRate', ->
  room = null
  helper = new Helper(PATH)

  result_ng_invalid_base = {"error":"Invalid base"}
  result_ok = {"base":"CAD","date":"2000-01-21","rates":{"JPY":72.246}}
  result_ok_empty = {"base":"CAD","date":"2000-01-21","rates":{}}

  # from script/Traffic.coffee
  waitForMessagesToBe = (done, expected)->
    if expected.length is room.messages.length
      expect(room.messages).to.eql expected
      done()
    else
      setTimeout ->
        waitForMessagesToBe(done, expected)
      , 10

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context 'currency command', ->
    context 'CAD JPY', ->
      beforeEach ->
        sinon.stub CurrencyRate.prototype, 'fetch', (base, symbol, callback)->
          setTimeout ->
            callback(null, result_ok)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency CAD JPY'

      afterEach ->
        CurrencyRate.prototype.fetch.restore()

      it 'shows the result', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency CAD JPY']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice 1 CAD = 72.246 JPY']
        ]

    context 'CAD JPX', ->
      beforeEach ->
        sinon.stub CurrencyRate.prototype, 'fetch', (base, symbol, callback)->
          setTimeout ->
            callback(null, result_ok_empty)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency CAD JPX'

      afterEach ->
        CurrencyRate.prototype.fetch.restore()

      it 'shows an error message', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency CAD JPX']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice そういうのないみたい']
        ]

    context 'CAX JPY', ->
      beforeEach ->
        sinon.stub CurrencyRate.prototype, 'fetch', (base, symbol, callback)->
          setTimeout ->
            callback(new Error('422'), result_ng_invalid_base)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency CAX JPY'

      afterEach ->
        CurrencyRate.prototype.fetch.restore()

      it 'shows an error message', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency CAX JPY']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice ごめん、えらった。']
        ]
