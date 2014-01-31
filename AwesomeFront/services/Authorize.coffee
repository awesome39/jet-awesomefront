module.exports= (log) -> class AuthorizeService

    constructor: () ->

        log= log.namespace '[AuthorizeService]'
        log 'Created.', do process.hrtime



        authorize= (role) ->
            log 'Created middleware.', do process.hrtime

            (req, res, next) ->

                req.profile (profile) ->
                        try
                            for permission in profile.permissions
                                continue if not permission.value
                                if ~role.search(new RegExp('^'+permission.name.replace('.','\\.')+'($|(\\.[a-z]+)+$)'))
                                    log 'ACCESS GRANTED with PERMISSION', permission
                                    return do next
                            log 'ACCESS DENIED', role, profile.permissions
                            return next Error 'Access denied.'
                        catch err
                            next err
                ,   (err) ->
                        next err



        @constructor.prototype.__proto__= authorize.__proto__
        authorize.__proto__= AuthorizeService.prototype

        return authorize

