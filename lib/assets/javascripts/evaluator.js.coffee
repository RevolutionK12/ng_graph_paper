@GraphPaper ?= {}
@GraphPaper.Evaluator = class Evaluator

  constructor: (graph_paper_data) ->
    
    data = JSON.parse(graph_paper_data)
    @lines    = data.lines
    @points   = data.points
    @linesByPoint = {}
    @gridSize = data.gridSize

    _.each @lines, (l) ->
      l.distance = @distance(l)
      l.p1.id = "#{l.p1[0]}_#{l.p1[1]}"
      l.p2.id = "#{l.p2[0]}_#{l.p2[1]}"
    , this
    @lines = _.sortBy @lines, (l) ->
      l.distance
    _.each @points, (p, idx) ->
      this["p#{idx+1}"] = p
      p.id = "#{p[0]}_#{p[1]}"
    , this
    #setup convenience functions to get at the lines by size
    _.each @lines, (l, idx) ->
      this["l#{idx+1}"] = l
      @linesByPoint[l.p1.id] ?= []
      @linesByPoint[l.p2.id] ?= []
      @linesByPoint[l.p1.id].push(l)
      @linesByPoint[l.p2.id].push(l)
    , this


  slope: (line) ->
    sl = if line.p1[1] == line.p2[1]
        0
      else if line.p1[0] == line.p2[0]
        'undefined'
      else
        (line.p1[1] - line.p2[1]) / (line.p1[0] - line.p2[0])
    console.log(sl)
    sl

  distance: (line) ->
      Math.sqrt(Math.pow(line.p1[0] - line.p2[0], 2) + Math.pow(line.p1[1] - line.p2[1],2)) / @gridSize

  isTriangle: ->
      @lines.length == 3 and @points.length == 3

  isRightTriangle: ->
      @isTriangle() and (
        (Math.abs((Math.pow(@distance(@l1),2) + Math.pow(@distance(@l2),2)) - Math.pow(@distance(@l3),2)) < 0.000001)
      )

  areaOfTriangle: ->
      Math.abs(((@p1[0]*(@p2[1] - @p3[1])) + (@p2[0]*(@p3[1]-@p1[1])) + @p3[0]*(@p1[1]-@p2[1]))/2) / (@gridSize*@gridSize)

  isPolygon: (sides) ->
    @lines.length = sides and @points.length == sides

  findPoint: (x,y) ->
    #this will be adjusted based on gridsize so that the user doesn't ahve to do that calc
    id = "#{x*@gridSize}_#{y*@gridSize}"
    (_.find @points, (p) -> p.id == id)?

  isRectangle: ->
    if @isPolygon(4)
      _.all [@p1, @p2, @p3, @p4], (p) ->
        corner = @linesByPoint[p.id]
        (@slope(corner[0]) == 'undefined' and @slope(corner[1]) == 0) or 
          (@slope(corner[0]) == 0 and @slope(corner[1]) == 'undefined') or
            (@slope(corner[0]) == (-1/@slope(corner[1]))) 
      , this
    else
      false

  evaluateAnswer: (answer) ->
    console.log "in evaluate"
    isTriangle      = () => 
      @isTriangle()
    isRightTriangle = () =>
      @isRightTriangle()
    distance        = (args) =>
      @distance(args)
    slope           = (args) =>
      @slope(args)
    areaOfTriangle  = (args) =>
      @areaOfTriangle(args)
    isRectangle = () =>
      @isRectangle()
    isPolygon = (args) => 
      @isPolygon(args)
    findPoint = (x,y) =>
      @findPoint(x,y)

    !!eval(answer)