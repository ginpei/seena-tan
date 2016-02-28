Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
sinon = require('sinon')
moment = require('moment-timezone')

PATH = './../scripts/dialogue.coffee'
Dialogue = require(PATH).Dialogue

describe 'Dialogue', ->
  room = null
  helper = new Helper(PATH)

  beforeEach ->
    # sinon.stub Dialogue.prototype, 'now', ()-> moment.tz('2000-12-01 12:00', process.env.TZ)
    room = helper.createRoom()
    room.robot.brain.set 'Dialogue.User', JSON.stringify([
      { id:'alice', name:'Alice Skywalker' }
    ])

  afterEach ->
    room.destroy()
    # Dialogue.prototype.now.restore()

  context 'hubot dialogue user', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot dialogue user'

    it 'shows the list of users', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot dialogue user']
        ['hubot', """
        - alice = Alice Skywalker
        """]
      ]

  context 'hubot dialogue user add <id> <name>', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot dialogue user add bob Bob Gibson'

    it 'adds the user', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot dialogue user add bob Bob Gibson']
        ['hubot', """
        - alice = Alice Skywalker
        - bob = Bob Gibson
        """]
      ]
