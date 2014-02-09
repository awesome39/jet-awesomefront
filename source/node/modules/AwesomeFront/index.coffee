{Module}= require 'di'

module.exports= class AwesomeFront extends Module



    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        @factory 'ProfileEmailVerification', require './models/ProfileEmailVerification'



        @factory 'AwesomeFrontApp', require './handlers'

        @factory 'AwesomeFrontApi', require './handlers/Api/V1'
        @factory 'AwesomeFrontSignupApi', require './handlers/Api/V1/Signup'



        @factory 'awesomeFront', (AwesomeFrontApp) ->
            new AwesomeFrontApp



        @factory 'awesomeFrontApi', (AwesomeFrontApi) ->
            new AwesomeFrontApi



    init: (injector) ->

        injector.invoke (log) ->
            log 'INIT MODULE AwesomeFront'

        injector.invoke (app, App) ->
            #
            # Обработчик Awesome
            #
            app.use '/', injector.invoke (awesomeFront) ->
                awesomeFront

            app.use App.static "#{__dirname}/../../../pub/templates/AwesomeFront"



            #
            # Обработчик Awesome API
            #
            app.use '/api/v1', injector.invoke (awesomeFrontApi) ->
                awesomeFrontApi
