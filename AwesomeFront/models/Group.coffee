deferred= require 'deferred'

module.exports= (ProfilePermission) -> class Group
    @table= 'profile'

    @Permission= ProfilePermission



    constructor: (data) ->

        @id= data.id
        @name= data.name
        @title= data.title

        @enabledAt= data.enabledAt
        @updatedAt= data.updatedAt

        @permissions= data.permissions or JSON.parse (data.permissionsJson or null)



    @query: (query, db, done) ->
        profiles= null

        dfd= do deferred

        db.query """
            SELECT

                Profile.*,

                CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('{',
                    '"id":',Permission.id,',',
                    '"name":"',Permission.name,'",',
                    '"value":',ProfilePermission.value,
                '}') ORDER BY
                    Permission.name,
                    ProfilePermission.value
                ),']') as permissionsJson

              FROM ??
                as Profile

              LEFT JOIN ??
                as ProfilePermission
                ON ProfilePermission.profileId = Profile.id

              LEFT JOIN ??
                as Permission
                ON Permission.id = ProfilePermission.permissionId

             WHERE
                Profile.type = ?

             GROUP BY
                Profile.id
            """
        ,   [@table, @Permission.table, @Permission.Permission.tablePermission, 'group']
        ,   (err, rows) =>
                if not err
                    profiles= []
                    if rows.length
                        for row in rows
                            profiles.push new @ row
                    dfd.resolve profiles
                else
                    dfd.reject err

                if done instanceof Function
                    process.nextTick ->
                        done err, profiles

        dfd.promise
