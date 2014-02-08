module.exports= (App, Account, ProfileSession, $audit, $auth, $authenticate, $authorize, db, log) ->
    class ProfileApi extends App

        constructor: () ->
            app= super



            app.set 'log', log= log.namespace '[ProfileAPI]'



            app.use db.redis.middleware()

            app.use db.maria.middleware()



            ###
            Отдает манифест.
            ###
            app.head '/', (req, res) ->
                res.setHeader 'x-jet-api', 'Awesome Profile API'
                res.setHeader 'x-jet-api-version', 1
                do res.end



            ###
            Отдает аутентифицированного пользователя.
            ###
            app.get '/'
            ,   $authenticate('user')
            ,   $authorize('profile.select')
            ,   $audit('Get personal information')

            ,   (req, res, next) ->
                    try

                        req.profile (profile) ->
                                log 'profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'profile rejected', err
                                next err

                    catch err
                        next new ProfileApiError



            app.post '/login'
            ,   ProfileApi.authUser()
            ,   (req, res, next) ->
                    res.json req.account



            app.get '/logout'
            ,   (req, res, next) ->
                    req.logout()
                    res.send 200



            ###
            Обрабатывает ошибки.
            ###
            app.use (err, req, res, next) =>

                if err instanceof ProfileApiError

                    res.json
                        message: err.message

                    ,   500

                else

                    next err



            return app





        @authUser: () -> (req, res, next) ->
            handler= $auth.authenticate 'local', (err, account) ->
                if err
                    return res.json 500, err

                if not account
                    return res.json 400, account
                account= Account.auth account, req.maria
                account (account) ->
                    if not account
                        return res.json 400, account
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
            handler req, res, next


        ###
        @authUserGithub: () -> (req, res, next) ->
            handler= $auth.authenticate 'github', (err, account) ->
                account= AccountGithub.auth account, req.maria
                account (account) ->
                    if not account
                        res.json 400, account
                    else
                        req.login account, (err) ->
                            next err
            handler req, res, next
        ###


        @loadProfileSessions: (param) -> (req, res, next) ->
            profileId= req.param param

            req.profile= {}
            req.profile.sessions= ProfileSession.queryMaria profileId, req.query, req.maria
            req.profile.sessions (sessions) ->
                    res.sessions= sessions
                    next()
            ,   (err) ->
                    res.errors.push res.error= err
                    next(err)







class ProfileApiError extends Error

    constructor: (message= 'Awesome Profile API Error') ->
        @message= message
