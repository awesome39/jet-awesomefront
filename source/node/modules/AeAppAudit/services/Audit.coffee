ware= require 'ware'

#
# Audit Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class AuditService

    constructor: () ->

        log= log.namespace '[AuditService]'
        log 'Created.', do process.hrtime



        audit= (something) ->
            log 'Created middleware.'

            (req, res, next) ->

                log 'Audit It!', something
                audit.ware.run something, (err, something) ->
                    log 'Audited:', something
                    do next



        audit.ware= do ware

        audit.use= ->

            audit.ware.use.apply audit.ware, arguments



        @constructor.prototype.__proto__= audit.__proto__
        audit.__proto__= AuditService.prototype

        return audit

