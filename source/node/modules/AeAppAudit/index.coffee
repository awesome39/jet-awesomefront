{Module}= require 'di'

#
# App Audit Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppAuditModule extends Module

    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        #
        # Audit Service
        #
        # @factory
        #
        @factory 'Audit', require './services/Audit'

        #
        # Instance of Audit Service
        #
        # @factory
        #
        @factory '$audit', (Audit) ->
            new Audit config
