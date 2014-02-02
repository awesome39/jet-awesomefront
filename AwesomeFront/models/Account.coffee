deferred= require 'deferred'
crypto= require 'crypto'

module.exports= (log) -> class Account
    @table: 'profile_account'



    constructor: (data) ->

        @id= data.id
        @profileId= data.profileId
        @name= data.name
        @pass= data.pass



    @serialize: (account, db, done) ->
        log 'serialize account', account
        done null, account

    @deserialize: (account, db, done) ->
        log 'deserialize account', account
        done null, account



    @auth: (account, db, done) ->
        dfd= do deferred

        err= null
        if not account
            err= Error 'account cannot be null'
        if not account.name or not account.pass
            err= Error 'account credentials cannot be null'

        if err
            if done
                process.nextTick ->
                    done err, account
            return dfd.reject err

        db.query "
            SELECT
                Account.*
              FROM
                ?? as Account
             WHERE
                Account.name= ?
               AND
                Account.pass= ?
            "
        ,   [@table, account.name, account.pass]
        ,   (err, rows) =>
                account= null

                if not err
                    if rows.length
                        account= new @ rows.shift()
                    dfd.resolve account
                else
                    dfd.reject err

                if done instanceof Function
                    process.nextTick ->
                        done err, account

        dfd.promise





    @create: (data, db, done) ->
        dfd= do deferred

        process.nextTick =>
            try

                err= null

                if not data
                    err= new @create.BadValueError 'data cannot be null'

                if err then throw err

                data= new @ data
                data.type= 'user'

                db.query """
                    INSERT
                        ??
                       SET
                        name= ?,
                        type= ?,
                        title= ?
                    ;
                    SELECT

                        Profile.*,

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',Account.id,',',
                            '"type":"',Account.type,'",',
                            '"name":"',Account.name,'",',
                            '"updatedAt":"',Account.updatedAt,'"',
                        '}') ORDER BY
                            (Account.type <=> 'local') DESC,
                            Account.type
                        ),']'), '[]') as accountsJson,

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',ProfileGroup.groupId,',',
                            '"name":"',ProfileGroupProfile.name,'",',
                            '"priority":',ProfileGroup.priority,',',
                            '"updatedAt":"',ProfileGroup.updatedAt,'"',
                        '}') ORDER BY
                            ProfileGroup.priority
                        ),']'), '[]') as groupsJson,

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',Permission.id,',',
                            '"name":"',Permission.name,'",',
                            '"profileId":',ProfilePermission.profileId,',',
                            '"priority":',IF(Profile.id<=>ProfilePermission.profileId,0,ProfileGroup.priority),',',
                            '"value":',ProfilePermission.value,',',
                            '"updatedAt":"',ProfilePermission.updatedAt,'"',
                        '}') ORDER BY
                            (Profile.id <=> ProfilePermission.profileId) DESC,
                            ProfileGroup.priority,
                            Permission.name,
                            ProfilePermission.value
                        ),']'), '[]') as permissionsJson

                      FROM ??
                        as Profile

                      LEFT JOIN ??
                        as Account
                        ON Account.profileId = Profile.id

                      LEFT JOIN ??
                        as ProfileGroup
                        ON ProfileGroup.profileId = Profile.id

                      LEFT JOIN ??
                        as ProfileGroupProfile
                        ON ProfileGroupProfile.id = ProfileGroup.groupId

                      LEFT JOIN ??
                        as ProfilePermission
                        ON ProfilePermission.profileId = Profile.id OR ProfilePermission.profileId= ProfileGroup.groupId

                      LEFT JOIN ??
                        as Permission
                        ON Permission.id = ProfilePermission.permissionId

                     WHERE
                        Profile.id= LAST_INSERT_ID()
                    """
                ,   [@table, data.name,'user',data.title, @table, @Account.table, @Group.table, @table, @Permission.table, @Permission.Permission.tablePermission]
                ,   (err, res) =>
                        if not err
                            if res[0].affectedRows == 1 and res[1].length == 1
                                data= new @ res[1][0]
                                dfd.resolve data
                            else
                                err= Error 'profile not created'
                        else
                            dfd.reject err

            catch err
                dfd.reject err

        dfd.promise

    @create.BadValueError= class CreateBadValueError extends Error
        constructor: (message) ->
            @message= message



    @query: (query, db, done) ->
        accounts= []

        dfd= do deferred

        setTimeout =>

            dfd.resolve accounts
            if done instanceof Function
                process.nextTick ->
                    done null, accounts

        ,   1023

        dfd.promise



    @get: (id, db, done) ->
        account= null

        dfd= do deferred

        setTimeout =>

            dfd.resolve account
            if done instanceof Function
                process.nextTick ->
                    done null, account

        ,   127

        dfd.promise



    @update: (id, data, db, done) ->
        dfd= do deferred

        err= null
        if not id
            err= Error 'id cannot be null'

        if not data
            err= Error 'data cannot be null'

        oldPass= @sha1 data.oldPass
        data= @filterDataForUpdate data

        if err
            dfd.reject err
            if done and err
                process.nextTick ->
                    done err
        if not err
            db.query "
                UPDATE
                    ??
                   SET
                    ?
                 WHERE
                    id= ?
                   AND
                    pass= ?
                "
            ,   [@table, data, id, oldPass]
            ,   (err, res) =>

                    if not err
                        if res.affectedRows == 1
                            dfd.resolve data
                        else
                            dfd.reject err
                    else
                        dfd.reject err

                    if done instanceof Function
                        process.nextTick ->
                            done err, data

        dfd.promise

    @filterDataForUpdate: (data) ->
        data=
            pass: @sha1 data.pass



    @sha1: (pass) ->
        sha1= crypto.createHash 'sha1'
        sha1.update pass
        sha1.digest 'hex'
