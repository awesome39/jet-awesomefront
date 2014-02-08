{Module}= require 'di'

#
# App Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppModule extends Module

    constructor: (config= {}, env= 'development') ->
        super



        @config= @constructor.manifest.config or {}



        #
        # App Service
        #
        # @factory
        #
        @factory 'App', require './services/App'



        #
        # Instance of App Service
        #
        # @factory
        #
        @factory '$app', (App, log) ->

            new App

        #
        # Instance of App Service
        #
        # @factory
        #
        @factory 'app', ($app) ->

            $app



        #
        # Error
        #
        # @factory
        #
        @factory 'Error', () ->
            Error



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector) ->

        injector.invoke (app, log) ->

            app.set 'injector', injector
