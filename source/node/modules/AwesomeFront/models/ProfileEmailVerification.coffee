deferred= require 'deferred'

module.exports= (Profile, log) -> class ProfileEmailVerification
    @table= 'profile_email_verification'

    @Profile= Profile



    constructor: (data) ->
        @id= data.id
        @token= data.token
        @emailId= data.emailId
        @profileId= data.profileId
        @verifiedAt= data.verifiedAt
        @value= data.value





    @create: (emailId, db) ->
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
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            data= new @ res[1][0]
                            dfd.resolve data
                        else
                            throw new Error 'token not created'

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
                    if err
                        throw new Error err

                    tokens= []
                    if rows.length
                        for row in rows
                            tokens.push new @ row
                    dfd.resolve tokens

        dfd.promise





    @getById: (id, db) ->
        dfd= do deferred

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
                ,   [@table, @Profile.tableEmail, id]
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        if not err and rows.length == 0
                            throw new @getById.NotFoundError 'token not found'

                        token= null
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
                ,   [@table, @Profile.tableEmail, token]
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        if not err and rows.length == 0
                            throw new @getByToken.NotFoundError 'token not found'


                        token= null
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





    @delete: (id, db) ->
        dfd= do deferred
        try

            if not id
                throw new @delete.BadValueError 'id cannot be null'


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
                    if err
                        throw new Error err

                    if res.affectedRows == 1
                        dfd.resolve true
                    else
                        throw new @delete.NotFoundError 'not deleted'

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
