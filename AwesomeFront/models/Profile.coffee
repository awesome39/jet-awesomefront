deferred= require 'deferred'

module.exports= (Account, ProfileGroup, ProfilePermission, log) -> class Profile
    @table= 'profile'
    @tableEmail= 'profile_email'
    @tablePhone= 'profile_phone'

    @Account= Account
    @Group= ProfileGroup
    @Permission= ProfilePermission



    constructor: (data) ->

        @id= data.id
        @name= data.name
        @title= data.title

        @emails= data.emails or JSON.parse (data.emailsJson or null)
        @phones= data.phones or JSON.parse (data.phonesJson or null)

        @accounts= data.accounts or JSON.parse (data.accountsJson or null)
        @groups= data.groups or JSON.parse (data.groupsJson or null)
        @permissions= data.permissions or JSON.parse (data.permissionsJson or null)

        @enabledAt= data.enabledAt
        @updatedAt= data.updatedAt



    @query: (query, db) ->
        dfd= do deferred

        profiles= null
        process.nextTick =>

            db.query """
                SELECT

                    Profile.*,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfileEmail.id,',',
                        '"value":"',ProfileEmail.value,'",',
                        '"verified":',IF((ProfileEmail.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfileEmail.verifiedAt IS NOT NULL) DESC,
                        ProfileEmail.id
                    ),']'), '[]') as emailsJson,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfilePhone.id,',',
                        '"value":"',ProfilePhone.value,'",',
                        '"verified":',IF((ProfilePhone.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfilePhone.verifiedAt IS NOT NULL) DESC,
                        ProfilePhone.id
                    ),']'), '[]') as phonesJson,

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
                    as ProfileEmail
                    ON ProfileEmail.profileId = Profile.id

                  LEFT JOIN ??
                    as ProfilePhone
                    ON ProfilePhone.profileId = Profile.id

                  LEFT JOIN ??
                    as Account
                    ON Account.profileId = Profile.id
                    AND Account.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroup
                    ON ProfileGroup.profileId = Profile.id
                    AND ProfileGroup.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroupProfile
                    ON ProfileGroupProfile.id = ProfileGroup.groupId
                    AND ProfileGroupProfile.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfilePermission
                    ON ProfilePermission.profileId = Profile.id OR ProfilePermission.profileId= ProfileGroup.groupId
                    AND ProfilePermission.enabledAt <= NOW()

                  LEFT JOIN ??
                    as Permission
                    ON Permission.id = ProfilePermission.permissionId
                    AND Permission.enabledAt <= NOW()

                 WHERE
                    Profile.type = ?

                 GROUP BY
                    Profile.id
                 ORDER BY
                    Profile.updatedAt DESC
                """
            ,   [@table, @tableEmail, @tablePhone, @Account.table, @Group.table, @table, @Permission.table, @Permission.Permission.tablePermission, 'user']
            ,   (err, rows) =>
                    if not err
                        profiles= []
                        if rows.length
                            for row in rows
                                profiles.push new @ row
                        dfd.resolve profiles
                    else
                        dfd.reject err

        dfd.promise



    @cacheIntoRedis: (profile, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                key= ['profile',profile.id].join ':'
                data= JSON.stringify profile

                db.client.set key, data, (err, reply) ->
                    if not err
                        dfd.resolve profile
                    else
                        dfd.reject err

            catch err
                dfd.reject err

        dfd.promise



    @getByIdFromRedis: (id, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                key= ['profile',id].join ':'

                db.client.get key, (err, data) ->
                    if not err
                        dfd.resolve if data then JSON.parse data else null
                    else
                        dfd.reject err

            catch err
                dfd.reject err

        dfd.promise



    @getById: (id, db) ->
        dfd= do deferred

        profile= null
        process.nextTick =>

            err= null
            if not id
                return dfd.reject err= Error 'id cannot be null'

            db.query """
                SELECT

                    Profile.*,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfileEmail.id,',',
                        '"value":"',ProfileEmail.value,'",',
                        '"verified":',IF((ProfileEmail.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfileEmail.verifiedAt IS NOT NULL) DESC,
                        ProfileEmail.id
                    ),']'), '[]') as emailsJson,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfilePhone.id,',',
                        '"value":"',ProfilePhone.value,'",',
                        '"verified":',IF((ProfilePhone.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfilePhone.verifiedAt IS NOT NULL) DESC,
                        ProfilePhone.id
                    ),']'), '[]') as phonesJson,

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
                    as ProfileEmail
                    ON ProfileEmail.profileId = Profile.id

                  LEFT JOIN ??
                    as ProfilePhone
                    ON ProfilePhone.profileId = Profile.id

                  LEFT JOIN ??
                    as Account
                    ON Account.profileId = Profile.id
                    AND Account.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroup
                    ON ProfileGroup.profileId = Profile.id
                    AND ProfileGroup.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroupProfile
                    ON ProfileGroupProfile.id = ProfileGroup.groupId
                    AND ProfileGroupProfile.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfilePermission
                    ON ProfilePermission.profileId = Profile.id OR ProfilePermission.profileId= ProfileGroup.groupId
                    AND ProfilePermission.enabledAt <= NOW()

                  LEFT JOIN ??
                    as Permission
                    ON Permission.id = ProfilePermission.permissionId
                    AND Permission.enabledAt <= NOW()

                 WHERE
                    Profile.id= ?
                    AND
                    Profile.enabledAt <= NOW()
                """
            ,   [@table, @tableEmail, @tablePhone, @Account.table, @Group.table, @table, @Permission.table, @Permission.Permission.tablePermission, id]
            ,   (err, rows) =>

                    if not err and rows.length and not rows[0].id
                        err= Error 'profile not found'

                    if not err
                        if rows.length
                            profile= new @ rows.shift()
                        dfd.resolve profile
                    else
                        dfd.reject err

        dfd.promise



    @getByName: (name, db) ->
        dfd= do deferred

        profile= null
        process.nextTick =>

            err= null
            if not name
                return dfd.reject err= Error 'name cannot be null'

            db.query """
                SELECT

                    Profile.*,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfileEmail.id,',',
                        '"value":"',ProfileEmail.value,'",',
                        '"verified":',IF((ProfileEmail.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfileEmail.verifiedAt IS NOT NULL) DESC,
                        ProfileEmail.id
                    ),']'), '[]') as emailsJson,

                    IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                        '"id":',ProfilePhone.id,',',
                        '"value":"',ProfilePhone.value,'",',
                        '"verified":',IF((ProfilePhone.verifiedAt IS NOT NULL),1,0),
                    '}') ORDER BY
                        (ProfilePhone.verifiedAt IS NOT NULL) DESC,
                        ProfilePhone.id
                    ),']'), '[]') as phonesJson,

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
                    as ProfileEmail
                    ON ProfileEmail.profileId = Profile.id

                  LEFT JOIN ??
                    as ProfilePhone
                    ON ProfilePhone.profileId = Profile.id

                  LEFT JOIN ??
                    as Account
                    ON Account.profileId = Profile.id
                    AND Account.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroup
                    ON ProfileGroup.profileId = Profile.id
                    AND ProfileGroup.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfileGroupProfile
                    ON ProfileGroupProfile.id = ProfileGroup.groupId
                    AND ProfileGroupProfile.enabledAt <= NOW()

                  LEFT JOIN ??
                    as ProfilePermission
                    ON ProfilePermission.profileId = Profile.id OR ProfilePermission.profileId= ProfileGroup.groupId
                    AND ProfilePermission.enabledAt <= NOW()

                  LEFT JOIN ??
                    as Permission
                    ON Permission.id = ProfilePermission.permissionId
                    AND Permission.enabledAt <= NOW()

                 WHERE
                    Profile.name= ?
                    AND
                    Profile.enabledAt <= NOW()
                """
            ,   [@table, @tableEmail, @tablePhone, @Account.table, @Group.table, @table, @Permission.table, @Permission.Permission.tablePermission, name]
            ,   (err, rows) =>

                    if not err
                        if rows.length
                            row= rows.shift()
                            if row.id
                                profile= new @ row
                            dfd.resolve profile
                    else
                        dfd.reject err

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



    @createEmails: (id, data, db, done) ->
        dfd= do deferred
        try

            err= null

            if not id then err= new @createEmails.BadValueError 'id cannot be null'
            if not data then err= new @createEmails.BadValueError 'data cannot be null'

            if err then throw err

            bulk= []
            for email in data
                bulk.push [id, email.value]

            if not bulk.length
                dfd.resolve []
            else
                db.query """
                    INSERT
                        ??
                    (
                        profileId,
                        value
                    )
                    VALUES
                        ?
                    ;
                    SELECT

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',ProfileEmail.id,',',
                            '"value":"',ProfileEmail.value,'",',
                            '"verified":',IF((ProfileEmail.verifiedAt IS NOT NULL),1,0),
                        '}') ORDER BY
                            (ProfileEmail.verifiedAt IS NOT NULL) DESC,
                            ProfileEmail.id
                        ),']'), '[]') as emailsJson

                      FROM
                        ?? as ProfileEmail
                     WHERE
                        ProfileEmail.profileId= ?
                     GROUP BY
                        ProfileEmail.profileId
                    ;
                    """
                ,   [@tableEmail, bulk, @tableEmail, id]
                ,   (err, res) =>
                        if not err
                            if res[0].affectedRows == bulk.length and res[1].length == 1
                                data= new @ res[1][0]
                                dfd.resolve data.emails
                            else
                                dfd.reject Error 'profile emails not created'
                        else
                            dfd.reject err

                        if done instanceof Function
                            process.nextTick ->
                                done err, data

        catch err
            if done instanceof Function
                process.nextTick ->
                    done err
            dfd.reject err

        dfd.promise

    @createEmails.BadValueError= class CreateEmailsBadValueError extends CreateBadValueError
        constructor: (message) ->
            @message= message



    @createPhones: (id, data, db, done) ->
        dfd= do deferred
        try

            err= null

            if not id then err= new @createPhones.BadValueError 'id cannot be null'
            if not data then err= new @createPhones.BadValueError 'data cannot be null'

            if err then throw err

            bulk= []
            for phone in data
                bulk.push [id, phone.value]

            if not bulk.length
                dfd.resolve []
            else
                db.query """
                    INSERT
                        ??
                    (
                        profileId,
                        value
                    )
                    VALUES
                        ?
                    ;
                    SELECT

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',ProfilePhone.id,',',
                            '"value":"',ProfilePhone.value,'",',
                            '"verified":',IF((ProfilePhone.verifiedAt IS NOT NULL),1,0),
                        '}') ORDER BY
                            (ProfilePhone.verifiedAt IS NOT NULL) DESC,
                            ProfilePhone.id
                        ),']'), '[]') as phonesJson

                      FROM
                        ?? as ProfilePhone
                     WHERE
                        ProfilePhone.profileId= ?
                     GROUP BY
                        ProfilePhone.profileId
                    ;
                    """
                ,   [@tablePhone, bulk, @tablePhone, id]
                ,   (err, res) =>
                        if not err
                            if res[0].affectedRows == bulk.length and res[1].length == 1
                                data= new @ res[1][0]
                                dfd.resolve data.phones
                            else
                                dfd.reject Error 'profile phones not created'
                        else
                            dfd.reject err

                        if done instanceof Function
                            process.nextTick ->
                                done err, data

        catch err
            if done instanceof Function
                process.nextTick ->
                    done err
            dfd.reject err

        dfd.promise

    @createPhones.BadValueError= class CreatePhonesBadValueError extends CreateBadValueError
        constructor: (message) ->
            @message= message



    @update: (id, data, db, done) ->
        dfd= do deferred

        process.nextTick =>
            try

                err= null
                if not id
                    err= Error 'id cannot be null'

                if not data
                    err= Error 'data cannot be null'

                data= new @ data

                if err then throw err

                db.query """
                    UPDATE
                        ??
                       SET
                        title= IFNULL(?, title)
                     WHERE
                        id= ?
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
                        Profile.id= ?
                    """
                ,   [@table, data.title, id, @table, @Account.table, @Group.table, @table, @Permission.table, @Permission.Permission.tablePermission, id]
                ,   (err, res) =>

                        log 'SELECT AFTER UPDATE', err, res

                        if not err and res[0].affectedRows == 1 and res[1].length == 1
                            data= new @ res[1][0]
                            dfd.resolve data
                        else
                            dfd.reject err

            catch err
                dfd.reject err

        dfd.promise



    @updateEmails: (profile, data, db) ->
        dfd= do deferred

        process.nextTick =>
            try

                err= null
                if not profile or not profile.id
                    err= Error 'profile id cannot be null'
                if not data
                    err= Error 'data cannot be null'

                if err then throw err

                step= 0

                query= ""
                queryParams= []

                forInsert= []
                forUpdate= []
                forDelete= []

                for email in data
                    if email.id
                        if email.deleted
                            forDelete.push email
                        else
                            forUpdate.push email
                    else
                        forInsert.push [profile.id, email.value]

                if forDelete.length
                    step++
                    ids= []
                    for email in forDelete
                        ids.push email.id
                    query= query + """
                        DELETE
                          FROM
                            ??
                         WHERE
                            profileId= ?
                            AND
                            id IN(?)
                        ;
                        """
                    queryParams.push @tableEmail
                    queryParams.push profile.id
                    queryParams.push ids

                if forUpdate.length
                    for email in forUpdate
                        step++
                        query= query + """
                            UPDATE
                                ??
                               SET
                                verifiedAt= IF(value = ?, verifiedAt, NULL),
                                value= ?
                             WHERE
                                id= ?
                                AND
                                profileId= ?
                            ;
                            """
                        queryParams.push @tableEmail
                        queryParams.push email.value
                        queryParams.push email.value
                        queryParams.push email.id
                        queryParams.push profile.id

                if forInsert.length
                    step++
                    query= query + """
                        INSERT
                            ??
                        (
                            profileId,
                            value
                        )
                        VALUES
                            ?
                        ;
                        """
                    queryParams.push @tableEmail
                    queryParams.push forInsert

                query= query + """
                    SELECT

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',ProfileEmail.id,',',
                            '"value":"',ProfileEmail.value,'",',
                            '"verified":',IF((ProfileEmail.verifiedAt IS NOT NULL),1,0),
                        '}') ORDER BY
                            (ProfileEmail.verifiedAt IS NOT NULL) DESC,
                            ProfileEmail.id
                        ),']'), '[]') as emailsJson

                      FROM
                        ?? as ProfileEmail
                     WHERE
                        ProfileEmail.profileId= ?
                     GROUP BY
                        ProfileEmail.profileId
                    ;
                    """
                queryParams.push @tableEmail
                queryParams.push profile.id

                db.query query, queryParams
                ,   (err, res) =>

                        if not err
                            if step then data= res[step][0] else data= res[0]
                            if data
                                data= new @ data
                                dfd.resolve data.emails
                            else
                                dfd.resolve []
                        else
                            dfd.reject err

            catch err
                dfd.reject err

        dfd.promise



    @updatePhones: (profile, data, db, done) ->
        dfd= do deferred

        process.nextTick =>
            try

                err= null
                if not profile or not profile.id
                    err= Error 'profile id cannot be null'
                if not data
                    err= Error 'data cannot be null'

                if err then throw err

                step= 0

                query= ""
                queryParams= []

                forInsert= []
                forUpdate= []
                forDelete= []

                for phone in data
                    if phone.id
                        if phone.deleted
                            forDelete.push phone
                        else
                            forUpdate.push phone
                    else
                        forInsert.push [profile.id, phone.value]

                if forDelete.length
                    step++
                    ids= []
                    for phone in forDelete
                        ids.push phone.id
                    query= query + """
                        DELETE
                          FROM
                            ??
                         WHERE
                            profileId= ?
                            AND
                            id IN(?)
                        ;
                        """
                    queryParams.push @tablePhone
                    queryParams.push profile.id
                    queryParams.push ids

                if forUpdate.length
                    for phone in forUpdate
                        step++
                        query= query + """
                            UPDATE
                                ??
                               SET
                                verifiedAt= IF(value = ?, verifiedAt, NULL),
                                value= ?
                             WHERE
                                id= ?
                                AND
                                profileId= ?
                            ;
                            """
                        queryParams.push @tablePhone
                        queryParams.push phone.value
                        queryParams.push phone.value
                        queryParams.push phone.id
                        queryParams.push profile.id

                if forInsert.length
                    step++
                    query= query + """
                        INSERT
                            ??
                        (
                            profileId,
                            value
                        )
                        VALUES
                            ?
                        ;
                        """
                    queryParams.push @tablePhone
                    queryParams.push forInsert

                query= query + """
                    SELECT

                        IFNULL(CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                            '"id":',ProfilePhone.id,',',
                            '"value":"',ProfilePhone.value,'",',
                            '"verified":',IF((ProfilePhone.verifiedAt IS NOT NULL),1,0),
                        '}') ORDER BY
                            (ProfilePhone.verifiedAt IS NOT NULL) DESC,
                            ProfilePhone.id
                        ),']'), '[]') as phonesJson

                      FROM
                        ?? as ProfilePhone
                     WHERE
                        ProfilePhone.profileId= ?
                     GROUP BY
                        ProfilePhone.profileId
                    ;
                    """
                queryParams.push @tablePhone
                queryParams.push profile.id

                db.query query, queryParams
                ,   (err, res) =>

                        if not err
                            if step then data= res[step][0] else data= res[0]
                            if data
                                data= new @ data
                                dfd.resolve data.phones
                            else
                                dfd.resolve []
                        else
                            dfd.reject err

            catch err
                dfd.reject err

        dfd.promise





    ###
    Удаляет указанный профиль.
    ###
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





    ###
    Включает указанный профиль.
    ###
    @enable: (id, enabled, db, done) ->
        dfd= do deferred
        try

            err= null
            if not id
                err= new @enable.BadValueError 'id cannot be null'

            enabled= enabled|0

            if err
                if done instanceof Function
                    process.nextTick ->
                        done err
                return dfd.reject err

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

                    if not err
                        enabledAt= res[1][0].enabledAt
                        enabled= !!enabledAt
                        dfd.resolve
                            enabledAt: enabledAt
                            enabled: enabled
                    else
                        dfd.reject err

                    if done instanceof Function
                        process.nextTick ->
                            done err, state

        catch err
            dfd.reject err

        dfd.promise

    @enable.BadValueError= class EnableBadValueError extends Error
        constructor: (message) ->
            @message= message

    @enable.NotFoundError= class EnableNotFoundError extends Error
        constructor: (message) ->
            @message= message
