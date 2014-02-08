di= require 'di'
modules= require './modules/modules'



###
Возвращает настроенный экзмепляр приложения.
###
module.exports= (manifest, env) ->
    cfg= manifest.config



    enabled= []
    for mod in modules.enabled
        Mod= require "./modules/#{mod}"
        Mod.manifest= require "./modules/#{mod}/package"

        enabled.push new Mod manifest.config, env

    injector= new di.Injector enabled

    for mod in enabled
        if mod.init
            injector.invoke mod.init, mod



    injector.invoke (app, App, log) ->

        app.use do App.compress



        app.use App.static "#{__dirname}/../pub/assets"



        #app.set 'views', "#{__dirname}/views"
        app.set 'view engine', 'jade'



        app.enable 'strict routing'


        ###
        app.get '/', (req, res, next) ->
            if do req.isAuthenticated
                res.redirect '/engine/'
            else
                res.redirect '/welcome/'

        app.get '/welcome', (req, res) -> res.redirect '/welcome/'



        app.get '/project', (req, res) -> res.redirect '/project/'
        app.get '/project/', (req, res, next) ->
            if do req.isAuthenticated
                do next
            else
                res.redirect '/welcome/'



        app.get '/engine', (req, res) -> res.redirect '/engine/'
        app.get '/engine/', (req, res, next) ->
            if do req.isAuthenticated
                do next
            else
                res.redirect '/welcome/'



        app.use App.static "#{__dirname}/../pub/templates/Manage"
        ###


        app
