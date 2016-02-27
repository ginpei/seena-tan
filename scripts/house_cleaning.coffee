# Description:
#   Manage house cleaning.
#
# Commands:
#   hubot house-cleaning - Show usage.
#   hubot house-cleaning user - Show the user list.
#   hubot house-cleaning user add <name> - Add an user.
#   hubot house-cleaning user remove <name> - Remove an user.
#   hubot house-cleaning place - Show the place list.
#   hubot house-cleaning place add <name> - Add a place.
#   hubot house-cleaning place remove <name> - Remove a place.
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

class Place extends Brain
  @KEY: 'HouseCleaning.Place'

class HouseCleaning
  @MSG_USAGE:
    """
    Usage
    Oracle: `cleaning rand`
    """

  start: (robot)->
    robot.respond /house-cleaning$/, (res)=>
      @respond_on_usage(res)

    robot.respond /house-cleaning user$/, (res)=>
      @respond_on_user_list(res)

    robot.respond /house-cleaning user add (.*)$/, (res)=>
      attr =
        name: res.match[1]
      @respond_on_user_add(res, attr)

    robot.respond /house-cleaning place$/, (res)=>
      @respond_on_place_list(res)

    robot.respond /house-cleaning place add (.*)$/, (res)=>
      attr =
        name: res.match[1]
      @respond_on_place_add(res, attr)

    robot.respond /house-cleaning rand$/, (res)=>
      @respond_on_rand(res)

  make_user_list: ()->
    User.all()
      .map((user)->"- #{user.name}")
      .join('\n')

  make_place_list: ()->
    Place.all()
      .map((place)->"- #{place.name}")
      .join('\n')

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

  respond_on_place_list: (res)->
    message = "Places:\n#{@make_place_list()}"
    res.reply message

  respond_on_place_add: (res, attr)->
    place = new Place(attr)
    place.save()
    message = "#{place.name} is successfully added.\n#{@make_place_list()}"
    res.reply message

  respond_on_rand: (res)->
    users = User.all()
    places = Place.shuffle()

    message = 'Here\'s the oracle.\n' + users
      .map((user, index)-> "- #{user.name} = #{places[index].name}")
      .join('\n')

    res.reply message

HouseCleaning.User = User
HouseCleaning.Place = Place

module.exports = (robot)->
  User.set_brain(robot.brain)
  Place.set_brain(robot.brain)
  house_cleaning = new HouseCleaning()
  house_cleaning.start(robot)

module.exports.HouseCleaning = HouseCleaning
