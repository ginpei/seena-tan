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

  @save: (data)->
    @brain.set(@KEY, JSON.stringify(data))

  @shuffle: ()->
    _.shuffle(@all())

module.exports = Brain
