{Passport}= require 'passport'

module.exports= (Account, AccountGithub, cfg, log) -> class AuthService extends Passport

    constructor: () ->
        super

        log= log.namespace '[AuthService]'
        log 'Created.', do process.hrtime

        @serializeUser= (account, done) ->
            #console.log 'serialize account', account
            done null, account

        @deserializeUser= (id, done) ->
            #console.log 'deserialize account', id
            done null, id

        passportLocal= require 'passport-local'
        @use new passportLocal.Strategy (name, pass, done) =>
            done null, new Account
                name: name
                pass: Account.sha1 pass

        passportGithub= require 'passport-github'
        @use new passportGithub.Strategy
            clientID: cfg.auth.github.clientID
            clientSecret: cfg.auth.github.clientSecret
        ,   (accessToken, refreshToken, github, done) ->
                done null, new AccountGithub
                    providerId: github.id
                    providerName: github.username



    init: () ->
        @initialize
            userProperty: 'account'



    sess: () ->
        @session()
