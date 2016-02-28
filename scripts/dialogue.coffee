# Description:
#   Have a fun conversation with me!
#
# Commands:
#   hubot * - Talk.

_ = require('underscore')

class Dialogue
  @API_URL: 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'

  start: (robot)->
    robot.respond /(.*)/, (res)=>
      message = res.match[1]
      @respond_on_request(res, message)

  respond_on_request: (res, message)->
    content =
      utt: message
      content: @context
      # nickname: ''
      # nickname_y: ''
      t: 20

    @send_request res, content, (data)=>
      res.reply data.utt
      @context = data.context

  send_request: (res, content, callback)->
    res.http(@constructor.API_URL)
      .query(APIKEY: process.env.HUBOT_DOCOMO_DIALOGUE_API_KEY)
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(content)) (err, _, body) ->
        if err
          console.error '[dialogue.coffee]', err
          callback(utt:'あ、ごめんなんかえらった')
        else
          data = JSON.parse(body)
          callback(data)

module.exports = (robot)->
  dialogue = new Dialogue()
  dialogue.start(robot)

module.exports.Dialogue = Dialogue
