# https://amussey.github.io/2015/08/11/testing-hubot-scripts.html
PATH = './../scripts/timer.coffee'

Helper = require('hubot-test-helper')
co = require('co')
expect = require('chai').expect
moment = require('moment-timezone')
sinon = require('sinon')

Timer = require(PATH).Timer

describe 'Timer', ->
  room = null
  helper = new Helper(PATH)

  beforeEach ->
    sinon.stub(Timer.prototype, 'now')
      .callsFake ()-> moment.tz('2000-01-01T12:00:00', process.env.TZ).locale('ja')
    room = helper.createRoom()

  afterEach ->
    room.destroy()
    Timer.prototype.now.restore()

  context '開始', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'alice', '@hubot 炊飯'

      it 'お知らせ時刻を返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '@hubot 炊飯']
          ['hubot', '@alice あいあいー。1:00になったらお知らせします。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'alice', '@hubot 洗濯'

      it '前の利用者を気遣う', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['hubot', '（@aliceの洗濯は終わったのかな？）']
        ]

    context '終了時刻の指定', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 10分間洗濯'
          yield room.user.say 'alice', '@hubot 12分乾燥'

      it '時刻を反映して設定', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 10分間洗濯']
          ['hubot', '@alice あいあいー。12:10になったらお知らせします。']
          ['alice', '@hubot 12分乾燥']
          ['hubot', '@alice あいあいー。12:12になったらお知らせします。']
        ]

    context '文言パターンの確認', ->
      patterns = [
        '@hubot 洗濯'
        '@hubot 洗濯開始'
        '@hubot 洗濯はじめ'
        '@hubot 洗濯はじめた'
        '@hubot 洗濯始めました'
      ]

      beforeEach ->
        co ->
          yield room.user.say 'alice', pattern for pattern in patterns

      it 'ちゃんと拾う', ->
        result = []
        for pattern, i in patterns
          result.push ['alice', pattern]
          result.push ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          result.push ['hubot', '（@aliceの洗濯は終わったのかな？）'] unless i is 0
        expect(room.messages).to.eql result

  context '確認', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯?'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯?']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'alice', '@hubot 洗濯?'

      it '使用者名を返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '@hubot 洗濯?']
          ['hubot', '@alice aliceが使ってるよ。1時間後の1:11に終わるよ。']
        ]

    context '文言パターンの確認', ->
      patterns = [
        '@hubot 洗濯?'
        '@hubot 洗濯？'
        '@hubot 誰か洗濯機誰か使ってる？'
        '@hubot だれか洗濯だれかつかってる？'
        '@hubot 洗濯機つかってる？'
        '@hubot 洗濯機使ってますか'
        '@hubot だれか炊飯してる？'
      ]

      beforeEach ->
        co ->
          yield room.user.say 'alice', pattern for pattern in patterns

      it 'ちゃんと拾う', ->
        result = []
        for pattern in patterns
          result.push ['alice', pattern]
          result.push ['hubot', '@alice 誰も使ってないと思うよ。']
        expect(room.messages).to.eql result

  context 'キャンセル', ->
    context '誰も利用中でない場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯やめ'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯やめ']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

    context '自分が利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'alice', '@hubot 洗濯やめ'

      it 'キャンセルと返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '@hubot 洗濯やめ']
          ['hubot', '@alice お知らせするのやめるよ。']
        ]

    context '誰か利用中である場合', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'bob', '@hubot 洗濯やめ'

      it '利用者名とキャンセルする旨とを返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['bob', '@hubot 洗濯やめ']
          ['hubot', '@bob aliceにお知らせするのやめるよ。']
        ]

    context 'キャンセル後', ->
      beforeEach ->
        co ->
          yield room.user.say 'alice', '@hubot 洗濯'
          yield room.user.say 'alice', '@hubot 洗濯やめ'
          yield room.user.say 'alice', '@hubot 洗濯?'

      it '誰もいないと返信', ->
        expect(room.messages).to.eql [
          ['alice', '@hubot 洗濯']
          ['hubot', '@alice あいあいー。1:11になったらお知らせします。']
          ['alice', '@hubot 洗濯やめ']
          ['hubot', '@alice お知らせするのやめるよ。']
          ['alice', '@hubot 洗濯?']
          ['hubot', '@alice 誰も使ってないと思うよ。']
        ]

  context '無関係な発言', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '洗濯'
        yield room.user.say 'alice', '@hubot 洗濯。'
        yield room.user.say 'alice', '@hubot あ、洗濯'

    it '無視する', ->
      expect(room.messages).to.eql [
        ['alice', '洗濯']
        ['alice', '@hubot 洗濯。']
        ['alice', '@hubot あ、洗濯']
      ]
