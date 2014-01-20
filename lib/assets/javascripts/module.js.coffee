angular.module "GraphPaper", []

@TestController = ($scope) ->
    $scope.settings = 
      editing: false
      origin: false
      images: [
      ]
    $scope.$watch 'settings.origin', (nv,ov) -> console.log nv