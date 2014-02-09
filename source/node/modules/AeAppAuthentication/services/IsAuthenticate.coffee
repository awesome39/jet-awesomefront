#app
# Authenticate Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class IsAuthenticateService

    constructor: ->

        log= log.namespace '[IsAuthenticateService]'



        check= (there) ->
            log do process.hrtime, 'Created middleware.'

            (req, res, next) ->
                log 'Authenticate!'


                if req.isAuthenticated()
                    do next
                else
                    res.redirect there


        return check
