{Module}= require 'di'

#
# AppSocket Module
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= class AppSocketModule extends Module

    constructor: (config= {}, env= 'development') ->
        super
