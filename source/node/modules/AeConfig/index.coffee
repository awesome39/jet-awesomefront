{Module}= require 'di'

#
# Config Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class ConfigModule extends Module

    constructor: (config= {}, env= 'development') ->
        super



        #
        # Config Service
        #
        # @factory
        #
        @factory 'ConfigService', require './services/Config'



        #
        # Instance of Config Service
        #
        # @factory
        #
        @factory '$cfg', (ConfigService) ->

            new ConfigService config, env

        #
        # Instance of Config Service
        #
        # @factory
        #
        @factory 'cfg', ($cfg) ->

            $cfg



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector) ->

        injector.invoke (app, $cfg) ->

            app.set 'config', $cfg
