# Description:
#   新春ドラマスペシャル・マグロ
#   テレビ朝日系列
#   前編 2007年1月4日 21:00 - 23:25（JST）
#   後編 2007年1月5日 21:00 - 23:25（JST）
#
# Dependencies:
#   None
#
# Configuration:
#   None
#

module.exports = (robot) ->
  robot.hear /まぐろ|マグロ|鮪|\bmaguro\b|\btuna\b/, (msg) ->

    urls = [
      'http://i.ytimg.com/vi/NCdObJJ9klA/maxresdefault.jpg'
      'http://blogs.c.yimg.jp/res/blog-61-e0/xl1200rgoidea/folder/472282/50/8578650/img_26?1363606034'
      'http://www.marea-yokohama.jp/blog/wp-content/uploads/2012/11/%E3%83%89%E3%83%A9%E3%83%9E-300x225.jpg'
      'http://tn-skr.smilevideo.jp/smile?i=9348808'
      'http://poohkohji.up.seesaa.net/090000001388033.jpg'
    ]

    if Math.random() > 1/10/urls.length
      index = Math.floor(Math.random() * ((urls.length - 1) + 1) );
      url = urls[index]
    else
      url = 'http://lohas.nicoseiga.jp/thumb/2326873i'

    msg.send 'ご期待ください\n' + url
