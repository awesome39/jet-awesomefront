redis= require 'redis'

#
# Db Maria Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class RedisDbService

    constructor: (config) ->



        log= log.namespace '[DbRedis]'



        @client= redis.createClient config.port, config.host, config.options

        @client.on 'connect', () ->
            log 'redis connected', arguments

        @client.on 'error', () ->
            log 'redis error', arguments



        @middleware= => (req, res, next) =>

            req.redis= @

            do next
