app= angular.module 'engine'
,   ['engine.users', 'engine.reports', 'ngResource', 'ngRoute']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'

