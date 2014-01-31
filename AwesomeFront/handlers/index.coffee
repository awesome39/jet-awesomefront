module.exports= (App, db, log) ->
    class AwesomeFrontApp extends App

        constructor: ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeFrontApp]'
            log 'construct...'



            app.get '/init', (req, res) ->
                res.render 'Manage/welcome/index.jade'



            return app
