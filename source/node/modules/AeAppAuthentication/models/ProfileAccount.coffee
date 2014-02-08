deferred= require 'deferred'

#
# Profile Group Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Group, log) -> class ProfileAccount extends Account

    @table= 'profile_account'

    @Account: Account
