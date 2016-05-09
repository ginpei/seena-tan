# Description:
#   Manage house cleaning.
#
# Commands:
#   hubot house-cleaning - Show usage.
#   hubot house-cleaning user - Show the user list.
#   hubot house-cleaning user add <name> - Add an user.
#   hubot house-cleaning user remove <name> - Remove an user.
#   hubot house-cleaning location - Show the location list.
#   hubot house-cleaning location add <name> - Add a location.
#   hubot house-cleaning location remove <name> - Remove a location.
#   hubot house-cleaning rand - Tell the new oracle.
#   hubot house-cleaning latest - Tell the last oracle again.
#   hubot 掃除当番更新して - 新しい神託を得る。
#   hubot 掃除当番教えて - 直近の神託を得る。

_ = require('underscore')

class Brain
  constructor: (attr)->
    @[key] = value for key, value of attr

  save: ()->
    constructor = @constructor
    all = constructor.all()
    all.push(@)
    constructor.save(all)

  @set_brain: (brain)->
    @brain = brain

  @all: ()->
    JSON.parse(@brain.get(@KEY) or '[]')

  @save: (users)->
    @brain.set(@KEY, JSON.stringify(users))

  @shuffle: ()->
    _.shuffle(@all())

class User extends Brain
  @KEY: 'HouseCleaning.User'

class Location extends Brain
  @KEY: 'HouseCleaning.Location'

class HouseCleaning
  @KEY_ORACLE: 'HouseCleaning.latest_oracle'
  @MSG_USAGE:
    """
    Usage
    Oracle: `cleaning rand`
    """

  start: (robot)->
    @brain = robot.brain

    robot.respond /house-cleaning$/, (res)=>
      @respond_on_usage(res)

    robot.respond /house-cleaning user$/, (res)=>
      @respond_on_user_list(res)

    robot.respond /house-cleaning user add (.*)$/, (res)=>
      attr =
        name: res.match[1]
      @respond_on_user_add(res, attr)

    robot.respond /house-cleaning location$/, (res)=>
      @respond_on_location_list(res)

    robot.respond /house-cleaning location add (.*)$/, (res)=>
      attr =
        name: res.match[1]
      @respond_on_location_add(res, attr)

    robot.respond /house-cleaning rand$/, (res)=>
      @respond_on_rand(res)

    robot.respond /house-cleaning latest$/, (res)=>
      @respond_on_rand(res)

    robot.respond /(?:.*)掃除当番.*更新/, (res)=>
      @respond_on_rand(res)

    robot.respond /(?:.*)掃除当番.*(?:教えて|だっけ|です|でした)/, (res)=>
      @respond_on_latest(res)

  make_user_list: ()->
    User.all()
      .map((user)->"- #{user.name}")
      .join('\n')

  make_location_list: ()->
    Location.all()
      .map((location)->"- #{location.name}")
      .join('\n')

  save_oracle: (content)->
    @brain.set(@constructor.KEY_ORACLE, content)

  load_oracle: ()->
    @brain.get(@constructor.KEY_ORACLE)

  respond_on_usage: (res)->
    res.reply @constructor.MSG_USAGE

  respond_on_user_list: (res)->
    message = "Users:\n#{@make_user_list()}"
    res.reply message

  respond_on_user_add: (res, attr)->
    user = new User(attr)
    user.save()
    message = "#{user.name} is successfully added.\n#{@make_user_list()}"
    res.reply message

  respond_on_usage: (res)->
    res.reply @constructor.MSG_USAGE

  respond_on_location_list: (res)->
    message = "Locations:\n#{@make_location_list()}"
    res.reply message

  respond_on_location_add: (res, attr)->
    location = new Location(attr)
    location.save()
    message = "#{location.name} is successfully added.\n#{@make_location_list()}"
    res.reply message

  respond_on_rand: (res)->
    users = User.all()
    locations = Location.shuffle()

    oracle = users
      .map((user, index)-> "- #{user.name} = #{locations[index].name}")
      .join('\n')

    @save_oracle(oracle)

    message = "Here's the oracle.\n#{oracle}"
    res.reply message

  respond_on_latest: (res)->
    oracle = @load_oracle()
    message = "Here's the oracle.\n#{oracle}"
    res.reply message

HouseCleaning.User = User
HouseCleaning.Location = Location

module.exports = (robot)->
  User.set_brain(robot.brain)
  Location.set_brain(robot.brain)
  house_cleaning = new HouseCleaning()
  house_cleaning.start(robot)

module.exports.HouseCleaning = HouseCleaning
