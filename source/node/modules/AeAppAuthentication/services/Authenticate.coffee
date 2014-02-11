#
# Authenticate Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Profile, log) -> class AuthenticateService

    constructor: () ->

        log= log.namespace '[AuthenticateService]'



        authenticate= (who) ->
            log do process.hrtime, 'Created middleware.'

            (req, res, next) ->

                log 'Authenticate!'

                hrtime= do process.hrtime
                req.time=
                    start: (hrtime[0] * 1e9 + hrtime[1])


                if !who and !req.isAuthenticated()
                    next 'not authenticated'


                if req.isAuthenticated()
                    profileId= req.account.profileId
                    req.profile= Profile.getByIdFromRedis profileId, req.redis
                    req.profile (profile) ->

                            hrtime= do process.hrtime
                            req.time.end= (hrtime[0] * 1e9 + hrtime[1])
                            #log 'resoled from redis', profile.id, (req.time.end - req.time.start) / 1e6 , 'ms'

                            profile= null # КЕШ ВЫКЛЮЧЕН

                            if not profile
                                req.profile= Profile.getById profileId, req.maria
                                req.profile (profile) ->
                                        log 'resoled from maria', profile.id
                                        if not profile
                                            res.profile= profile
                                            req.user= res.profile # LEGACY
                                            next()
                                        else
                                            req.profile= Profile.cacheIntoRedis profile, req.redis
                                            req.profile (profile) ->
                                                    log 'cached profile resolved', profile.id
                                                    res.profile= profile
                                                    req.user= res.profile # LEGACY
                                                    next()
                                            ,   (err) ->
                                                    log 'cached profile rejected', err
                                                    res.profile= profile
                                                    req.user= res.profile # LEGACY
                                                    next()
                                ,   (err) ->
                                        next(err)
                            else
                                res.profile= profile
                                req.user= res.profile # LEGACY
                                next()
                    ,   (err) ->
                            next(err)
                else
                    req.profile= Profile.getByName 'anonymous', req.maria
                    req.profile (profile) ->
                            res.profile= profile
                            req.user= res.profile # LEGACY
                            next()
                    ,   (err) ->
                            next(err)



        return authenticate
