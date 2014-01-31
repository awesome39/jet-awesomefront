app= angular.module 'engine.users', ['ngResource','ngRoute']

app.factory '$list', () ->
    () -> console.log '$list', arguments

app.filter '$listFilter', () ->
    (list, $list) ->
        sliceStart= $list.page.number * $list.page.length
        sliceEnd= sliceStart + $list.page.length
        list.slice sliceStart, sliceEnd





###

Ресурсы

###

###
Модель пользователя.
###
app.factory 'UserModel', ($resource) ->
    $resource '/api/v1/users/:userId/:action', {userId:'@id'},

        create:
            method: 'post'

        update:
            method: 'post'
            params:
                userId: '@id'

        delete:
            method: 'delete'
            params:
                userId: '@id'

        enable:
            method: 'post'
            params:
                userId: '@id'
                action: 'enable'




###

Контроллеры

###

###
Контроллер панели управления пользователями.
###
app.controller 'UsersDashboardCtrl', ($scope, $q) ->
    $scope.state= 'ready'

###
Контроллер списка моделей пользователя.
###
app.controller 'UsersUserListCtrl', ($scope, $rootScope, $route, UserModel) ->
    $rootScope.users=
        list: UserModel.query ->
    $scope.users= $rootScope.users.list
    $scope.state= 'ready'

    $scope.$list=
        page:
            length: 7
            number: 0

    $scope.$listPrev= () ->
        $scope.$list.page.number--
    $scope.$listNext= () ->
        $scope.$list.page.number++

###
Контроллер диалога модели пользователя.
###
app.controller 'UsersUserDialogCtrl', ($scope, $rootScope, $location, UserModel) ->

    $scope.dialog.mode= $scope.dialog.route.params.mode
    $scope.dialog.location= '#/users/user/'+ $scope.dialog.route.params.userId or 0
    $scope.dialog.path= '/users/user/'+ $scope.dialog.route.params.userId or 0

    $scope.dialog.tabs=
        disabled: {}

    if 'create' == $scope.dialog.route.params.userId
        $scope.model= new UserModel
        $scope.model.emails= [{}]
        $scope.model.phones= [{}]
        $scope.dialog.tabs.disabled.account= true
    else
        $scope.model= UserModel.get $scope.dialog.route.params, (model) ->
            model.emails= [] if not model.emails
            model.phones= [] if not model.phones

    $scope.enable= (user) ->
        if not user.enabledAt
            console.log 'включить пользователя', user
            UserModel.enable {id:user.id, enabled:true}, (data) ->
                user.enabledAt= data.enabledAt
                console.log 'включен', data.enabled
        else
            console.log 'выключить пользователя', user
            UserModel.enable {id:user.id, enabled:false}, (data) ->
                user.enabledAt= data.enabledAt
                console.log 'выключен', data.enabled

    $scope.addEmail= (email) ->
        $scope.model.emails.push email or {}
    $scope.remEmail= (email) ->
        if email.id
            email.deleted= true
        else
            spliceStart= $scope.model.emails.indexOf email
            $scope.model.emails.splice spliceStart, 1
    $scope.resEmail= (email) ->
        delete email.deleted

    $scope.addPhone= (phone) ->
        $scope.model.phones.push {}
    $scope.remPhone= (phone) ->
        if phone.id
            phone.deleted= true
        else
            spliceStart= $scope.model.phones.indexOf phone
            $scope.model.phones.splice spliceStart, 1
    $scope.resPhone= (phone) ->
        delete phone.deleted

    $scope.save= (Form) ->
        if not $scope.model.id
            UserModel.create $scope.model, (model) ->
                    if $rootScope.users and $rootScope.users.list
                        $rootScope.users.list.unshift model
                    $location.path $scope.dialog.path
            ,   (err) ->
                    console.error 'не удалось создать пользователя', err
        else
            UserModel.update $scope.model, (model) ->
                    $location.path $scope.dialog.path
            ,   (err) ->
                    console.error 'не удалось обновить пользователя', err
