{Passport}= require 'passport'

#
# Auth Service Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Account, cfg, log) -> class AuthService extends Passport

    constructor: () ->
        super

        log= log.namespace '[AuthService]'



        @serializeUser= (account, done) ->
            done null, account

        @deserializeUser= (id, done) ->
            done null, id

        passportLocal= require 'passport-local'
        @use new passportLocal.Strategy (name, pass, done) =>
            done null, new Account
                name: name
                pass: Account.sha1 pass



    init: () ->
        @initialize
            userProperty: 'account'



    sess: () ->
        @session()
