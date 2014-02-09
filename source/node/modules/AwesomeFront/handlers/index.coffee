module.exports= (App, $authenticate, $authorize, $audit, $isAuthenticate, db, log) ->
    class AwesomeFrontApp extends App

        constructor: ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeFrontApp]'
            log 'construct...'



            app.use db.redis.middleware()
            app.use db.maria.middleware()



            app.get '/'
            ,   $authenticate('user')
            ,   $authorize('profile.select')
            ,   $audit('Get personal information for rendering')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'profile resolved', profile
                                res.locals.user= profile
                                res.render 'AwesomeFront/index'
                        ,   (err) ->
                                log 'profile rejected', err
                                next err

                    catch err
                        next err



            app.get '/my'
            ,   $isAuthenticate('/')





            return app
