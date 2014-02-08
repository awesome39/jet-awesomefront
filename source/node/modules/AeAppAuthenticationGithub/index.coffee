{Module}= require 'di'
{Strategy}= require 'passport-github'

#
# App Authentication Github Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppAuthenticationGithubModule extends Module

    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        #
        # Account Github Model
        #
        # @factory
        #
        @factory 'AccountGithub', require './models/AccountGithub'



        #
        # App Authentication Github Handler
        #
        @factory 'AppAuthenticationGithub', require './handlers'



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector, app) ->

        injector.invoke ($auth, AccountGithub, cfg) ->

            $auth.use new Strategy

                clientID: cfg.auth.github.clientID
                clientSecret: cfg.auth.github.clientSecret

            ,   (accessToken, refreshToken, github, done) ->

                    done null, new AccountGithub
                        providerId: github.id
                        providerName: github.username

        app.use '/', injector.invoke (AppAuthenticationGithub) ->
            new AppAuthenticationGithub
