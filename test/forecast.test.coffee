Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')

PATH = './../scripts/forecast.coffee'
Forecast = require('forecast.io')
ForecastBot = require(PATH).ForecastBot
test_data = require('./forecast.test_data.json')  # https://gist.github.com/ginpei/74dcf10b659ad5d1e8a5

describe 'Forecast', ->
  room = null
  helper = new Helper(PATH)

  waitForMessagesToBe = (done, expected)->
    if expected.length is room.messages.length
      expect(room.messages).to.eql expected
      done()
    else
      setTimeout ->
        waitForMessagesToBe(done, expected)
      , 10

  beforeEach ->
    sinon.stub Forecast, 'get', (options)->
      setTimeout ->
        options.onsuccess(test_data)
      , 20
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    Forecast.get.restore()

  context '今日の天気', ->
    reply_text =
      """
      こんな感じだよー。
      04:00 ☂  9.3℃ 43% Drizzle
      05:00 ☂  9.6℃ 73% Rain
      06:00 ☂  9.5℃ 72% Light Rain
      07:00 ☂  9.3℃ 70% Light Rain
      08:00 ☂  9.0℃ 73% Light Rain
      09:00 ☂  9.0℃ 75% Rain
      10:00 ☂  8.4℃ 77% Rain
      11:00 ☂  8.2℃ 83% Rain
      12:00 ☂  7.6℃ 80% Rain
      01:00 ☂  7.4℃ 80% Rain
      02:00 ☂  7.2℃ 78% Rain
      03:00 ☂  6.7℃ 74% Rain
      04:00 ☂  6.6℃ 71% Light Rain
      05:00 ☂  6.5℃ 63% Light Rain
      06:00 ☂  6.3℃ 55% Light Rain
      07:00 ☂  6.3℃ 35% Drizzle
      """

    context '尋ねる', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 天気'

      it '返信する', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot 天気']
          ['hubot', 'ん。']
          ['hubot', "@alice #{reply_text}"]
        ]

    context '文言パターンの確認', ->
      patterns = [
        '@hubot 天気'
        '@hubot 今日の天気'
        '@hubot 今日の天気を教えて'
      ]

      beforeEach ->
        co ->
          yield room.user.say 'alice', pattern for pattern in patterns

      it 'ちゃんと拾う', (done)->
        expected = []
        for pattern, i in patterns
          expected.push ['alice', pattern]
          expected.push ['hubot', 'ん。']
        for i in patterns
          expected.push ['hubot', "@alice #{reply_text}"]
        waitForMessagesToBe done, expected
