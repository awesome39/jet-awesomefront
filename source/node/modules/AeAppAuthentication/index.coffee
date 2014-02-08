{Module}= require 'di'

#
# App Authentication Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppAuthenticationModule extends Module

    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        #
        # Account Model
        #
        # @factory
        #
        @factory 'Account', require './models/Account'



        #
        # Group Model
        #
        # @factory
        #
        @factory 'Group', require './models/Group'



        #
        # Profile Model
        #
        # @factory
        #
        @factory 'Profile', require './models/Profile'

        #
        # Profile Group Model
        #
        # @factory
        #
        @factory 'ProfileGroup', require './models/ProfileGroup'

        #
        # Profile Session Model
        #
        # @factory
        #
        @factory 'ProfileSession', require './models/ProfileSession'



        #
        # Auth Service
        #
        # @factory
        #
        @factory 'Auth', require './services/Auth'

        #
        # Instance of Auth Service
        #
        # @factory
        #
        @factory '$auth', (Auth, $session) ->
            $auth= new Auth config

            $auth.$session= $session

            $auth



        #
        # Auth Session Service
        #
        # @factory
        #
        @factory 'AuthSession', require './services/AuthSession'

        #
        # Instance of Auth Session Service
        #
        # @factory
        #
        @factory '$session', (AuthSession) ->
            new AuthSession



        #
        # Authenticate Service
        #
        # @factory
        #
        @factory 'Authenticate', require './services/Authenticate'

        #
        # Instance of Authenticate
        #
        # @factory
        #
        @factory '$authenticate', (Authenticate) ->
            new Authenticate config



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector) ->

        injector.invoke (log) ->
            log 'INIT MODULE'

        injector.invoke (app, App, $auth) ->

            app.use do App.cookieParser
            app.use do App.json

            app.use $auth.$session.init
                key:'manage.sid', secret:'user'

            app.use do $auth.init
            app.use do $auth.sess
