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
    room.robot.brain.set 'HouseCleaning.Place', JSON.stringify([
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

  context 'hubot house-cleaning place', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning place'

    it 'shows place names', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning place']
        ['hubot', """
          @alice Places:
          - Bathroom
          - Entrance
          - Kitchen 1
          - Kitchen 2
        """ ]
      ]

  context 'hubot house-cleaning place add <place-name>', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot house-cleaning place add Centre of the Earth'

    it 'adds the new place', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot house-cleaning place add Centre of the Earth']
        ['hubot', """
          @alice Centre of the Earth is successfully added.
          - Bathroom
          - Entrance
          - Kitchen 1
          - Kitchen 2
          - Centre of the Earth
        """ ]
      ]

  context 'oracle', ->
    beforeEach ->
      sinon.stub HouseCleaning.Place, 'shuffle', ()-> @all().reverse()

    afterEach ->
      HouseCleaning.Place.shuffle.restore()

    context 'hubot house-cleaning rand', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot house-cleaning rand'

      it 'adds the new place', ->
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

