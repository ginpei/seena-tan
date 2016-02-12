# Description:
#   洗濯が終わったら連絡します。

require('moment-timezone')
moment = require('moment')

module.exports = (robot) ->
  rx_laundry = /^洗濯$/
  rx_laundry_queue = /^洗濯(?:\?|？)$/
  laundry_user = null
  laundry_timer = null
  laundry_finishes_at = null
  rx_driyer = /^乾燥$/

  robot.hear rx_laundry, (res) ->
    duration = { hours: 1, minutes: 11 }
    laundry_finishes_at = moment().tz('America/Vancouver').add(duration)
    time = laundry_finishes_at.format('h:mm')

    message = "あいあいー。#{time}になったらお知らせします。"
    res.reply message

    laundry_user = res.message.user.name
    laundry_timer = setTimeout ->
      message = 'そろそろ終わったんじゃないかな？'
      res.reply message
    , moment.duration(duration)

  robot.hear rx_laundry_queue, (res) ->
    if laundry_user
      time = laundry_finishes_at.format('h:mm')
      duration = laundry_finishes_at.locale('ja').fromNow()
      res.reply "#{laundry_user}が使ってるよ。#{duration}の#{time}に終わるよ。"

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
