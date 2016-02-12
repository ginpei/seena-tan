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

module.exports = (robot) ->
  laundry_manager = new LaundryManager()
  laundry_manager.hear(robot)

  rx_driyer = /^乾燥$/

  robot.hear rx_driyer, (res) ->
    user = res.message.user.name
    duration = { hours: 1, minutes: 11 }
    finishes_at = moment().tz('America/Vancouver').add(duration)
    time = finishes_at.format('h:mm')

    message = "あいあいー。#{time}になったらお知らせします。"
    res.reply message

    setTimeout ->
      message = 'そろそろ終わったんじゃないかな？'
      res.reply message
    , moment.duration(duration)
