{Module}= require 'di'

module.exports= class AwesomeFront extends Module



    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        @factory 'AwesomeFrontApp', require './handlers'



        #
        # API
        #
        @factory 'AwesomeFrontApi', require './handlers/Api/V1'
        @factory 'AwesomeFrontSignupApi', require './handlers/Api/V1/Signup'



        #
        # Экземпляр приложения Awesome
        #
        @factory 'awesomeFront', (AwesomeFrontApp) ->
            new AwesomeFrontApp



        #
        # Экземпляр приложения Awesome API
        #
        # @version 1
        #
        @factory 'awesomeFrontApi', (AwesomeFrontApi) ->
            new AwesomeFrontApi



    init: (injector) ->

        injector.invoke (log) ->
            log 'INIT MODULE AwesomeFront'

        injector.invoke (app, App, $auth) ->
            #
            # Обработчик Awesome
            #
            app.use '/', injector.invoke (awesomeFront) ->
                awesomeFront



            #
            # Обработчик Awesome API
            #
            app.use '/api/v1', injector.invoke (awesomeFrontApi) ->
                awesomeFrontApi
