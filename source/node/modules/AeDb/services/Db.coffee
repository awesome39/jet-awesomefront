#
# Db Service
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (log) -> class DbService

    constructor: (config= {}, env= 'development') ->



        log= log.namespace '[Db]'
