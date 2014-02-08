maria= require 'mysql'

#
# Db Maria Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class MariaDbService

    constructor: (config) ->



        log= log.namespace '[DbMaria]'
        log 'Created.', do process.hrtime



        @pool= maria.createPool config

        @middleware= => (req, res, next) =>
            req.maria= null
            log 'maria...'
            @getConnection (err, conn) ->
                if not err
                    req.maria= conn
                    res.on 'finish', ->
                        if req.maria
                            log 'maria connection released...'
                            return do req.maria.release if not req.maria.transaction
                            if req.maria.transaction
                                req.maria.query 'ROLLBACK', (err) ->
                                    if not err
                                        log 'maria transaction closed with rollback.'
                                        req.maria.transaction= false
                                    else
                                        log 'maria transaction not closed with err:', err
                next err

        @middleware.transaction= -> (req, res, next) ->
            log 'maria transaction...'
            req.maria.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                return next err if err
                req.maria.query 'START TRANSACTION', (err) ->
                    log 'maria transaction.', err
                    if not err
                        req.maria.transaction= true
                    return next err

        @middleware.transaction.commit= -> (req, res, next) ->
            log 'maria transaction commit...'
            return do next if not req.maria.transaction
            req.maria.query 'COMMIT', (err) ->
                log 'maria transaction commit.'
                req.maria.transaction= false
                return next err

        @middleware.transaction.rollback= -> (req, res, next) ->
                log 'maria transaction commit...'
                return do next if not req.maria.transaction
                req.maria.query 'ROLLBACK', (err) ->
                    log 'maria transaction commit.'
                    req.maria.transaction= false
                    return next err



    getConnection: (done) ->

        @pool.getConnection done
