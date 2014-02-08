deferred= require 'deferred'
crypto= require 'crypto'

#
# Account Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class Account

    @table: 'profile_account'



    constructor: (data) ->

        @id= data.id
        @profileId= data.profileId
        @name= data.name
        @type= data.type
        @pass= data.pass

        @enabledAt= data.enabledAt
        @updatedAt= data.updatedAt



    @serialize: (account, db, done) ->
        log 'serialize account', account
        done null, account

    @deserialize: (account, db, done) ->
        log 'deserialize account', account
        done null, account



    @auth: (data, db) ->
        dfd= do deferred

        process.nextTick =>
            try
                if not data
                    throw new Error 'account cannot be null'

                if not data.name or not data.pass
                    throw new Error 'account credentials cannot be null'


                db.query """
                    SELECT
                        Account.id,
                        Account.profileId,
                        Account.name,
                        Account.type,
                        Account.enabledAt,
                        Account.updatedAt
                    FROM
                        ?? as Account
                    WHERE
                        Account.name= ?
                        AND
                        Account.pass= ?
                    """
                ,   [@table, data.name, data.pass]
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        account= null
                        if rows.length
                            account= new @ rows.shift()
                        dfd.resolve account

            catch err
                dfd.reject err

        dfd.promise





    @create: (profileId, data, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not profileId
                    throw new @create.BadValueError 'profileId cannot be null'

                if not data
                    throw new @create.BadValueError 'data cannot be null'

                data= new @ data
                data.pass= @sha1 data.pass

                db.query """
                    INSERT
                        ??
                    SET
                        profileId= ?,
                        name= ?,
                        pass= ?
                    ;
                    SELECT
                        Account.id,
                        Account.profileId,
                        Account.type,
                        Account.name,
                        Account.enabledAt,
                        Account.updatedAt
                    FROM
                        ?? AS Account
                    WHERE
                        Account.id= LAST_INSERT_ID()
                    """
                ,   [@table, profileId, data.name, data.pass, @table]
                ,   (err, res) =>
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            account= new @ res[1][0]
                            dfd.resolve account
                        else
                            throw new Error 'account not created'

            catch err
                dfd.reject err

        dfd.promise

    @create.BadValueError= class CreateBadValueError extends Error
        constructor: (message) ->
            @message= message





    @query: (query, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                db.query """
                    SELECT
                        Account.id,
                        Account.profileId,
                        Account.type,
                        Account.name,
                        Account.enabledAt,
                        Account.updatedAt
                    FROM
                        ?? AS Account
                    """
                ,   [@table]
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        accounts= []
                        if rows.length
                            for row in rows
                                accounts.push new @ row
                        dfd.resolve accounts

            catch err
                dfd.reject err

        dfd.promise





    @getById: (id, db) ->
        dfd= do deferred

        process.nextTick =>
            try
                if not id
                    throw new @get.BadValueError 'id cannot be null'


                db.query """
                    SELECT
                        Account.id,
                        Account.profileId,
                        Account.type,
                        Account.name,
                        Account.enabledAt,
                        Account.updatedAt
                    FROM
                        ?? AS Account
                    WHERE
                        Account.id = ?
                    """
                ,   [@table, id]
                ,   (err, rows) =>
                        if not err and rows.length == 0
                            throw new @getById.NotFoundError 'account not found'

                        if err
                            throw new Error err

                        account= new @ rows.shift()
                        dfd.resolve account

            catch err
                dfd.reject err

        dfd.promise

    @getById.BadValueError= class GetByIdBadValueError extends Error
        constructor: (message) ->
            @message= message

    @getById.NotFoundError= class GetByIdNotFoundError extends Error
        constructor: (message) ->
            @message= message





    @update: (id, data, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not id
                    throw new @update.BadValueError 'id cannot be null'

                if not data
                    throw new @update.BadValueError 'data cannot be null'


                oldPass= @sha1 data.oldPass
                data= new @ data
                data.pass= @sha1 data.pass

                db.query """
                    UPDATE
                        ??
                    SET
                        ?
                    WHERE
                        id= ?
                        AND
                        pass= ?
                    ;
                    SELECT
                        Account.id,
                        Account.profileId,
                        Account.type,
                        Account.name,
                        Account.enabledAt,
                        Account.updatedAt
                    FROM
                        ?? AS Account
                    WHERE
                        Account.id= ?
                    """
                ,   [@table, data, id, oldPass, @table, id]
                ,   (err, res) =>
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            account= new @ res[1][0]
                            dfd.resolve account
                        else
                            throw new Error 'account not updated'

            catch err
                dfd.reject err

        dfd.promise

    @update.BadValueError= class UpdateBadValueError extends Error
        constructor: (message) ->
            @message= message





    @delete: (id, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not id
                    throw new @delete.BadValueError 'id cannot be null'


                db.query """
                    DELETE
                    FROM
                        ??
                    WHERE
                        id= ?
                    """
                ,   [@table, id]
                ,   (err, res) =>
                        if err
                            throw new Error err
                        if res.length == 0
                            throw new @delete.NotFoundError 'not found'

                        if res[0].affectedRows == 1
                            dfd.resolve true
                        else
                            throw new Error 'account not deleted'

            catch err
                dfd.reject err

        dfd.promise

    @delete.BadValueError= class DeleteBadValueError extends Error
        constructor: (message) ->
            @message= message

    @delete.NotFoundError= class DeleteNotFoundError extends Error
        constructor: (message) ->
            @message= message





    @enable: (id, enabled, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not id
                    throw new @enable.BadValueError 'id cannot be null'


                enabled= enabled|0

                db.query """
                    UPDATE
                        ??
                    SET
                        enabledAt= IF(?, IF(enabledAt, enabledAt, NOW()), NULL)
                    WHERE
                        id= ?
                    ;
                    SELECT
                        enabledAt
                    FROM
                        ??
                    WHERE
                        id= ?
                    """
                ,   [@table, enabled, id, @table, id]
                ,   (err, res) =>
                        if err
                            throw new Error err
                        if res.length == 0
                            throw new @enable.NotFoundError 'not found'

                        enabledAt= res[1][0].enabledAt
                        enabled= !!enabledAt

                        data=
                            enabledAt: enabledAt
                            enabled: enabled
                        dfd.resolve data

            catch err
                dfd.reject err

        dfd.promise

    @enable.BadValueError= class EnableBadValueError extends Error
        constructor: (message) ->
            @message= message

    @enable.NotFoundError= class EnableNotFoundError extends Error
        constructor: (message) ->
            @message= message





    @filterDataForUpdate: (data) ->
        data=
            pass: @sha1 data.pass



    @sha1: (pass) ->
        sha1= crypto.createHash 'sha1'
        sha1.update pass
        sha1.digest 'hex'
