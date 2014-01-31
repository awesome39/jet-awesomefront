app= angular.module 'engine.reports', ['ngResource','ngRoute']

app.controller 'ReportsDashboardCtrl', ($scope, debug) ->
    if debug then debug.log 'ReportsDashboardCtrl...'
