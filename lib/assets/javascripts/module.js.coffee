angular.module "GraphPaper", []

@TestController = ($scope) ->
    $scope.settings = 
      editing: true
      origin: 
        x: 10*25
        y: 11*25
      images: [
        path: "/test_image.png"
      ]
    $scope.$watch 'settings.origin', (nv,ov) -> console.log nv