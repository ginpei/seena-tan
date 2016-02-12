# Description:
#   洗濯が終わったら連絡します。

require('moment-timezone')
moment = require('moment')

class LaundryManager
  rx_start: /^洗濯$/
  rx_queue: /^洗濯(?:\?|？)$/

  current_user: null
  tm_finish: null
  finishes_at: null

  defaults:
    duration: { hours: 1, minutes: 11 }

  hear: (robot)->
    robot.hear @rx_start, (res)=>
      last = @update_current(res)
      @start_timer ->
        message = 'そろそろ終わったんじゃないかな？'
        res.reply message
      res.reply @make_start_message()

    robot.hear @rx_queue, (res)=>
      if @current_user
        time = @finishes_at.format('h:mm')
        duration = @finishes_at.locale('ja').fromNow()
        res.reply "#{@current_user}が使ってるよ。#{duration}の#{time}に終わるよ。"
      else
        res.reply '誰も使ってないと思うよ。'

  update_current: (res)->
    @duration = @defaults.duration
    @finishes_at = moment().tz('America/Vancouver').add(@duration)
    @current_user = res.message.user.name

  start_timer: (callback)->
    @tm_finish = setTimeout(callback, moment.duration(@duration))

  make_start_message: (data)->
    time = @finishes_at.format('h:mm')
    "あいあいー。#{time}になったらお知らせします。"

class DrierManager extends LaundryManager
  rx_start: /^乾燥$/
  rx_queue: /^乾燥(?:\?|？)$/

module.exports = (robot) ->
  laundry_manager = new LaundryManager()
  laundry_manager.hear(robot)

  drier_manager = new DrierManager()
  drier_manager.hear(robot)
