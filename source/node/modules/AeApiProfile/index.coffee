{Module}= require 'di'

#
# Awesome Profile API
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class ProfileApi extends Module

    constructor: (config= {}) ->
        super



        @config= @constructor.manifest.config or {}



        #
        # Api Profile Handler
        #
        @factory 'ApiProfile', require './handlers/Api/V1/Profile'



    #
    # Initialize module with injector.
    #
    # @public
    #
    init: (app, db, ApiProfile) ->

        app.use '/api/v1/user', new ApiProfile
