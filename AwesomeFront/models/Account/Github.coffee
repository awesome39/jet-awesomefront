deferred= require 'deferred'

module.exports= (Account, log) -> class AccountGithub extends Account
    @table: 'profile_account_github'



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
