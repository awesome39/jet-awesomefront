color= require 'cli-color'

#
# Log Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= () -> class LogService

    constructor: (config= {}) ->



        log= console.log

        log.color= color

        log.namespace= (name) ->
            l= (args...) ->
                log log.color.magenta(name), args...
            l.color= log.color
            l



        return log
