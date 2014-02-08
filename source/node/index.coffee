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



    injector.invoke (app, App) ->

        app.use do App.compress

        app.use App.static "#{__dirname}/../pub/assets"

        app.set 'view engine', 'jade'

        app.enable 'strict routing'



        app
