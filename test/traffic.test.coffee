Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')

PATH = './../scripts/traffic.coffee'
Traffic = require(PATH).Traffic

describe 'Traffic', ->
  room = null
  helper = new Helper(PATH)

  traffic_error = null
  result_ok = [
    { title:'SkyTrain', status:'Operating normally.', effective:'Feb 27 2016 12:57:PM', fine:true }
    { title:'Bus',      status:'Operating normally.', effective:'Feb 27 2016 12:57:PM', fine:true }
  ]
  result_ok2 = [
    { title:'SkyTrain', status:'Operating normally.', effective:'Feb 27 2016 12:58:PM', fine:true }
    { title:'Bus',      status:'Operating normally.', effective:'Feb 27 2016 12:58:PM', fine:true }
  ]
  result_ng_train = [
    {
      title: 'SkyTrain',
      status: 'Something wrong.',
      effective:'Feb 27 2016 12:57:PM',
      fine: false,
      detail: 'Spider man is running on the rails.'
    }
    { title:'Bus', status:'Operating normally.', effective:'Feb 27 2016 12:57:PM', fine:true }
  ]
  result_ng_bus = [
    { title:'SkyTrain', status:'Operating normally.', effective:'Feb 27 2016 12:57:PM', fine:true }
    {
      title: 'Bus',
      status: 'Something wrong.',
      effective:'Feb 27 2016 12:57:PM',
      fine: false,
      detail: 'Spider man is running on the rails.'
    }
  ]

  # FIXME: this way isn't working well. Updating to wait all messages is required.
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
        if traffic_error is 'train'
          result = result_ng_train
        else if traffic_error is 'bus'
          result = result_ng_bus
        else if traffic_error is 'ok2'
          result = result_ok2
        else
          result = result_ok
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
        ✔ SkyTrain
        ✔ Bus
        http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
        """

      beforeEach ->
        co ->
          traffic_error = null
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
        ✘ SkyTrain : [Something wrong.] Spider man is running on the rails.
        ✔ Bus
        http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
        """

      beforeEach ->
        co ->
          traffic_error = 'train'
          yield room.user.say 'alice', '@hubot 電車大丈夫？'

      it '返信する', (done)->
        waitForMessagesToBe done, [
          ['alice', '@hubot 電車大丈夫？']
          ['hubot', 'んーどうかな']
          ['hubot', "@alice #{reply_text}"]
        ]

  context '毎朝報告用', ->
    context '普通に動いてるとき', ->
      traffic = null
      sent_text = null

      beforeEach (done)->
        traffic_error = null
        Traffic.get_morning_message (message)->
          sent_text = message
          done()

      it '文言を返す', ->
        expect(sent_text).to.eql 'SkyTrainは平常運転みたいです。'

    context '乱れているとき', ->
      sent_text = null

      beforeEach (done)->
        traffic_error = 'train'
        Traffic.get_morning_message (message)->
          sent_text = message
          done()

      it '文言を返す', ->
        message =
          """
          交通機関が乱れてるみたいだよ。気を付けてね。
          ✘ SkyTrain : [Something wrong.] Spider man is running on the rails.
          http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
          """
        expect(sent_text).to.eql message

  context '定期確認', ->
    traffic = null
    # context '確認', ->
    #   it 'ok', ->
    #     robot =
    #       brain:
    #         data: {}
    #         get: (key)->
    #           if key in @data
    #             @data[key]
    #           else
    #             null
    #         set: (key, value)->
    #             @data[key] = value
    #     data = {}
    #     expec(traffic.f(robot, )

    context '正常のまま', ->
      beforeEach ->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = null
        traffic.regular_report(room.robot)

        traffic_error = null
        traffic.regular_report(room.robot)

      it '何も発言しない', (done)->
        waitForMessagesToBe done, [
        ]

    context '正常のままだが内容更新', ->
      beforeEach (done)->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = null
        traffic.regular_report(room.robot)

        setTimeout ->
          traffic_error = 'ok2'
          traffic.regular_report(room.robot)
          setTimeout ->
            done()
          , 30
        , 30

      it '何も発言しない', (done)->
        waitForMessagesToBe done, [
        ]

    context '電車が異常になった', ->
      beforeEach (done)->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = null
        traffic.regular_report(room.robot)

        setTimeout ->
          traffic_error = 'train'
          traffic.regular_report(room.robot)
          setTimeout ->
            done()
          , 30
        , 30

      it '報告', (done)->
        message =
          """
          交通機関が乱れてるみたいだよ。気を付けてね。
          ✘ SkyTrain : [Something wrong.] Spider man is running on the rails.
          http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
          """
        waitForMessagesToBe done, [
          ['hubot', message]
        ]

    context '電車が異常のまま', ->
      beforeEach ->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = 'train'
        traffic.regular_report(room.robot)

        traffic_error = 'train'
        traffic.regular_report(room.robot)

      it '何も発言しない', (done)->
        waitForMessagesToBe done, [
        ]

    context '電車が正常に戻った', ->
      beforeEach (done)->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = 'train'
        traffic.regular_report(room.robot)

        setTimeout ->
          traffic_error = null
          traffic.regular_report(room.robot)
          setTimeout ->
            done()
          , 30
        , 30

      it '報告', (done)->
        message =
          """
          平常運転に戻りました。
          ✔ SkyTrain
          http://www.translink.ca/en/Schedules-and-Maps/Alerts.aspx
          """
        waitForMessagesToBe done, [
          ['hubot', message]
        ]

    context 'バスが異常になった', ->
      beforeEach ->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = null
        traffic.regular_report(room.robot)

        traffic_error = 'bus'
        traffic.regular_report(room.robot)

      it '何も発言しない', (done)->
        waitForMessagesToBe done, [
        ]

    context 'バスが正常に戻った', ->
      beforeEach ->
        traffic = new Traffic()
        traffic.channel = room.name

        traffic_error = 'bus'
        traffic.regular_report(room.robot)

        traffic_error = null
        traffic.regular_report(room.robot)

      it '何も発言しない', (done)->
        waitForMessagesToBe done, [
        ]
