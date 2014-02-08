deferred= require 'deferred'

#
# Profile Permission Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Permission, log) -> class ProfilePermission extends Permission

    @table= 'profile_permission'

    @Permission: Permission



    constructor: (data) ->

        @id= data.id
        @profileId= data.profileId
        @permissionId= data.permissionId

        @value= data.value

        @enabledAt= data.enabledAt
        @updatedAt= data.updatedAt





    @createByName: (profileId, name, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not profileId
                    throw new @createByName.BadValueError 'profileId cannot be null'

                if not name
                    throw new @createByName.BadValueError 'name cannot be null'


                db.query """
                    INSERT
                        ??
                    SET
                        profileId= ?,
                        permissionId= (
                            SELECT
                                Permission.id

                            FROM
                                ?? AS Permission

                            WHERE
                                Permission.name = ?
                        )
                    ;

                    SELECT
                        ProfilePermission.*

                    FROM
                        ?? AS ProfilePermission

                    WHERE
                        ProfilePermission.id= LAST_INSERT_ID()
                    """
                ,   [@table, profileId, @Permission.table, name, @table]
                ,   (err, res) =>
                        if err
                            throw new Error err

                        if res[0].affectedRows == 1 and res[1].length == 1
                            data= new @ res[1][0]
                            dfd.resolve data
                        else
                            throw new Error 'profile permission not created'

            catch err
                dfd.reject err

        dfd.promise

    @createByName.BadValueError= class CreateBadValueError extends Error
        constructor: (message) ->
            @message= message





    @enableByProfileId: (profileId, enabled, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                if not profileId
                    throw new @enableByProfileId.BadValueError 'profileId cannot be null'


                enabled= enabled|0

                db.query """
                    UPDATE
                        ??
                    SET
                        enabledAt= IF(?, IF(enabledAt, enabledAt, NOW()), NULL)
                    WHERE
                        profileId= ?
                    ;
                    SELECT
                        enabledAt
                    FROM
                        ??
                    WHERE
                        profileId= ?
                    """
                ,   [@table, enabled, profileId, @table, profileId]
                ,   (err, res) =>
                        if err
                            throw new Error err
                        if res.length == 0
                            throw new @enableByProfileId.NotFoundError 'not found'

                        enabledAt= res[1][0].enabledAt
                        enabled= !!enabledAt

                        data=
                            enabledAt: enabledAt
                            enabled: enabled
                        dfd.resolve data

            catch err
                dfd.reject err

        dfd.promise

    @enableByProfileId.BadValueError= class EnableBadValueError extends Error
        constructor: (message) ->
            @message= message

    @enableByProfileId.NotFoundError= class EnableNotFoundError extends Error
        constructor: (message) ->
            @message= message
