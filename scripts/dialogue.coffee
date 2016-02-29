# Description:
#   Have a fun conversation with me!
#
# Commands:
#   hubot * - Talk.

Brain = require('../lib/Brain.coffee')

class User extends Brain
  @KEY: 'Dialogue.User'

class Dialogue
  @API_URL: 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'

  start: (robot)->
    @robot = robot

    robot.respond /(.*)/, (res)=>
      return if @is_matched_others(res)
      message = res.match[1]
      @respond_on_request(res, message)

    robot.respond /dialogue user$/, (res)=>
      @respond_on_user(res)

    robot.respond /dialogue user add (\w*) (.*)$/, (res)=>
      attr =
        id: res.match[1]
        name: res.match[2]
      @respond_on_user_add(res, attr)

  is_matched_others: (res)->
    message = res.match[0]
    robot = res.robot

    robot_name = robot.name
      .replace(/([-])/g, '\\$1')  # not sure if there are any other chars
    this_rx_str = "/^\\s*[@]?#{robot_name}[:,]?\\s*(?:(.*))/"

    matched = robot.listeners.some (listener)->
      rx = listener.regex
      rx.toString() isnt this_rx_str and rx.test(message)

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

  make_user_list: ()->
    test = User.all()
      .map((user)->"- #{user.id} = #{user.name}")
      .join('\n')

  respond_on_request: (res, message)->
    content = @make_content(res, message)
    @send_request res, content, (data)=>
      rx_bot_name = /桜子/g
      hubot_name = 'スェナたん'
      message = data.utt.replace(rx_bot_name, hubot_name)
      res.reply message
      @context = data.context

  make_content: (res, message)->
    content =
      utt: message
      content: @context
      nickname: @get_user_nickname(res.message.user.name)
      t: 20

  get_user_nickname: (id)->
    user = User.find_where(id:id?.toLowerCase())
    user?.name

  respond_on_user: (res)->
    message = @make_user_list()
    res.send(message)

  respond_on_user_add: (res, attr)->
    attr.id = attr.id.toLowerCase()
    user = new User(attr)
    user.save()

    message = @make_user_list()
    res.send(message)

module.exports = (robot)->
  User.set_brain(robot.brain)

  dialogue = new Dialogue()
  dialogue.start(robot)

module.exports.Dialogue = Dialogue
module.exports.Dialogue.User = User
