module.exports= (App, AwesomeFrontSignupApi, db, log) ->
    class AwesomeFrontApi extends App

        constructor: ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeFrontApp]'
            log 'construct...'



            app.use db.redis.middleware()
            app.use db.maria.middleware()



            app.use '/user', new AwesomeFrontSignupApi




            app.use (err, req, res, next) ->
                console.log "Error [#{err.name}]: #{err.message}"

                res.json
                    error: err.name
                    message: err.message
                ,   500



            return app
