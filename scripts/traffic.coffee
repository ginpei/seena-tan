# Description:
#   get traffic
#
# Commands:
#   hubot traffic - Show current traffic information.
#   hubot 電車 - 交通情報を表示する。
#   hubot バス - 交通情報を表示する。
#   hubot 交通 - 交通情報を表示する。

translinkAlerts = require('translink-alerts')

class Trafic
  start: (robot)->
    robot.hear /(?:traffic|電車|バス|交通)/, (res)=>
      res.send 'えっとねー'
      @get_lines (lines)->
        if lines
          message =
            """
            こんな感じみたい。
            #{lines.join('\n')}
            """
        else
          message = 'ごめん、えらった。'
        res.reply message

  get_lines: (callback)->
    translinkAlerts (err, alerts)->
      if err
        console.error err.stack
        return callback(null)

      callback alerts.map (data)->
        if data.fine
          "✔ #{data.title}"
        else
          "✘ #{data.title} : [#{data.status}] #{data.detail}"

module.exports = (robot)->
  trafic = new Trafic()
  trafic.start(robot)
