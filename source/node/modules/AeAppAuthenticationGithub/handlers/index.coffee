#
# Auth Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (App, $auth, AccountGithub, ProfileSession, db, log) ->
    class AppAuthenticationGithub extends App

        constructor: () ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeApp]'
            log 'construct...'



            ###
            Аутентифицирует пользователя с помощью Гитхаба.
            ###
            app.get '/auth/github'
            ,   $auth.authenticate('github')



            ###
            Аутентифицирует пользователя с Гитхаба.
            ###
            app.get '/auth/github/callback'
            ,   db.maria.middleware()
            ,   (req, res, next) ->

                    handler= $auth.authenticate 'github', (err, account, info) ->

                        account= AccountGithub.auth account, req.maria
                        account (account) ->
                                if not account
                                    return res.json 400, null

                                req.login account, (err) ->
                                    headers= JSON.stringify
                                        'referer': req.headers['referer']
                                        'user-agent': req.headers['user-agent']
                                        'accept': req.headers['accept']
                                        'accept-encoding': req.headers['accept-encoding']
                                        'accept-language': req.headers['accept-language']
                                    session= ProfileSession.insertMaria req.account.profileId, req.sessionID, req.ip, headers, req.maria
                                    session (session) ->
                                            res.redirect '/'
                                    ,   (err) ->
                                            do req.logout
                                            next err

                        ,   (err) ->
                                next err

                    handler req, res, next



            return app
