deferred= require 'deferred'

#
# Account Github Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Account, log) -> class AccountGithub extends Account

    @table: 'profile_account_github'

    @Account: Account



    constructor: (data) ->
        @id= data.id
        @userId= data.userId
        @provider= 'github'
        @providerId= data.providerId
        @providerName= data.providerName



    @auth: (account, db) ->
        dfd= do deferred

        process.nextTick =>

            db.query """

                    SELECT

                        *

                      FROM
                        ?? as AccountGithub

                     WHERE
                        AccountGithub.providerId= ?

                """
            ,   [@table, account.providerId]
            ,   (err, res) =>
                    if not err
                        dfd.resolve res[0] or null
                    else
                        dfd.reject err

        dfd.promise



    @query: (profile, query, db) ->
        dfd= do deferred

        accounts= null
        process.nextTick =>
            try

                db.query """

                    SELECT

                        AccountGithub.id,
                        AccountGithub.profileId as userId,
                        AccountGithub.providerId,
                        AccountGithub.providerName

                      FROM
                        ?? as AccountGithub

                     WHERE
                        AccountGithub.profileId= ?

                    """
                ,   [@table, profile.id]
                ,   (err, rows) =>
                        if not err

                            accounts= []
                            if rows.length
                                for row in rows
                                    accounts.push new @ row

                            dfd.resolve accounts

                        else
                            dfd.reject err

            catch err
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



            catch err
                dfd.reject err

        dfd.promise

    @create.BadValueError= class CreateBadValueError extends Error
        constructor: (message) ->
            @message= message



    @updateAll: (profile, data, db, done) ->
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

                for account in data
                    if account.id
                        if account.deleted
                            forDelete.push account
                        else
                            forUpdate.push account
                    else
                        forInsert.push [profile.id, account.providerName]

                if forDelete.length
                    step++
                    ids= []
                    for account in forDelete
                        ids.push account.id
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
                    queryParams.push @table
                    queryParams.push profile.id
                    queryParams.push ids

                if forUpdate.length
                    for account in forUpdate
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
                        queryParams.push @table
                        queryParams.push account.value
                        queryParams.push account.value
                        queryParams.push account.id
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
                    queryParams.push @table
                    queryParams.push forInsert

            catch err
                dfd.reject err

        dfd.promise
