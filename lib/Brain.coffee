_ = require('underscore')

class Brain
  constructor: (attr)->
    @[key] = value for key, value of attr

  save: ()->
    constructor = @constructor
    all = constructor.all()
    all.push(@)
    constructor.save(all)

  delete: ()->
    @constructor.delete(@)

  @set_brain: (brain)->
    @brain = brain

  @all: ()->
    JSON.parse(@brain.get(@KEY) or '[]')

  @find_where: (attr)->
    _.findWhere(@all(), attr)

  @save: (data)->
    @brain.set(@KEY, JSON.stringify(data))

  @delete: (item)->
    all = @all()
    index = @_indexOf(item)
    if index >= 0
      all.splice(index, 1)
      @save(all)

  @_indexOf: (target)->
    index = -1
    @all().find (item, i)=>
      if (Object.keys(target).every (key)=> target[key] is item[key])
        index = i
    index

  @shuffle: ()->
    _.shuffle(@all())

module.exports = Brain
