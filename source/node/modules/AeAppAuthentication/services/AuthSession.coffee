RedisStore= require 'connect-redis'

#
# Auth Session Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (App, log) -> class AuthSessionService

    @Store= RedisStore App



    constructor: () ->

        log= log.namespace '[AuthSessionService]'
        log 'Created.', do process.hrtime

        @store= new @constructor.Store



    init: (options) ->
        log 'INIT', options
        App.session
            key: options.key
            secret: options.secret
            store: @store
