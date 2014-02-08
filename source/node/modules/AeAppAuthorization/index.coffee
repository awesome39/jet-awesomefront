{Module}= require 'di'

#
# App Authorization Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppAuthorizationModule extends Module

    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        #
        # Permission Model
        #
        # @factory
        #
        @factory 'Permission', require './models/Permission'

        #
        # Profile Permission Model
        #
        # @factory
        #
        @factory 'ProfilePermission', require './models/ProfilePermission'



        #
        # Authorize Service
        #
        # @factory
        #
        @factory 'Authorize', require './services/Authorize'

        #
        # Instance of Authorize Service
        #
        # @factory
        #
        @factory '$authorize', (Authorize) ->
            new Authorize config
