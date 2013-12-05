app = angular.module 'GraphPaper'

app.filter 'cursor', () ->
  (input) ->
    if input?
      if _.contains(['pointing', 'lining'], input)
        'pointer'
      else
        'default'

class Line 
  constructor: (startx, starty, @paper) ->
    @p1 = @paper.circle(startx, starty, 5).attr({fill: '#ff0000', stroke: 'none'})
    @p2 = @paper.circle(startx+6, starty+6, 5).attr({fill: '#ff0000', stroke: 'none'})
    @updatePath()
    _by_id = []
    _by_id[@p1.id] = @p1
    _by_id[@p2.id] = @p2

  findByPoint: (point) ->
    @p1.id == point.id || @p2.id == point.id
  dragging: (x,y) ->
    @p2.attr({cx: x, cy: y})
    @updatePath()
  path_string: -> 
    "M #{@p1.attrs.cx} #{@p1.attrs.cy} L #{@p2.attrs.cx} #{@p2.attrs.cy}"
  updatePath: ->
    if @path
      @path.attr path: @path_string()
    else
      @path = @paper.path(@path_string()).attr({stroke:'#ff0000', 'stroke-width': 1})
  movePoint: (p, x, y) ->
    p.attr({cx: x, cy: y}) 
    @updatePath()
  length: () ->
    Math.sqrt(Math.pow(@p1.attrs.cx - @p2.attrs.cx, 2) + Math.pow(@p1.attrs.cy - @p2.attrs.cy,2))
  remove: () ->
    @path.remove()
  toString: ->
    "#{Math.min(@p1.id, @p2.id)}_#{Math.max(@p1.id, @p2.id)}"

app.directive 'graphPaper', () ->
  restrict: 'A'
  scope: 
    'width'    : '@'
    'height'   : '@'
    'answer'   : '='
    'settings' : '='
    'model'    : '='
    'correct'  : '='
  template: 
    """
      <div>
        <div class='header' ng-hide='settings.editing'>
          <a class="btn btn-small" ng-click='cursor()' ng-class="{active: mode=='cursor'}"><i class="icon-arrow-left"></i> Pointer </a>
          <a class="btn btn-small" ng-click="toggleDeleteTool()" ng-class="{active: mode=='deleting'}"><i class="icon-remove"></i> Delete</a>
          <a class="btn btn-small" ng-click="togglePointTool()" ng-class="{active: mode=='pointing'}"><i class="icon-hand-up"></i> Point Tool</a>
          <a class="btn btn-small" ng-click="toggleLineTool()" ng-class="{active: mode=='lining'}"><i class="icon-minus"></i> Line Tool</a>
        </div>
        <br />
        <div class="canvas" ng-style="{cursor: (mode|cursor)}"></div>
        <input type='hidden' ng-value="points_and_lines"/>
      </div>
    """
  replace: true
  controller: [ "$scope", "$element", "$attrs", ($scope, $element, $attrs) ->

    $scope.points = []
    $scope.lines  = []

    $scope.mode         = 'cursor'
    $scope.adding_point = false
    $scope.adding_line  = false

    $scope.addPoint = (p) ->
      $scope.points[p.id] = p
      _update()
      p

    $scope.removePoint = (p_id) ->
      p = $scope.points[p_id]
      $scope.points[p_id] = null
      if (values = _.filter($scope.lines, (l) -> l.findByPoint(p))).length > 0
        _.each values, (v) -> 
          v.remove()
          $scope.lines = _.without($scope.lines, v)
      _update()
      p

    $scope.addLine = (line) ->
      if _line = $scope.findLine(line)
        line.remove()
        _line
      else
        $scope.lines.push line
        $scope.addPoint(line.p1)
        $scope.addPoint(line.p2)
        _update()
        line

    $scope.togglePointTool = ->
      if $scope.mode != 'pointing'
        $scope.mode = 'pointing'
      else
        $scope.mode = 'cursor'

    $scope.toggleLineTool = ->
      if $scope.mode != 'lining'
        $scope.mode = 'lining'
      else
        $scope.mode = 'cursor'

    $scope.toggleDeleteTool = ->
      if $scope.mode != 'deleting'
        $scope.mode = 'deleting'
      else
        $scope.mode = 'cursor'

    $scope.getPoint = (id) ->
      $scope.points[id]

    $scope.findPoint = (x,y) ->
      _.find _.compact($scope.points), (p) ->
        p.attrs.cx == x and p.attrs.cy == y

    $scope.findLine = (line) ->
      _.find $scope.lines, (l) ->
        l.toString() == line.toString()

    $scope.cursor = ->
      $scope.mode = 'cursor'

    _lines_to_s = ->
      ls = _.collect $scope.lines, (l) ->
        "{'p1':[#{l.p1.attrs.cx-$scope.padding},#{l.p1.attrs.cy-$scope.padding}],'p2':[#{l.p2.attrs.cx-$scope.padding},#{l.p2.attrs.cy-$scope.padding}]}"
      "[#{ls.join(',')}]"

    _points_to_s = ->
      ps = _.collect _.compact(_.flatten($scope.points)), (p) ->
        "[#{p.attrs.cx-$scope.padding},#{p.attrs.cy-$scope.padding}]"
      "[#{ps.join(',')}]"

    $scope.points_and_lines = ->
      "{\"lines\":#{_lines_to_s()},\"points\":#{_points_to_s()}, \"gridSize\":25}"

    _evaluate = ->
      $scope.correct = 
        try
          gp = new GraphPaper.Evaluator($scope.points_and_lines())
          a = gp.evaluateAnswer($scope.answer)
          a
        catch error
          console.log error
          false

    _update = ->
      $scope.$apply ->
        $scope.model   = $scope.points_and_lines()
        _evaluate()

    $scope.$watch 'answer', () ->
      _evaluate()

  ]
  link: (scope, element, attrs) ->
    _touching = false
    _current_line = null
    _dragging = false

    gridSize = 25
    width  = parseInt attrs.width
    height = parseInt attrs.height
    scope.padding = padding = 20


    _snap_to_grid = (x,y) ->
      x: Raphael.snapTo(gridSize, x-padding, gridSize/2) + padding
      y: Raphael.snapTo(gridSize, y-padding, gridSize/2) + padding

    _create_point = (x,y) ->
      snapped = _snap_to_grid(x,y)
      unless scope.findPoint(snapped.x, snapped.y)  
        _register_actions scope.addPoint paper.circle(snapped.x, snapped.y, 5).attr({fill: '#ff0000', stroke: 'none'})

    _start_line = (x,y) ->
      snapped       = _snap_to_grid(x, y)
      _current_line = new Line(snapped.x, snapped.y, paper)
      _current_line.p2.click (e) ->
        xy = _get_x_y e
        _end_line(xy.x, xy.y)
      _current_line


    _end_line = (x,y) ->
      snapped = _snap_to_grid(x, y)
      if _current_line
        _current_line.dragging(snapped.x, snapped.y)
        #check if its of length 0
        if _current_line.length() == 0
          _current_line.remove()
          _current_line.p1.remove()
          _current_line.p2.remove()
        else
          if p1 = scope.findPoint(_current_line.p1.attrs.cx, _current_line.p1.attrs.cy)
            _current_line.p1.remove()
            _current_line.p1 = p1
          else
            _register_actions _current_line.p1
          if p2 = scope.findPoint(_current_line.p2.attrs.cx, _current_line.p2.attrs.cy)
            _current_line.p2.remove()
            _current_line.p2 = p2
          else
            _register_actions _current_line.p2

          scope.addLine(_current_line)
        _current_line = null
        _dragging = false

    _register_actions = (point) ->
      point.unmouseup()
      point.unmousedown()
      # point.unclick()
      point.mousedown (e) ->
        if Touch? && (e instanceof Touch)
          return
        else
          xy = _get_x_y e
          if scope.mode == 'lining'
            _start_line xy.x, xy.y

      point.mouseup (e) ->
        if scope.mode == 'lining'
          _mouseup e
        else if scope.mode == 'deleting'
          scope.removePoint(e.currentTarget.raphaelid).remove()

    element.find('.canvas').css
      width:  padding*2+width+'px'
      height: padding*2+height+'px'

    paper  = new Raphael(element.find('.canvas')[0], (padding*2)+width, (padding*2)+height)
    glass  = null
    points = paper.set()
    scope.image_set = paper.set()

    _draw_background = ->
      set = paper.set()
      #horizontal lines
      for Y in [gridSize..height] by gridSize
        path = paper.path "M #{padding} #{Y+padding} L #{width+padding} #{Y+padding}"
        set.push path
      for X in [gridSize..width] by gridSize
        path = paper.path "M #{X+padding} #{padding} L #{X+padding} #{width+padding}"
        set.push path
      set.attr
        stroke: '#ccccff'
        'stroke-width': '1'
      paper.rect(padding,padding,height,width).attr('stroke', '#000000')
      glass = paper.rect(padding,padding,height,width).attr('stroke': 'none').attr('fill', 'transparent')

    _draw_images = ->
      scope.image_set.remove()
      scope.image_set.clear()
      for image in scope.settings.images
        img = new Image()
        img.onload = ->
          pimage = paper.image img.src, image.x or padding, image.y or padding, img.width, img.height
          scope.image_set.push(pimage)
          if scope.settings.editing
            pimage.drag (dx, dy) ->
              this.attr x: this.x+dx, y: this.y+dy
            , ->
              this.x = this.attr('x')
              this.y = this.attr('y')
            , ->
              image.x = this.attr('x')-padding
              image.y = this.attr('y')-padding
              scope.$emit 'changed'
        img.src = image.path

    _drawAxis = (origin = null, editing = false) ->
      if origin
        Y = origin.y+padding
        X = origin.x+padding
      else
        Y = height/gridSize/2*gridSize + padding
        X = width/gridSize/2*gridSize  + padding 
        scope.settings.origin = x: X-padding, y: Y-padding
      scope.axis = lines = paper.set()
      _vert_path = (X) -> "M #{X} #{padding} L #{X} #{width+padding}"
      _horz_path = (Y) -> "M #{padding} #{Y} L #{width+padding} #{Y}"

      lines.push vert = paper.path _vert_path(X)
      lines.push horz = paper.path _horz_path(Y)
      lines.attr
        stroke: '#000000'
        'stroke-width': '2'
      
      _cart_move = (dx, dy) ->
        this.attr({cx: nx = (this.dsx + dx), cy: ny = (this.dsy + dy)});

      _cart_up = ->
        snap = _snap_to_grid this.attr('cx'), this.attr('cy') 
        X = snap.x
        Y = snap.y
        vert.attr path: _vert_path(X)
        horz.attr path: _horz_path(Y)
        this.attr 'cx', X
        this.attr 'cy', Y
        scope.settings.origin = {x: X-padding, y: Y-padding}
        _draw_labels(scope.settings.origin)
        scope.$emit 'changed'

      _cart_start = () ->
        this.dsx = this.attr('cx')
        this.dsy = this.attr('cy')

      if editing
        scope.circ = circ = paper.circle(X, Y, 7).attr
          fill: '#cccccc'
          stroke: '#000000'
          'stroke-width': '1'

        circ.hover ->
          this.attr
            'stroke': '#ff0000'
            'stroke-width': '2'
        , ->
          this.attr
            'stroke': '#000000'
            'stroke-width': '1'
        circ.drag _cart_move, _cart_start, _cart_up

      _draw_labels = (origin) ->
        scope.labels ?= paper.set()
        scope.labels.remove()
        scope.labels.clear()
        adjy = parseInt((origin.y)/gridSize)
        adjx = parseInt((origin.x)/gridSize)
        for lbl in [0..parseInt(width/gridSize)]
          if lbl-adjx != 0
            scope.labels.push paper.text(lbl*gridSize+padding, origin.y+padding+15, "#{lbl-adjx}")
            scope.labels.push paper.path "M #{lbl*gridSize+padding} #{origin.y+padding} L #{lbl*gridSize+padding} #{origin.y+padding + 5} "
        for lbl in [0..parseInt(height/gridSize)]
          if lbl-adjy != 0
            scope.labels.push paper.text(origin.x+padding+15, lbl*gridSize+padding, "#{(-1)*(lbl-adjy)}")
            scope.labels.push paper.path "M #{origin.x+padding} #{lbl*gridSize+padding} L #{origin.x + padding + 5} #{lbl*gridSize+padding}"

        scope.labels.attr({fill: "#000", 'font-family': 'monospace', 'font-size': 12}) 

      _draw_labels(scope.settings.origin)

    _drawOuterLabels = ->
      for lbl in [0..width/gridSize]
        (paper.text(lbl*gridSize+padding, padding/2, "#{lbl}").attr({fill: "#000", 'font-family': 'monospace'})) 
      for lbl in [0..height/gridSize]
        (paper.text(padding/2, lbl*gridSize+padding, "#{lbl}").attr({fill: "#000", 'font-family': 'monospace'})) 

    _draw_background()
    scope.$watch 'settings.editing', ->
      if scope.settings.editing? and scope.settings.editing
        _drawOuterLabels()    

    scope.$watch 'settings.origin', ->
      if scope.settings.origin? && scope.settings.origin
        _drawAxis(scope.settings.origin, scope.settings.editing)
      else
        if scope.axis?
          scope.axis.remove()
          scope.axis.clear()
          scope.labels.remove()
          scope.labels.clear()
          scope.circ.remove()

    scope.$watch 'settings.images', ->
      if scope.settings.images and scope.settings.images.length != scope.image_set.length
        _draw_images() 

    scope.$on 'images_changed', ->
      _draw_images()

    _get_x_y = (e) ->
      position = $('.canvas', element).offset()
      if TouchEvent? && (e instanceof TouchEvent)
        e = e.changedTouches[0]
      x: e.pageX - position.left
      y: e.pageY - position.top

    glass.drag (e) ->
      if scope.mode == 'lining' and _current_line?
        _dragging = true

    _mouseup = (e) ->
      xy = _get_x_y(e)
      if _current_line? && _dragging
        _end_line(xy.x, xy.y)
      else if (TouchEvent?) && _current_line? 
        _end_line(xy.x, xy.y)
      else if (TouchEvent?) && !_current_line?
        _start_line(xy.x, xy.y)

    glass.mousedown (e) ->
      if Touch? && (e instanceof Touch)
        return
      else
        xy = _get_x_y e
        if scope.mode == 'lining'
          unless _current_line?
            _start_line(xy.x, xy.y)

    glass.mouseup (e) ->
      xy = _get_x_y e
      if scope.mode == 'lining'
        _mouseup e
      else if scope.mode == 'pointing'
        point = _create_point(xy.x,xy.y)

    glass.mousemove (e) ->
      if Touch? && (e instanceof Touch)
        return
      else
        xy = _get_x_y e
        if scope.mode == 'lining' and _current_line?
          _dragging = true
          snapped = _snap_to_grid(xy.x, xy.y)
          _current_line.dragging(snapped.x, snapped.y)
