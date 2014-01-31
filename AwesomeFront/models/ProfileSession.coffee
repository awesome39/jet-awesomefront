deferred= require 'deferred'

module.exports= (log) -> class ProfileSession
    @table: 'profile_session'



    constructor: (data) ->

        @ip= data.ip
        @headers= data.headers

        @sessionId= data.sessionId

        @createdAt= data.createdAt
        @expiredAt= data.expiredAt



    @queryRedis: (profileId, query, db, done) ->

    @queryMaria: (profileId, query, db, done) ->
        log 'ProfileSession#queryMaria', profileId, query
        sessions= null

        dfd= do deferred

        err= null
        if not profileId
            err= Error 'profileId cannot be null'

        if err
            if done instanceof Function
                process.nextTick ->
                    done err
            return dfd.reject err

        db.query """
            SELECT

                ProfileSession.*

              FROM ??
                as ProfileSession

             WHERE
                ProfileSession.profileId= ?
            """
        ,   [@table, profileId]
        ,   (err, rows) =>
                if not err
                    sessions= []
                    if rows.length
                        for row in rows
                            sessions.push new @ row
                    dfd.resolve sessions
                else
                    dfd.reject err

                if done instanceof Function
                    process.nextTick ->
                        done err, sessions

        dfd.promise



    @insertMaria: (profileId, sessionId, ip, headers, maria, done) ->
        dfd= do deferred

        process.nextTick =>
            try

                err= null

                if not profileId
                    err= Error 'profileId cannot be null'

                if not sessionId
                    err= Error 'sessionId cannot be null'

                if err then throw err

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
                        log 'INSERTED SESS', err, res
                        if not err
                            dfd.resolve sessionId
                        else
                            dfd.reject err

            catch err
                dfd.reject err

        dfd.promise
