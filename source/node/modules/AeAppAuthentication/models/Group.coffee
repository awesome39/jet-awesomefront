deferred= require 'deferred'

#
# Group Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (ProfilePermission) -> class Group

    @table= 'profile'

    @Permission= ProfilePermission



    constructor: (data) ->

        @id= data.id
        @name= data.name
        @title= data.title

        @enabledAt= data.enabledAt
        @updatedAt= data.updatedAt



    @create: (data, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not data
                    throw new @create.BadValueError 'data cannot be null'

                data= new @ data

                db.query """
                    INSERT
                        ??
                    SET
                        name= ?,
                        type= ?,
                        title= ?
                    ;
                    SELECT
                        ProfileGroup.id,
                        ProfileGroup.name,
                        ProfileGroup.title,
                        ProfileGroup.enabledAt,
                        ProfileGroup.updatedAt
                    FROM
                        ?? AS ProfileGroup
                    WHERE
                        ProfileGroup.id= LAST_INSERT_ID()
                    """
                ,   [@table, data.name, 'group', data.title, @table]
                ,   (err, res) =>
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            group= new @ res[1][0]
                            dfd.resolve group
                        else
                            throw new Error 'group not created'

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
                        ProfileGroup.id,
                        ProfileGroup.name,
                        ProfileGroup.title,
                        ProfileGroup.enabledAt,
                        ProfileGroup.updatedAt
                    FROM
                        ?? AS ProfileGroup
                    WHERE
                        ProfileGroup.type = ?
                    """
                ,   [@table, 'group']
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        groups= []
                        if rows.length
                            for row in rows
                                groups.push new @ row
                        dfd.resolve groups

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
                        ProfileGroup.id,
                        ProfileGroup.name,
                        ProfileGroup.title,
                        ProfileGroup.enabledAt,
                        ProfileGroup.updatedAt
                    FROM
                        ?? AS ProfileGroup
                    WHERE
                        ProfileGroup.id = ?
                        AND
                        ProfileGroup.type = ?
                    """
                ,   [@table, id, 'group']
                ,   (err, rows) =>
                        if err
                            throw new Error err

                        if not err and rows.length == 0
                            throw new @getById.NotFoundError 'not found'

                        group= new @ rows.shift()
                        dfd.resolve group

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


                data= new @ data

                db.query """
                    UPDATE
                        ??
                    SET
                        ?
                    WHERE
                        id= ?
                        AND
                        type= ?
                    ;
                    SELECT
                        ProfileGroup.id,
                        ProfileGroup.name,
                        ProfileGroup.title,
                        ProfileGroup.enabledAt,
                        ProfileGroup.updatedAt
                    FROM
                        ?? AS ProfileGroup
                    WHERE
                        ProfileGroup.id = ?
                        AND
                        ProfileGroup.type = ?
                    """
                ,   [@table, data, id, 'group', @table, id, 'group']
                ,   (err, res) =>
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            group= new @ res[1][0]
                            dfd.resolve group
                        else
                            throw new Error 'not updated'

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
                            throw new Error 'not deleted'

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

