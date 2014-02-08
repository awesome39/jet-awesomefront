extend= require 'extend'

#
# Config Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class ConfigService

    constructor: (config= {}, env= 'development') ->



        log= log.namespace '[Config]'



        extend true, @, config.default or {}

        if config[env]
            extend true, @, config[env]
