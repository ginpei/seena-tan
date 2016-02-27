# Description:
#   Manage events.
#
# Commands:
#   hubot event - Show usage
#   hubot event list - Show the event list
#   hubot event add <starts_at> <name> - Add an event. <starts_at> should be `MM-DD HH:mm` like `01-02 03:04` for Jan 2.

_ = require('underscore')
moment = require('moment-timezone')
TZ = process.env.TZ

class EventManager
  @MSG_USAGE:
    """
    Usage
    list: `event list`
    add: `event add 12-31 10:30 Meet up`
    remove: `event remove 12-31 10:30 Meet up`
    """

  start: (robot)->
    @brain = robot.brain

    robot.respond /event$/, (res)=>
      @respond_on_usage(res)

    robot.respond /event list$/, (res)=>
      @respond_on_list(res)

    robot.respond /event add (\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}) (.*)/, (res)=>
      [none, datetime, name] = res.match
      @respond_on_add(res, { datetime, name })

    robot.respond /event remove (\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}) (.*)/, (res)=>
      [none, datetime, name] = res.match
      date = @parse_time(datetime)
      @respond_on_remove(res, { date, name })

  # @param {String} event.name
  # @param {Moment} event.date
  add_event: (event)->
    throw '`name` is required.' unless event.name
    throw '`date` is required.' unless event.date
    throw '`date` has to be Moment.' unless event.date instanceof moment

    events = @get_current_events()
    events.push(event)
    events = events.sort (e1, e2)->
      if e1.date < e2.date
        -1
      else if e1.date > e2.date
        +1
      else
        0

    json = JSON.stringify(events)
    @brain.set('event_manager.events', json)

  get_event: (condition)->
    event = _.find @get_current_events(), (candidate)->
      candidate.name is condition.name and candidate.date.isSame(condition.date)

  remove_event: (condition)->
    old_events = @get_current_events()
    new_events = _.reject old_events, (candidate)->
      candidate.name is condition.name and candidate.date.isSame(condition.date)

    json = JSON.stringify(new_events)
    @brain.set('event_manager.events', json)

  get_current_events: ()->
    events = JSON.parse(@brain.get('event_manager.events') or '[]')
      .map (e)-> e.date = moment.tz(e.date, TZ); e

  make_list_message: (events)->
    events
      .map((event)-> "#{moment.tz(event.date, TZ).format('MM-DD dd HH:mm')} #{event.name}")
      .join('\n')

  # @param {Strng} text `MM-DD HH:mm`
  # @returns {Moment}
  parse_time: (source)->
    now = @now()
    time = moment.tz("#{now.format('YYYY')}-#{source}", 'YYYY-M-D H:m', TZ)

    if time < now
      time.add({ year:1 })

    return time

  now: ()->
    moment.tz(TZ)

  respond_on_usage: (res)->
    res.reply EventManager.MSG_USAGE

  respond_on_list: (res)->
    events = @get_current_events()
    message = "Events:\n#{@make_list_message(events)}"
    res.reply message

  respond_on_add: (res, data)->
    date = @parse_time(data.datetime)

    if date.isValid()
      event =
        date: date
        name: data.name

      if @get_event(event)
        events = @get_current_events()
        list = @make_list_message(events)
        res.reply "#{data.name} is already registered at the same time.\n#{list}"

      else
        @add_event(event)

        events = @get_current_events()
        list = @make_list_message(events)
        res.reply "#{data.name} is successfully registered.\n#{list}"

    else
      res.reply 'It looks invalid date and/or time! Date has to be like: "1-1 0:0" or "12-31 23:59".'

  respond_on_remove: (res, data)->
    event = @get_event(date: data.date, name: data.name)
    if event
      @remove_event(event)
      res.reply "#{event.name} is successfully removed."
    else
      res.reply 'Sorry, the event you specified is not found.'

module.exports = (robot)->
  event_manager = new EventManager()
  event_manager.start(robot)

module.exports.EventManager = EventManager
