deferred= require 'deferred'

module.exports= (Profile, log) -> class ProfileEmailVerification
    @table= 'profile_email_verification'

    @Profile= Profile



    constructor: (data) ->
        @id= data.id
        @token= data.token
        @emailId= data.emailId
        @verifiedAt= data.verifiedAt
        @value= data.value





    @create: (emailId, db, done) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not emailId
                    throw new @create.BadValueError 'emailId cannot be null'

                token= @generateString(40)

                db.query """
                    INSERT
                        ??
                    SET
                        token= ?,
                        emailId= ?
                    ;

                    SELECT
                        Token.id,
                        Token.token,
                        Token.emailId,
                        Email.profileId,
                        Email.value,
                        Email.verifiedAt,
                        Email.enabledAt,
                        Email.updatedAt

                    FROM
                        ?? AS Token

                    JOIN
                        ?? AS Email

                    ON
                        Email.id = Token.emailId

                    WHERE
                        Token.id = LAST_INSERT_ID()
                    """
                ,   [@table, token, emailId, @table, @Profile.tableEmail]
                ,   (err, res) =>
                    if not err
                        if res[0].affectedRows == 1 and res[1].length == 1
                            data= new @ res[1][0]
                            dfd.resolve data
                        else
                            err= Error 'token not created'
                    else
                        dfd.reject err

            catch err
                dfd.reject err

        dfd.promise

    @create.BadValueError= class CreateBadValueError extends Error
        constructor: (message) ->
            @message= message





    @query: (query, db) ->
        dfd= do deferred

        tokens= null
        process.nextTick =>

            db.query """
                SELECT
                    Token.id,
                    Token.token,
                    Token.emailId,
                    Email.profileId,
                    Email.value,
                    Email.verifiedAt,
                    Email.enabledAt,
                    Email.updatedAt

                FROM
                    ?? AS Token

                JOIN
                    ?? AS Email

                ON
                    Email.id = Token.emailId
                """
            ,   [@table, @Profile.tableEmail]
            ,   (err, rows) =>
                    if not err
                        profiles= []
                        if rows.length
                            for row in rows
                                profiles.push new @ row
                        dfd.resolve tokens
                    else
                        dfd.reject err

        dfd.promise





    @getById: (id, db) ->
        dfd= do deferred

        token= null
        process.nextTick =>
            try
                if not id
                    throw new @getById.BadValueError 'id cannot be null'

                db.query """
                    SELECT
                        Token.id,
                        Token.token,
                        Token.emailId,
                        Email.profileId,
                        Email.value,
                        Email.verifiedAt,
                        Email.enabledAt,
                        Email.updatedAt

                    FROM
                        ?? AS Token

                    JOIN
                        ?? AS Email

                    ON
                        Email.id = Token.emailId

                    WHERE
                        Token.id = ?
                    """
                ,   [@table, @tableProfileLink, id]
                ,   (err, rows) =>

                    if not err and rows.length == 0
                        throw new @getById.NotFoundError 'token not found'

                    if err
                        throw new Error err


                    row= rows.shift()
                    if row.id
                        token= new @ row
                    dfd.resolve token

            catch err
                dfd.reject err

        dfd.promise

    @getById.BadValueError= class GetByProfileIdBadValueError extends Error
        constructor: (message) ->
            @message= message

    @getById.NotFoundError= class GetByProfileIdNotFoundError extends Error
        constructor: (message) ->
            @message= message





    @getByToken: (token, db) ->
        dfd= do deferred

        token= null
        process.nextTick =>
            try
                if not token
                    throw new @getByToken.BadValueError 'token cannot be null'

                db.query """
                    SELECT
                        Token.id,
                        Token.token,
                        Token.emailId,
                        Email.profileId,
                        Email.value,
                        Email.verifiedAt,
                        Email.enabledAt,
                        Email.updatedAt

                    FROM
                        ?? AS Token

                    JOIN
                        ?? AS Email

                    ON
                        Email.id = Token.emailId

                    WHERE
                        Token.token = ?
                    """
                ,   [@table, @tableProfileLink, token]
                ,   (err, rows) =>

                    if not err and rows.length == 0
                        throw new @getByToken.NotFoundError 'token not found'

                    if err
                        throw new Error err


                    row= rows.shift()
                    if row.id
                        token= new @ row
                    dfd.resolve token

            catch err
                dfd.reject err

        dfd.promise

    @getByToken.BadValueError= class GetByTokenBadValueError extends Error
        constructor: (message) ->
            @message= message

    @getByToken.NotFoundError= class GetByTokenNotFoundError extends Error
        constructor: (message) ->
            @message= message





    @delete: (id, db, done) ->
        dfd= do deferred
        try

            err= null
            if not id
                err= new @delete.BadValueError 'id cannot be null'

            if err
                if done instanceof Function
                    process.nextTick ->
                        done err
                return dfd.reject err

            db.query """
                DELETE
                FROM
                    ??
                WHERE
                    id= ?
                ;
                """
            ,   [@table, id]
            ,   (err, res) =>

                    if not err
                        if res.affectedRows == 1
                            dfd.resolve true
                        else
                            dfd.reject err= new @delete.NotFoundError 'not deleted'
                    else
                        dfd.reject err

                    if done instanceof Function
                        process.nextTick ->
                            done err, data

        catch err
            dfd.reject err

        dfd.promise

    @delete.BadValueError= class DeleteBadValueError extends Error
        constructor: (message) ->
            @message= message

    @delete.NotFoundError= class DeleteNotFoundError extends Error
        constructor: (message) ->
            @message= message



    @generateString= (n) ->
        s= ''
        while s.length < n
            s += Math.random().toString(36).replace(/\d|_/g,'').slice(2, 12);
        s.substr(0, n)