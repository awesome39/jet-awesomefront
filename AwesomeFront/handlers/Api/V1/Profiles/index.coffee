module.exports= (App, Profile, $audit, $authenticate, $authorize, db, log) ->
    class AwesomeProfilesApi extends App

        constructor: () ->
            app= super



            app.set 'log', log= log.namespace '[AwesomeProfilesApi]'
            log 'construct...'



            ###
            Отдает манифест.
            ###
            app.head '/', (req, res) ->
                res.setHeader 'x-jet-api', 'Awesome Profiles API'
                res.setHeader 'x-jet-api-version', 1
                do res.end



            ###
            Отдает список пользователей.
            ###
            app.get '/'
            ,   $authenticate('user')
            ,   $authorize('profiles.select')
            ,   $audit('Get personal information')

            ,   AwesomeProfilesApi.queryProfile()

            ,   (req, res, next) =>
                    try
                        req.profiles (profiles) ->
                                log 'profiles resolved', profiles
                                res.json profiles
                        ,   (err) ->
                                log 'profiles rejected', err
                                next err
                    catch err
                        next new AwesomeProfilesApiError



            ###
            Добавляет пользователя.
            ###
            app.post '/'
            ,   $authenticate('user')
            ,   $authorize('profiles.insert')
            ,   $audit('Add personal information')

            ,   db.maria.middleware.transaction()

            ,   AwesomeProfilesApi.createProfile()
            ,   AwesomeProfilesApi.createProfileEmails()
            ,   AwesomeProfilesApi.createProfilePhones()

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
                        next new AwesomeProfilesApiError



            ###
            Отдает указанного пользователя.
            ###
            app.get '/:userId(\\d+)'
            ,   $authenticate('user')
            ,   $authorize('profiles.select')
            ,   $audit('Get personal information')

            ,   AwesomeProfilesApi.getProfile('userId')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'selected profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'selected profile rejected', err
                                next err
                    catch err
                        next new AwesomeProfilesApiError


            ###
            Обновляет указанного пользователя.
            ###
            app.post '/:userId(\\d+)'
            ,   $authenticate('user')
            ,   $authorize('profiles.update')
            ,   $audit('Upd personal information')

            ,   db.maria.middleware.transaction()

            ,   AwesomeProfilesApi.updateProfile('userId')
            ,   AwesomeProfilesApi.updateProfileEmails()
            ,   AwesomeProfilesApi.updateProfilePhones()

            ,   db.maria.middleware.transaction.commit()

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'updated profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'updated profile rejected', err
                                next err
                    catch err
                        next new AwesomeProfilesApiError


            ###
            Удаляет указанного пользователя.
            ###
            app.delete '/:userId(\\d+)'
            ,   $authenticate('user')
            ,   $authorize('profiles.delete')
            ,   $audit('Del personal information')

            ,   AwesomeProfilesApi.deleteProfile('userId')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'deleted profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'deleted profile rejected', err
                                next err
                    catch err
                        next new AwesomeProfilesApiError


            ###
            Включает или выключает указанного пользователя.
            ###
            app.post '/:userId(\\d+)/enable'
            ,   $authenticate('user')
            ,   $authorize('profiles.enable')
            ,   $audit('Act personal information')

            ,   AwesomeProfilesApi.enableProfile('userId')

            ,   (req, res, next) ->
                    try
                        req.profile (profile) ->
                                log 'enabled profile resolved', profile
                                res.json profile
                        ,   (err) ->
                                log 'enabled profile rejected', err
                                next err
                    catch err
                        next new AwesomeProfilesApiError



            ###
            Обрабатывает ошибки.
            ###
            app.use (err, req, res, next) =>

                if err instanceof AwesomeProfilesApiError

                    res.json
                        message: err.message

                    ,   500

                else

                    next err



            return app





        @queryProfile: () -> (req, res, next) ->
            query= req.query
            req.profiles= Profile.query query, req.maria
            req.profiles (profiles) ->
                    res.profiles= profiles
                    next()
            ,   (err) ->
                    next(err)



        @getProfile: (param) -> (req, res, next) ->
            profileId= req.param param
            req.profile= Profile.getById profileId, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    next(err)



        @createProfile: () -> (req, res, next) ->
            req.profile= Profile.create req.body, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    next(err)

        @createProfileEmails: () -> (req, res, next) ->
            req.profile (profile) ->
                req.profile.emails= Profile.createEmails profile.id, req.body.emails or [], req.maria
                req.profile.emails (emails) ->
                        res.profile.emails= emails
                        next()
                ,   (err) ->
                        next(err)

        @createProfilePhones: () -> (req, res, next) ->
            req.profile (profile) ->
                req.profile.phones= Profile.createPhones profile.id, req.body.phones or [], req.maria
                req.profile.phones (phones) ->
                        res.profile.phones= phones
                        next()
                ,   (err) ->
                        next(err)



        @updateProfile: (paramProfileId) -> (req, res, next) ->
            profileId= req.param paramProfileId
            req.profile= Profile.update profileId, req.body, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    next(err)

        @updateProfileEmails: () -> (req, res, next) ->
            req.profile (profile) ->
                    req.profile.emails= Profile.updateEmails profile, req.body.emails or [], req.maria
                    req.profile.emails (emails) ->
                            profile.emails= emails
                            next()
                    ,   (err) ->
                            next(err)

        @updateProfilePhones: () -> (req, res, next) ->
            req.profile (profile) ->
                    req.profile.phones= Profile.updatePhones profile, req.body.phones or [], req.maria
                    req.profile.phones (phones) ->
                            profile.phones= phones
                            next()
                    ,   (err) ->
                            next(err)



        @deleteProfile: (paramProfileId) -> (req, res, next) ->
            profileId= req.param paramProfileId
            req.profile= Profile.delete profileId, req.maria
            req.profile (profile) ->
                    res.profile= profile
                    next()
            ,   (err) ->
                    if err instanceof Profile.delete.BadValueError then res.status 400
                    if err instanceof Profile.delete.NotFoundError then res.status 404
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







class AwesomeProfilesApiError extends Error

    constructor: (message= 'Awesome Profiles API Error') ->
        @message= message
