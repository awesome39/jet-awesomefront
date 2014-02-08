{Module}= require 'di'

#
# Log Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class LogModule extends Module

    constructor: ->
        super



        #
        # Log Service
        #
        # @factory
        #
        @factory 'LogService', require './services/Log'



        #
        # Instance of Log Service
        #
        # @factory
        #
        @factory '$log', (LogService) ->

            new LogService

        #
        # Instance of Log Service
        #
        # @factory
        #
        @factory 'log', ($log) ->

            $log



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector) ->

        injector.invoke (app, $cfg) ->

            app.set 'log', $cfg
