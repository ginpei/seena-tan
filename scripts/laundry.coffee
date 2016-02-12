# Description:
#   洗濯が終わったら連絡します。

require('moment-timezone')
moment = require('moment')

module.exports = (robot) ->
  rx_laundry = /^洗濯$/
  rx_driyer = /^乾燥$/

  robot.hear rx_laundry, (res) ->
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
