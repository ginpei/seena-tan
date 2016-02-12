# Description:
#   洗濯が終わったら連絡します。

moment = require('moment')

module.exports = (robot) ->
  rxLaundry = /^洗濯$/
  rxDriyer = /^乾燥$/

  robot.hear rxLaundry, (res) ->
    user = res.message.user.name
    duration = { hours: 1, minutes: 11 }
    finishesAt = moment().add(duration)
    time = finishesAt.format('h:mm')

    message = "あいあいー。#{time}になったらお知らせします。"
    res.reply message

    setTimeout ->
      message = 'そろそろ終わったんじゃないかな？'
      res.reply message
    , moment.duration(duration)

  robot.hear rxDriyer, (res) ->
    user = res.message.user.name
    duration = { hours: 1, minutes: 11 }
    finishesAt = moment().add(duration)
    time = finishesAt.format('h:mm')

    message = "あいあいー。#{time}になったらお知らせします。"
    res.reply message

    setTimeout ->
      message = 'そろそろ終わったんじゃないかな？'
      res.reply message
    , moment.duration(duration)
