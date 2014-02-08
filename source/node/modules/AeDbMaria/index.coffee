{Module}= require 'di'

#
# Db Maria Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class DbMariaModule extends Module

    constructor: (config= {}, env= 'development') ->
        super



        #
        # Db Maria Service
        #
        # @factory
        #
        @factory 'DbMariaService', require './services/DbMaria'



        #
        # Instance of Db Maria Service
        #
        # @factory
        #
        @factory '$dbMaria', ($cfg, $db, DbMariaService, log) ->

            new DbMariaService $cfg.db.maria
