module.exports= (App, $audit, $authenticate, $authorize, db, log) ->
    class AwesomePermissionsApi extends App

        constructor: () ->
            app= super



            app.set 'log', log= log.namespace '[AwesomePermissionsApi]'
            log 'construct...'



            ###
            Отдает манифест.
            ###
            app.head '/', (req, res) ->
                res.setHeader 'x-jet-api', 'Awesome Permissions API'
                res.setHeader 'x-jet-api-version', 1
                do res.end



            ###
            Отдает список разрешений.
            ###
            #app.get '/'
            #,   $authenticate('user')
            #,   $authorize('permissions.select')
            #,   $audit('Get permissions')
            #
            #,   AwesomePermissionsApi.queryPermission()
            #
            #,   (req, res, next) ->
            #        try
            #            req.permissions (permissions) ->
            #                    log 'permissions resolved', permissions
            #                    res.json permissions
            #            ,   (err) ->
            #                    log 'permissions rejected', err
            #                    next err
            #        catch err
            #            next new AwesomePermissionsApiError



            ###
            Обрабатывает ошибки.
            ###
            app.use (err, req, res, next) =>

                if err instanceof AwesomePermissionsApiError

                    res.json
                        message: err.message

                    ,   500

                else

                    next err



            return app







class AwesomePermissionsApiError extends Error

    constructor: (message= 'Awesome Permissions API Error') ->
        @message= message
