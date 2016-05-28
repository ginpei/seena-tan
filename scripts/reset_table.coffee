# Description:
#   Reset the table when finds a reversed table.
#   https://twitter.com/mipearson/status/735306904642199552

class ResetTable
  delay: 3000

  start: (robot)->
    @robot = robot

    robot.hear /┻┻/, (res)=>
      if @delay
        setTimeout ()=>
          @reset(res)
        , @delay
      else
        @reset(res)

  reset: (res)->
    message = '┳┳ノ(°-°ノ )'
    res.send(message)

module.exports = (robot)->
  reset_table = new ResetTable()
  reset_table.start(robot)

module.exports.ResetTable = ResetTable
