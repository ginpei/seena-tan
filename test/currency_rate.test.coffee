Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')

PATH = './../scripts/currency_rate.coffee'
CurrencyRate = require(PATH).CurrencyRate

describe 'CurrencyRate', ->
  room = null
  helper = new Helper(PATH)

  result_ng_invalid_base = '{"error":"Invalid base"}'
  result_ok = '{"base":"CAD","date":"2000-01-21","rates":{"JPY":72.246}}'
  result_ok_empty = '{"base":"CAD","date":"2000-01-21","rates":{}}'

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
        sinon.stub CurrencyRate.prototype, 'http_get', (url, callback)->
          setTimeout ->
            callback({ statusCode: 200 }, result_ok)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency CAD JPY'

      afterEach ->
        CurrencyRate.prototype.http_get.restore()

      it 'shows the result', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency CAD JPY']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice 1 CAD = 72.246 JPY']
        ]

    context 'CAD XXX', ->
      beforeEach ->
        sinon.stub CurrencyRate.prototype, 'http_get', (url, callback)->
          setTimeout ->
            callback({ statusCode: 200 }, result_ok_empty)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency CAD XXX'

      afterEach ->
        CurrencyRate.prototype.http_get.restore()

      it 'shows an error message', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency CAD XXX']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice そういうのないみたい']
        ]

    context 'XXX JPY', ->
      beforeEach ->
        sinon.stub CurrencyRate.prototype, 'http_get', (url, callback)->
          setTimeout ->
            callback({ statusCode: 422 }, result_ng_invalid_base)
          , 20

        co ->
          currency_rate_error = null
          yield room.user.say 'alice', '@hubot currency XXX JPY'

      afterEach ->
        CurrencyRate.prototype.http_get.restore()

      it 'shows an error message', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot currency XXX JPY']
          ['hubot', 'んーどうかな']
          ['hubot', '@alice ごめん、えらった。']
        ]

  context 'CurrencyRate.fetch()', ->
    beforeEach ->
      sinon.stub CurrencyRate.prototype, 'http_get', (url, callback)->
        setTimeout ->
          callback({ statusCode: 200 }, result_ok)
        , 20

    it 'returns the result', (done)->
      CurrencyRate.fetch 'CAD', 'JPY', (message)->
        expect(message).to.eql '1 CAD = 72.246 JPY'
        done()
