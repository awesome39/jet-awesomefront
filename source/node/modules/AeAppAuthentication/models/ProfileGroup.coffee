deferred= require 'deferred'

#
# Profile Group Model Factory
#
# @author Michael F <tehfreak@awesome39.com>
#
module.exports= (Group, log) -> class ProfileGroup extends Group

    @table= 'profile_group'

    @Group: Group
