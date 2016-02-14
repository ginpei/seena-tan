# Description:
#   洗濯が終わったら連絡します。

moment = require('moment-timezone')

class LaundryManager
  machine_name: null

  rx_start: null
  rx_queue: null
  rx_stop: null

  current_user: null
  tm_finish: null
  finishes_at: null

  defaults:
    duration: { hours: 1, minutes: 11 }

  constructor: (options={})->
    @machine_name = options.machine_name

    @rx_start = new RegExp("^(#{@machine_name})(?:開始|(?:始|はじ)め(?:た|ました)?)?$")
    @rx_queue = new RegExp("^(?:誰か|だれか)?(#{@machine_name})(?:機)?(?:誰か|だれか)?(?:(?:使って|つかって)(?:る|ます|ますか))?(?:\\?|？|(?:使|つか)ってますか)$")
    @rx_stop = new RegExp("^(#{@machine_name})(?:やめ|やめる|やめた|キャンセル)$")

  hear: (robot)->
    robot.hear @rx_start, (res)=>
      last = @update_current(res)

      @start_timer =>
        message = 'そろそろ終わったんじゃないかな？'
        res.reply message
        @update_current(null)
      res.reply @make_start_message()

      if last.user
        res.send "（#{last.user}は終わったのかな？）"

    robot.hear @rx_queue, (res)=>
      if @current_user
        time = @finishes_at.format('h:mm')
        duration = @finishes_at.from(@now())
        res.reply "#{@current_user}が使ってるよ。#{duration}の#{time}に終わるよ。"
      else
        res.reply '誰も使ってないと思うよ。'

    robot.hear @rx_stop, (res)=>
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
      @duration = @defaults.duration
      @finishes_at = @now().add(@duration)
      @current_user = res.message.user.name
    else
      @duration = null
      @finishes_at = null
      @current_user = null

    last

  now: ()->
    moment.tz('America/Vancouver').locale('ja')

  start_timer: (callback)->
    @tm_finish = setTimeout(callback, moment.duration(@duration))

  make_start_message: (data)->
    time = @finishes_at.format('h:mm')
    "あいあいー。#{time}になったらお知らせします。"

module.exports = (robot) ->
  laundry_manager = new LaundryManager(machine_name:'洗濯')
  laundry_manager.hear(robot)

  drier_manager = new LaundryManager(machine_name:'乾燥')
  drier_manager.hear(robot)

module.exports.LaundryManager = LaundryManager
