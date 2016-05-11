Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')
moment = require('moment-timezone')

PATH = './../scripts/house_cleaning.coffee'
HouseCleaning = require(PATH).HouseCleaning

describe 'HouseCleaning', ->
  room = null
  helper = new Helper(PATH)

  beforeEach ->
    # sinon.stub HouseCleaning.prototype, 'now', ()-> moment.tz('2000-12-01 12:00', process.env.TZ)
    room = helper.createRoom()

    room.robot.brain.set 'HouseCleaning.User', JSON.stringify([
      { name:'Alice' }
      { name:'Bob' }
      { name:'Carol' }
      { name:'Eve' }
    ])
    room.robot.brain.set 'HouseCleaning.Location', JSON.stringify([
      { name:'Bathroom' }
      { name:'Entrance' }
      { name:'Kitchen 1' }
      { name:'Kitchen 2' }
    ])

  afterEach ->
    room.destroy()
    # HouseCleaning.prototype.now.restore()

  context 'hubot house-cleaning', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning'

    it 'shows the usage', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning']
        ['hubot', "@alice #{HouseCleaning.MSG_USAGE}"]
      ]

  context 'hubot house-cleaning user', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning user'

    it 'shows user names', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning user']
        ['hubot', """
          @alice Users:
          - Alice
          - Bob
          - Carol
          - Eve
        """ ]
      ]

  context 'hubot house-cleaning user add <user-name>', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning user add Dan Cou Ga'

    it 'adds the new user', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning user add Dan Cou Ga']
        ['hubot', """
          @alice Dan Cou Ga is successfully added.
          - Alice
          - Bob
          - Carol
          - Eve
          - Dan Cou Ga
        """ ]
      ]

  context 'hubot house-cleaning user remove <user-name>', ->
    beforeEach ->
      room.robot.brain.set 'HouseCleaning.User', JSON.stringify([
        { name:'Alice' }
        { name:'Bob' }
        { name:'Carol' }
        { name:'Eve' }
        { name:'Dan Cou Ga' }
      ])

      co ->
        yield room.user.say 'alice', '@hubot house-cleaning user remove Dan Cou Ga'
        yield room.user.say 'alice', '@hubot house-cleaning user remove Carol'

    it 'remove the new user', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning user remove Dan Cou Ga']
        ['hubot', """
          @alice Dan Cou Ga is successfully removed.
          - Alice
          - Bob
          - Carol
          - Eve
        """ ]
        ['alice', '@hubot house-cleaning user remove Carol']
        ['hubot', """
          @alice Carol is successfully removed.
          - Alice
          - Bob
          - Eve
        """ ]
      ]

  context 'hubot house-cleaning location', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning location'

    it 'shows location names', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning location']
        ['hubot', """
          @alice Locations:
          - Bathroom
          - Entrance
          - Kitchen 1
          - Kitchen 2
        """ ]
      ]

  context 'hubot house-cleaning location add <location-name>', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning location add Centre of the Earth'

    it 'adds the new location', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning location add Centre of the Earth']
        ['hubot', """
          @alice Centre of the Earth is successfully added.
          - Bathroom
          - Entrance
          - Kitchen 1
          - Kitchen 2
          - Centre of the Earth
        """ ]
      ]

  context 'hubot house-cleaning location remove <location-name>', ->
    beforeEach ->
      room.robot.brain.set 'HouseCleaning.Location', JSON.stringify([
        { name:'Bathroom' }
        { name:'Entrance' }
        { name:'Kitchen 1' }
        { name:'Kitchen 2' }
        { name:'Centre of the Earth' }
      ])

      co ->
        yield room.user.say 'alice', '@hubot house-cleaning location remove Centre of the Earth'

    it 'removes the new location', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning location remove Centre of the Earth']
        ['hubot', """
          @alice Centre of the Earth is successfully removed.
          - Bathroom
          - Entrance
          - Kitchen 1
          - Kitchen 2
        """ ]
      ]

  context 'oracle', ->
    beforeEach ->
      sinon.stub HouseCleaning.Location, 'shuffle', ()-> @all().reverse()

    afterEach ->
      HouseCleaning.Location.shuffle.restore()

    context 'hubot house-cleaning rand', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot house-cleaning rand'

      it 'adds the new location', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot house-cleaning rand']
          ['hubot', """
            @alice Here's the oracle.
            - Alice = Kitchen 2
            - Bob = Kitchen 1
            - Carol = Entrance
            - Eve = Bathroom
          """ ]
        ]

    context 'hubot 掃除当番更新', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 掃除当番更新'
          yield room.user.say 'alice', '@hubot 掃除当番を更新して'

      it 'adds the new location', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 掃除当番更新']
          ['hubot', """
            @alice Here's the oracle.
            - Alice = Kitchen 2
            - Bob = Kitchen 1
            - Carol = Entrance
            - Eve = Bathroom
          """ ]
          ['alice', '@hubot 掃除当番を更新して']
          ['hubot', """
            @alice Here's the oracle.
            - Alice = Kitchen 2
            - Bob = Kitchen 1
            - Carol = Entrance
            - Eve = Bathroom
          """ ]
        ]

    context 'hubot house-cleaning latest', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot house-cleaning rand'
          yield room.user.say 'alice', '@hubot house-cleaning latest'

      it 'adds the new location', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot house-cleaning rand']
          ['hubot', """
            @alice Here's the oracle.
            - Alice = Kitchen 2
            - Bob = Kitchen 1
            - Carol = Entrance
            - Eve = Bathroom
          """ ]
          ['alice', '@hubot house-cleaning latest']
          ['hubot', """
            @alice Here's the oracle.
            - Alice = Kitchen 2
            - Bob = Kitchen 1
            - Carol = Entrance
            - Eve = Bathroom
          """ ]
        ]

    context 'hubot 掃除当番教えて', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 掃除当番更新'
          yield room.user.say 'alice', '@hubot 掃除当番教えて'
          yield room.user.say 'alice', '@hubot 掃除当番どうだっけ？'
          yield room.user.say 'alice', '@hubot 私の掃除当番は何ですか'
          yield room.user.say 'alice', '@hubot あのう、掃除当番なんでしたっけ……'

      it 'adds the new location', ->
        oracle = """
          @alice Here's the oracle.
          - Alice = Kitchen 2
          - Bob = Kitchen 1
          - Carol = Entrance
          - Eve = Bathroom
        """
        expect(room.messages).to.eql [
          ['alice', '@hubot 掃除当番更新']
          ['hubot', oracle ]
          ['alice', '@hubot 掃除当番教えて']
          ['hubot', oracle ]
          ['alice', '@hubot 掃除当番どうだっけ？']
          ['hubot', oracle ]
          ['alice', '@hubot 私の掃除当番は何ですか']
          ['hubot', oracle ]
          ['alice', '@hubot あのう、掃除当番なんでしたっけ……']
          ['hubot', oracle ]
        ]
