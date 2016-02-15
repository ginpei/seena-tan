CronJob = require('cron').CronJob

class Morning
  start: (robot)->
    job = new CronJob(
      cronTime: "00 15 * * * *"
      onTick: =>
        robot.messageRoom 'seena_tan', '時報テスト'
      start: true
      timeZone: 'America/Vancouver'
    )

module.exports = (robot) ->
  # morning = new Morning()
  # morning.start(robot)

module.exports.Morning = Morning
