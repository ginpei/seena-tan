# Description:
#   洗濯が終わったら連絡します。

moment = require('moment-timezone')

class Timer
  title: null

  rx_start: null
  rx_queue: null
  rx_stop: null

  current_user: null
  tm_finish: null
  finishes_at: null

  constructor: (options={})->
    @title = options.title
    @default_duration = options.duration

    @rx_start = new RegExp("(?:(\\d+)分間?)?(?:#{@title})(?:開始|(?:始|はじ)め(?:た|ました)?|する|します)?$")
    @rx_queue = new RegExp("(?:誰か|だれか)?(?:#{@title})(?:機|器)?(?:誰か|だれか)?(?:(?:使って|つかって|して)(?:る|ます|ますか))?(?:\\?|？|(?:使|つか)ってますか)$")
    @rx_stop = new RegExp("(?:#{@title})(?:やめ|やめる|やめた|キャンセル)$")

  start: (robot)->
    robot.respond @rx_start, (res)=>
      last = @update_current(res)

      @start_timer =>
        message = "そろそろ#{@title}が終わったんじゃないかな？"
        res.reply message
        @update_current(null)
      res.reply @make_start_message()

      if last.user
        res.send "（@#{last.user}の#{@title}は終わったのかな？）"

    robot.respond @rx_queue, (res)=>
      if @current_user
        time = @finishes_at.format('h:mm')
        duration = @finishes_at.from(@now())
        res.reply "#{@current_user}が使ってるよ。#{duration}の#{time}に終わるよ。"
      else
        res.reply '誰も使ってないと思うよ。'

    robot.respond @rx_stop, (res)=>
      if @current_user
        if @current_user is res.message.user.name
          message = "お知らせするのやめるよ。"
        else
          message = "#{@current_user}にお知らせするのやめるよ。"
        res.reply message
        @update_current(null)
      else
        res.reply '誰も使ってないと思うよ。'

  update_current: (res)->
    last =
      duration: @duration
      finishes_at: @finishes_at
      user: @current_user

    clearTimeout(@tm_finish)
    @tm_finish = null

    if res
      @duration = @getDuration(res)
      @finishes_at = @now().add(@duration)
      @current_user = res.message.user.name
    else
      @duration = null
      @finishes_at = null
      @current_user = null

    last

  getDuration: (res)->
    specified_minutes = res.match[1]
    if specified_minutes
      { minutes:specified_minutes }
    else
      @default_duration

  now: ()->
    moment.tz(process.env.TZ).locale('ja')

  start_timer: (callback)->
    @tm_finish = setTimeout(callback, moment.duration(@duration))

  make_start_message: (data)->
    time = @finishes_at.format('h:mm')
    "あいあいー。#{time}になったらお知らせします。"

module.exports = (robot) ->
  laundry_manager = new Timer(
    duration: { hours: 1, minutes: 11 }
    title: '洗濯'
  )
  laundry_manager.start(robot)

  drier_manager = new Timer(
    duration: { minutes: 60 }
    title: '乾燥'
  )
  drier_manager.start(robot)

  drier_manager = new Timer(
    title: '炊飯'
    duration: { minutes:60 }
  )
  drier_manager.start(robot)

module.exports.Timer = Timer
