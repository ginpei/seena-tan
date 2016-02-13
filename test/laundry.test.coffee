# https://amussey.github.io/2015/08/11/testing-hubot-scripts.html
PATH = './../scripts/laundry.coffee'

Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
moment = require('moment-timezone')
sinon = require('sinon')

LaundryManager = require(PATH).LaundryManager

describe 'LaundryManager', ->
  room = null
  helper = new Helper(PATH)

  beforeEach ->
    sinon.stub LaundryManager.prototype, 'now', ()-> moment.tz('2000-01-01T12:00:00', 'America/Vancouver').locale('ja')
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    LaundryManager.prototype.now.restore()

  context '開始', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'

      it 'お知らせ時刻を返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'
          yield room.user.say 'alice', '洗濯'

      it '前の利用者を気遣う', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['hubot', '（aliceは終わったのかな？）']
        ]

  context '確認', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯?'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯?']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'
          yield room.user.say 'alice', '洗濯?'

      it '使用者名を返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '洗濯?']
          ['hubot', '@alice aliceが使ってるよ。1時間後の1:11に終わるよ。']
        ]

    context '文言パターンの確認', ->
      patterns = [
        '洗濯?'
        '洗濯？'
        '誰か洗濯機誰か使ってる？'
        'だれか洗濯だれかつかってる？'
        '洗濯機つかってる？'
        '洗濯機使ってますか'
      ]

      beforeEach ->
        co ->
          yield room.user.say 'alice', patterns[0]
          yield room.user.say 'alice', patterns[1]
          yield room.user.say 'alice', patterns[2]
          yield room.user.say 'alice', patterns[3]
          yield room.user.say 'alice', patterns[4]
          yield room.user.say 'alice', patterns[5]

      it 'ちゃんと拾う', ->
        expect(room.messages).to.eql [
          ['alice', patterns[0]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
          ['alice', patterns[1]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
          ['alice', patterns[2]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
          ['alice', patterns[3]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
          ['alice', patterns[4]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
          ['alice', patterns[5]]
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

  context 'キャンセル', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯やめ'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯やめ']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

    context '自分が利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'
          yield room.user.say 'alice', '洗濯やめ'

      it 'キャンセルと返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '洗濯やめ']
          ['hubot', '@alice お知らせするのやめるよ。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'
          yield room.user.say 'bob', '洗濯やめ'

      it '利用者名とキャンセルする旨とを返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['bob', '洗濯やめ']
          ['hubot', '@bob aliceにお知らせするのやめるよ。']
        ]

    context 'キャンセル後', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '洗濯'
          yield room.user.say 'alice', '洗濯やめ'
          yield room.user.say 'alice', '洗濯?'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '洗濯やめ']
          ['hubot', '@alice お知らせするのやめるよ。']
          ['alice', '洗濯?']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]
