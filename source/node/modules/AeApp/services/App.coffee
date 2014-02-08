express= require 'express'

#
# App Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= () -> class AppService extends express

    constructor: () ->

        app= super
        @constructor.prototype.__proto__= app.__proto__
        app.__proto__= AppService.prototype

        return app
