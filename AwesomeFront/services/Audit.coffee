ware= require 'ware'

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
            log 'Use', arguments
            audit.ware.use.apply audit.ware, arguments



        audit.sign= (something) ->

            return if not something



        @constructor.prototype.__proto__= audit.__proto__
        audit.__proto__= AuditService.prototype

        return audit

