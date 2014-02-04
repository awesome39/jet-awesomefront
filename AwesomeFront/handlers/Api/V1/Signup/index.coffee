module.exports= (App, Profile, Account, ProfilePermission, ProfileEmailVerification, $audit, $authenticate, $authorize, db, log) ->
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
            ,   AwesomeFrontSignupApi.createEmailVerifyToken()

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
            Включает или выключает указанного пользователя.
            ###
            app.post '/:token/enable'
            ,   $audit('Verifying up personal information')

            ,   db.maria.middleware.transaction()

            ,   AwesomeFrontSignupApi.getToken('token')
            ,   AwesomeFrontSignupApi.enableProfileEmail()
            ,   AwesomeFrontSignupApi.deleteToken()

            ,   db.maria.middleware.transaction.commit()

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
            data= req.body
            data.enabledAt= new Date
            req.profile= Profile.create data, req.maria
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
                req.profile.permission= ProfilePermission.createByName profile.id, 'profile.select', req.maria
                req.profile.permission (permission) ->
                        res.profile.permission= permission
                        next()
                ,   (err) ->
                        next(err)

        @createEmailVerifyToken: -> (req, res, next) ->
            req.profile (profile) ->
                emailId= profile.emails.pop().id
                req.profile.token= ProfileEmailVerification.create emailId, req.maria
                req.profile.token (token) ->
                        res.profile.token= token
                        next()
                ,   (err) ->
                        next(err)





        @getToken: (param) -> (req, res, next) ->
            tokenString= req.param param
            req.token= ProfileEmailVerification.getByToken tokenString, req.maria
            req.token (token) ->
                    res.token= token
                    next()
            ,   (err) ->
                    if err instanceof ProfileEmailVerification.getByToken.BadValueError then res.status 400
                    if err instanceof ProfileEmailVerification.getByToken.NotFoundError then res.status 404
                next(err)

        @enableProfile: -> (req, res, next) ->
            profileId= req.token.profileId
            req.profile= Profile.enable profileId, 1, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    if err instanceof Profile.enable.BadValueError then res.status 400
                    if err instanceof Profile.enable.NotFoundError then res.status 404
                    next(err)

        @enableProfileEmail: -> (req, res, next) ->
            emailId= req.token.emailId
            req.profile (profile) ->
                req.profile.email= Profile.enableEmail emailId, 1, req.maria
                req.profile.email (email) ->
                    res.profile.email= email
                    next()
                ,   (err) ->
                    next(err)

        @enableProfileAccount: -> (req, res, next) ->
            profileId= req.token.profileId
            req.profile.account= Account.enableByProfileId profileId, 1, req.maria
            req.profile.account (account) ->
                    res.account= account
                    next()
            ,   (err) ->
                    if err instanceof Account.enableByProfileId.BadValueError then res.status 400
                    if err instanceof Account.enableByProfileId.NotFoundError then res.status 404
                    next(err)

        @enablePermission: -> (req, res, next) ->
            profileId= req.param param
            req.profile.permission= Profile.enable profileId, req.body, req.maria
            req.profile.permission (permission) ->
                res.profile.permission= permission
                next()
            ,   (err) ->
                if err instanceof Profile.enable.BadValueError then res.status 400
                if err instanceof Profile.enable.NotFoundError then res.status 404
                next(err)

        @deleteToken: -> (req, res, next) ->
            req.token= ProfileEmailVerification req.token.id, req.maria
            req.token (token) ->
                res.token= token
                next()
            ,   (err) ->
                    if err instanceof ProfileEmailVerification.BadValueError then res.status 400
                    if err instanceof ProfileEmailVerification.NotFoundError then res.status 404
                    next(err)





class AwesomeFrontSignupApiError extends Error

    constructor: (message= 'AwesomeFront Signup API Error') ->
        @message= message
