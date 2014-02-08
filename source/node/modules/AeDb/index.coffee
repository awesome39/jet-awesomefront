{Module}= require 'di'

#
# Db Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class DbModule extends Module

    constructor: (config= {}, env= 'development') ->
        super



        #
        # Db Service
        #
        # @factory
        #
        @factory 'DbService', require './services/Db'



        #
        # Instance of Db Service
        #
        # @factory
        #
        @factory '$db', (DbService, log) ->

            new DbService

        #
        # Instance of Db Service
        #
        # @factory
        #
        @factory 'db', ($db) ->

            $db



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (injector) ->

        injector.invoke (app, $db, $dbMaria, $dbRedis) ->

            app.set 'db', $db

            # @todo
            $db.maria= $dbMaria
            $db.redis= $dbRedis
