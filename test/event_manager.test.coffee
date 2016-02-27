Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')
moment = require('moment-timezone')

PATH = './../scripts/event_manager.coffee'
EventManager = require(PATH).EventManager

describe 'EventManager', ->
  room = null
  helper = new Helper(PATH)

  beforeEach ->
    sinon.stub EventManager.prototype, 'now', ()-> moment.tz('2000-12-01 12:00', process.env.TZ)
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    EventManager.prototype.now.restore()

  context 'hubot event', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot event'

    it 'shows the usage', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot event']
        ['hubot', "@alice #{EventManager.MSG_USAGE}"]
      ]

  context 'hubot event list', ->
    beforeEach ->
      room.robot.brain.set 'event_manager.events', JSON.stringify([
        { date:'2000-11-30 12:00', name:'Lunch at Sugoi Sushi' }
        { date:'2000-12-02 09:08', name:'Meet up' }
        { date:'2000-12-13 12:59', name:'Hiking' }
        { date:'2001-01-02 19:00', name:'New Year Party' }
      ])
      co ->
        yield room.user.say 'alice', '@hubot event list'

    it 'shows the list of events without expired items', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot event list']
        [
          'hubot',
          """
          @alice Events:
          12-02 Sa 09:08 Meet up
          12-13 We 12:59 Hiking
          01-02 Tu 19:00 New Year Party
          """
        ]
      ]

  context 'hubot event add <starts_at> <name>', ->
    context 'with valid date', ->
      beforeEach ->
        room.robot.brain.set 'event_manager.events', JSON.stringify([
          { date:'2000-12-13 12:59', name:'Hiking' }
        ])
        co ->
          yield room.user.say 'alice', '@hubot event add 12-2 19:30 Meet up'
          yield room.user.say 'alice', '@hubot event add 1-2 9:8 New Year Party'

      it 'registers a specified event as ordered', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot event add 12-2 19:30 Meet up']
          ['hubot',
            """
            @alice Meet up is successfully registered.
            12-02 Sa 19:30 Meet up
            12-13 We 12:59 Hiking
            """]
          ['alice', '@hubot event add 1-2 9:8 New Year Party']
          ['hubot',
            """
            @alice New Year Party is successfully registered.
            12-02 Sa 19:30 Meet up
            12-13 We 12:59 Hiking
            01-02 Tu 09:08 New Year Party
            """]
        ]

    context 'with valid date but duplicated', ->
      beforeEach ->
        room.robot.brain.set 'event_manager.events', JSON.stringify([
          { date:'2000-12-13 12:59', name:'Hiking' }
        ])
        co ->
          yield room.user.say 'alice', '@hubot event add 12-13 12:59 Hiking'

      it 'tells what was happened', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot event add 12-13 12:59 Hiking']
          ['hubot',
            """
            @alice Hiking is already registered at the same time.
            12-13 We 12:59 Hiking
            """]
        ]

    context 'with invalid date', ->
      beforeEach ->
        room.robot.brain.set 'event_manager.events', JSON.stringify([
          { date:'2000-12-13 12:59', name:'Hiking' }
        ])
        co ->
          yield room.user.say 'alice', '@hubot event add 99-99 99:99 Hello world'
          yield room.user.say 'alice', '@hubot event list'

      it 'does not add the one', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot event add 99-99 99:99 Hello world']
          ['hubot', '@alice It looks invalid date and/or time! Date has to be like: "1-1 0:0" or "12-31 23:59".']
          ['alice', '@hubot event list']
          ['hubot', """
            @alice Events:
            12-13 We 12:59 Hiking
          """]
        ]

  context 'hubot event remove <id>', ->
    beforeEach ->
      room.robot.brain.set 'event_manager.events', JSON.stringify([
        { date:'2000-12-02 09:08', name:'Meet up' }
        { date:'2000-12-03 12:59', name:'Hiking' }
      ])
      co ->
        yield room.user.say 'alice', '@hubot event remove 12-03 12:59 Hxking'
        yield room.user.say 'alice', '@hubot event remove 12-13 12:59 Hiking'
        yield room.user.say 'alice', '@hubot event remove 12-3 12:59 Hiking'
        yield room.user.say 'alice', '@hubot event list'

    it 'removes the specified event', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot event remove 12-03 12:59 Hxking']
        ['hubot', '@alice Sorry, the event you specified is not found.']
        ['alice', '@hubot event remove 12-13 12:59 Hiking']
        ['hubot', '@alice Sorry, the event you specified is not found.']
        ['alice', '@hubot event remove 12-3 12:59 Hiking']
        ['hubot', '@alice Hiking is successfully removed.']
        ['alice', '@hubot event list']
        ['hubot', """
          @alice Events:
          12-02 Sa 09:08 Meet up
        """]
      ]

  context 'get_morning_message', ->
    context 'some', ->
      message = null

      beforeEach ->
        room.robot.brain.set 'event_manager.events', JSON.stringify([
          { date:'2000-12-01 12:00', name:'Lunch at Sugoi Sushi' }
          { date:'2000-12-01 19:00', name:'Meet up' }
        ])
        co ->
          yield room.user.say 'alice', '@hubot --debug-event-morning'

      it 'returns a message', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot --debug-event-morning']
          ['hubot', """
            12:00 Lunch at Sugoi Sushi
            19:00 Meet up
          """]
        ]

  context '#parse_time()', ->
    obj = null
    beforeEach ->
      obj = new EventManager()

    it 'uses current year', ->
      expect(obj.parse_time('12-31 12:00').format('YYYY-MM-DD')).to.eql '2000-12-31'

    it 'uses next year', ->
      expect(obj.parse_time('1-2 3:4').format('YYYY-MM-DD HH:mm')).to.eql '2001-01-02 03:04'
