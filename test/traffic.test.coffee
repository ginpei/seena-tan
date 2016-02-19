Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')

PATH = './../scripts/traffic.coffee'
Traffic = require(PATH).Traffic

describe 'Traffic', ->
  room = null
  helper = new Helper(PATH)

  operating_wo_errors = true
  result_ok = [
    { title:'Bus', status:'Operating normally.', fine:true }
    { title:'SkyTrain', status:'Operating normally.', fine:true }
  ]
  result_ng = [
    { title:'Bus', status:'Operating normally.', fine:true }
    {
      title: 'SkyTrain',
      status: 'Something wrong.',
      fine: false,
      detail: 'Spider man is running on the rails.'
    }
  ]

  waitForMessagesToBe = (done, expected)->
    if expected.length is room.messages.length
      expect(room.messages).to.eql expected
      done()
    else
      setTimeout ->
        waitForMessagesToBe(done, expected)
      , 10

  beforeEach ->
    sinon.stub Traffic.prototype, 'translink_alerts', (callback)->
      setTimeout ->
        if operating_wo_errors
          result = result_ok
        else
          result = result_ng
        callback(null, result)
      , 20
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    Traffic.prototype.translink_alerts.restore()

  context '確認', ->
    context '普通に動いてるとき', ->
      reply_text =
        """
        大丈夫そうだよー。
        ✔ Bus
        ✔ SkyTrain
        """

      beforeEach ->
        co ->
          operating_wo_errors = true
          yield room.user.say 'alice', '@hubot 電車大丈夫？'

      it '返信する', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot 電車大丈夫？']
          ['hubot', 'んーどうかな']
          ['hubot', "@alice #{reply_text}"]
        ]

    context '乱れているとき', ->
      reply_text =
        """
        乱れてるみたい……。
        ✔ Bus
        ✘ SkyTrain : [Something wrong.] Spider man is running on the rails.
        """

      beforeEach ->
        co ->
          operating_wo_errors = false
          yield room.user.say 'alice', '@hubot 電車大丈夫？'

      it '返信する', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot 電車大丈夫？']
          ['hubot', 'んーどうかな']
          ['hubot', "@alice #{reply_text}"]
        ]
