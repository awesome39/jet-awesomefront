module.exports= (App, Profile, Account, ProfilePermission, $audit, $authenticate, $authorize, db, log) ->
    class AwesomeFrontSignupApi extends App

        constructor: ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeFrontSignupApi]'
            log 'construct...'





            ###
            Регистрирует пользователя.
            ###
            app.post '/signup'
            ,   $audit('Sign up personal information')

            ,   db.maria.middleware.transaction()

            ,   AwesomeFrontSignupApi.createProfile()
            ,   AwesomeFrontSignupApi.createProfileEmails()
            ,   AwesomeFrontSignupApi.createProfilePhones()
            ,   AwesomeFrontSignupApi.createProfileAccount()
            ,   AwesomeFrontSignupApi.createProfilePermission()

            ,   db.maria.middleware.transaction.commit()

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'created profile resolved', profile
                                res.json 201, res.profile
                        ,   (err) ->
                                log 'created profile rejected', err
                                next err
                    catch err
                        next new AwesomeFrontSignupApiError



            ###
            Отдает указанного пользователя.
            ###
            app.get '/:userId(\\d+)'
            ,   $authenticate('user')
            ,   $authorize('profiles.select')
            ,   $audit('Get personal information')

            ,   AwesomeFrontSignupApi.getProfile('userId')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'selected profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'selected profile rejected', err
                                next err
                    catch err
                        next new AwesomeFrontSignupApiError



            ###
            Включает или выключает указанного пользователя.
            ###
            app.post '/:userId(\\d+)/enable'
            ,   $authenticate('user')
            ,   $authorize('profiles.enable')
            ,   $audit('Act personal information')

            ,   AwesomeFrontSignupApi.enableProfile('userId')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'enabled profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'enabled profile rejected', err
                                next err
                    catch err
                        next new AwesomeFrontSignupApiError



            ###
            Обрабатывает ошибки.
            ###
            app.use (err, req, res, next) =>
                if err instanceof AwesomeFrontSignupApiError
                    res.json
                        message: err.message
                    ,   500

                else
                    next err



            return app





        @getProfile: (param) -> (req, res, next) ->
            profileId= req.param param
            req.profile= Profile.getById profileId, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    next(err)



        @createProfile: -> (req, res, next) ->
            req.profile= Profile.create req.body, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    next(err)

        @createProfileEmails: -> (req, res, next) ->
            req.profile (profile) ->
                req.profile.emails= Profile.createEmails profile.id, req.body.emails or [], req.maria
                req.profile.emails (emails) ->
                        res.profile.emails= emails
                        next()
                ,   (err) ->
                        next(err)

        @createProfilePhones: -> (req, res, next) ->
            req.profile (profile) ->
                req.profile.phones= Profile.createPhones profile.id, req.body.phones or [], req.maria
                req.profile.phones (phones) ->
                        res.profile.phones= phones
                        next()
                ,   (err) ->
                        next(err)

        @createProfileAccount: -> (req, res, next) ->
            req.profile (profile) ->
                req.profile.account= Account.create profile.id, req.body, req.maria
                req.profile.account (account) ->
                        res.profile.account= account
                        next()
                ,   (err) ->
                        next(err)

        @createProfilePermission: -> (req, res, next) ->
            req.profile (profile) ->
                console.log 'PROFILE', profile.id
                req.profile.permission= ProfilePermission.createByName profile.id, 'profile.select', req.maria
                req.profile.permission (permission) ->
                        res.profile.permission= permission
                        next()
                ,   (err) ->
                        next(err)





        @enableProfile: (paramProfileId) -> (req, res, next) ->
            profileId= req.param paramProfileId
            req.profile= Profile.enable profileId, req.body.enabled, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    if err instanceof Profile.enable.BadValueError then res.status 400
                    if err instanceof Profile.enable.NotFoundError then res.status 404
                    next(err)







class AwesomeFrontSignupApiError extends Error

    constructor: (message= 'AwesomeFront Signup API Error') ->
        @message= message
