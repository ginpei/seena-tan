Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect

PATH = './../scripts/reset_table.coffee'
ResetTable = require(PATH).ResetTable

describe 'ResetTable', ->
  room = null
  original_delay = null
  helper = new Helper(PATH)

  beforeEach ->
    original_delay = ResetTable.prototype.delay
    ResetTable.prototype.delay = 0
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    ResetTable.prototype.delay = original_delay

  context 'when finds a reversed table', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '┻┻'

    it 'resets the table', ->
      expect(room.messages).to.eql [
        ['alice', '┻┻']
        ['hubot', '┳┳ノ(°-°ノ )']
      ]

  context 'when someone reverses a table', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '(ノ ﾟДﾟ)ノ⌒┻┻'

    it 'resets the table', ->
      expect(room.messages).to.eql [
        ['alice', '(ノ ﾟДﾟ)ノ⌒┻┻']
        ['hubot', '┳┳ノ(°-°ノ )']
      ]

  context 'if a reversed table is broken', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '┻.┻'

    it 'does nothing', ->
      expect(room.messages).to.eql [
        ['alice', '┻.┻']
        # ignore
      ]
