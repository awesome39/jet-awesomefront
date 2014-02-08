deferred= require 'deferred'

#
# Profile Session Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class ProfileSession

    @table: 'profile_session'



    constructor: (data) ->

        @ip= data.ip
        @headers= data.headers

        @sessionId= data.sessionId

        @createdAt= data.createdAt
        @expiredAt= data.expiredAt



    @queryRedis: (profileId, query, db) ->

    @queryMaria: (profileId, query, db) ->
        log 'ProfileSession#queryMaria', profileId, query

        dfd= do deferred
        process.nextTick =>
            try

                if not profileId
                    throw new Error 'profileId cannot be null'

                db.query """
                    SELECT

                        ProfileSession.*

                      FROM ?? AS ProfileSession

                     WHERE
                        ProfileSession.profileId= ?
                    """
                ,   [@table, profileId]
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        sessions= []
                        if rows.length
                            for row in rows
                                sessions.push new @ row
                        dfd.resolve sessions

            catch
                dfd.reject err

        dfd.promise



    @insertMaria: (profileId, sessionId, ip, headers, maria) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not profileId
                    throw new Error 'profileId cannot be null'

                if not sessionId
                    throw new Error 'sessionId cannot be null'


                maria.query """
                    INSERT
                      INTO ??

                       SET
                        profileId= ?,
                        sessionId= ?,
                        ip= ?,
                        headers= ?

                    ON DUPLICATE KEY
                    UPDATE

                        profileId= ?,
                        sessionId= ?,
                        ip= ?,
                        headers= ?
                    """
                ,   [@table, profileId, sessionId, ip, headers, profileId, sessionId, ip, headers]
                ,   (err, res) =>
                        if err
                            throw new Error err

                        log 'INSERTED SESS', err, res
                        dfd.resolve sessionId

            catch err
                dfd.reject err

        dfd.promise
