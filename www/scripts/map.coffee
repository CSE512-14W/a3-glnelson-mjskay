# Setup maps 
width = 600
height = 550#1160


#SPEYSIDE INSET
W.speyside = speyside = { 
    svg: d3.select("#maps").append("div").append("svg")
        .attr("width", width/2)
        .attr("height", height/3)
        .attr("class", "inset-map")
        .style("position", "relative")
        .style("left", 100)
        .style("top", 10)

    projection: d3.geo.albers()
        .center([0, 55.4])
        .rotate([4.4, 0])
        .parallels([50, 60])
        .scale(1200 * 13)
        .translate([width / 4 - 240, height / 3 + 500])

    #approx bounds of inset in long/lat
    p0: [-3.719788, 57.216634]
    p1: [-1.676331, 57.879816]
} 

#MAIN MAP
W.scotland = scotland = {
    #d3 map object used for building map
    svg: d3.select("#maps").append("div").append("svg")
        .attr("width", width - 200)
        .attr("height", height)
        .attr("class", "map")

    #projection used to map long/lat to cartesian coords
    projection: d3.geo.albers()
        .center([0, 55.4])
        .rotate([4.4, 0])
        .parallels([50, 60])
        .scale(1200 * 5)
        .translate([width / 2 - 100, height / 2 + 160])
}

#ISLAY INSET
W.islay = islay = { 
    svg: d3.select("#maps").append("div").append("svg")
        .attr("width", width/3)
        .attr("height", height/3)
        .attr("class", "inset-map")
        .style("position", "relative")
        .style("top", "-5")

    projection: d3.geo.albers()
        .center([0, 55.4])
        .rotate([4.4, 0])
        .parallels([50, 60])
        .scale(1200 * 23)
        .translate([width / 4 + 440, height / 3 + 90])

    #approx bounds of inset in long/lat
    p0: [-6.597748, 55.551942]
    p1: [-5.81337, 55.983019]
} 


insets = [
    speyside
    islay
]


#map transition duration in ms
transitionMs = 500

###
Return a class to assign to the circle representing this whisky
###
whiskyCircleClass = (whisky) ->
    class_ = (if whisky.selected 
        "selected" 
    else if whisky.top5
        "top5"
    else if whisky.bottom5
        "bottom5"
    else "")
    if whisky.brushed
        class_ + " brushed"
    else
        class_

    

### 
Draw/redraw map points given a set of whiskies. Updates attributes
that are mapped to distillery distance from baseline, etc.
 
whiskies: array of whiskies, e.g. rows from whisky.csv
### 
redrawMap = ({svg, projection}, whiskies) ->
    #create voronoi for selection and add to clone of data
    #this must be below the points so that points win out over the voronoi
    #cells when clicking
    positions = (projection([d.Longitude, d.Latitude]) for d in whiskies)
    polygons = d3.geom.voronoi(positions)
    #join polygons with key
    whiskyPolygons = ({polygon: polygons[i], key: W.whiskyKey(w)}\ 
        for w, i in whiskies when polygons[i]?
        )
    
    g = svg.selectAll("g#voronoi")
        .data(whiskyPolygons, (d) -> d.key)
        .enter()
        .append("g")
        .attr("id", "voronoi")
 
    g.append("path")
        .attr("d", (d) -> "M" + d.polygon.join("L") + "Z")
        .on "click", (d) ->  # click to select 
            W.selectWhiskyByKey(d.key)
            W.redraw()
        .on "mouseover", (d) ->
            W.brushWhiskyByKey(d.key)
            W.redraw(sortChanged=false)
        .on "mouseout", (d) ->
            W.unbrush()
            W.redraw(sortChanged=false)
                


    distilleries = svg.selectAll("circle")
        .data(whiskies, W.whiskyKey)

    #update existing distilleries
    distilleries
        .transition().duration(transitionMs)
        .attr("r", W.whiskyDistance)
        .attr("class", whiskyCircleClass)

    #create non-existing ones    
    distilleries
        .enter().append("circle")
            .attr("cx", (d) -> projection([d.Longitude, d.Latitude])[0])
            .attr("cy", (d) -> projection([d.Longitude, d.Latitude])[1])
            .attr("r", 0)
            .on "click", (d) ->  # click to select 
                W.selectWhiskyByKey(W.whiskyKey(d))
                W.redraw()
            .on "mouseover", (d) ->
                W.brushWhiskyByKey(W.whiskyKey(d))
                W.redraw(sortChanged=false)
            .on "mouseout", (d) ->
                W.unbrush()
                W.redraw(sortChanged=false)
            .transition().duration(transitionMs)
            .attr("r", W.whiskyDistance)
            .attr("class", whiskyCircleClass)
            
    #remove exiting ones
    distilleries
        .exit()
            .transition().duration(transitionMs)
            .attr("r", 0)
            .remove()
            
###
Return true if a distillery is to be shown on this inset map
instead of the main map
###
isWhiskyInInset = (whisky, map) ->
    return map.p0[0] < whisky.Longitude < map.p1[0] and map.p0[1] < whisky.Latitude < map.p1[1]

###
Return true if a distillery is to be shown on an inset map
instead of the main map
###
isWhiskyInAnyInset = (whisky) ->
    for map in insets
        if isWhiskyInInset(whisky, map)
            return true
    false
    
###
Redraw all maps / insets
###
W.redrawMaps = (whiskies) -> 
    #first, draw main map with points in insets omitted
    whiskySubset = (w for w in whiskies when not isWhiskyInAnyInset(w))
    redrawMap(scotland, whiskySubset)

    #then, draw inset maps
    for map in insets 
        # restrict point set if we are an inset
        whiskySubset = (w for w in whiskies when isWhiskyInInset(w, map))
        redrawMap(map, whiskySubset)
            
###
Draw a given map (basic geometry, no data)
###
drawMap = (uk, {svg, projection}) ->
    ###
    path projection: function taking an array of [long, lat]s and returning an svg path
    string (value of <path d="...">) projected into map space following the points in the array.
    Used to draw paths on the map.
    ###
    projectPath = d3.geo.path()
        .projection(projection)

    #Portions originally based on http://bost.ocks.org/mike/map/ 

    #draw map backgrounds
    svg.selectAll(".subunit")
        .data(topojson.feature(uk, uk.objects.subunits).features)
        .enter().append("path")
        .attr("class", (d) -> "subunit " + d.id)
        .attr("d", projectPath)

    #draw borders
    svg.append("path")
        .datum(topojson.mesh(uk, uk.objects.subunits, (a, b) -> a != b)) # select borders
        .attr("d", projectPath)
        .attr("class", "subunit-boundary")
            
W.setupMaps = (uk) ->
    #MAIN MAP SETUP
    drawMap(uk, scotland)

    #INSET MAPS        
    for inset in insets
        #draw inset outline on main map
        p0 = scotland.projection(inset.p0)
        p1 = scotland.projection(inset.p1)
        scotland.svg.append("rect")
            .attr("x", p0[0])
            .attr("y", p1[1])
            .attr("width", Math.abs(p1[0] - p0[0]))
            .attr("height", Math.abs(p1[1] - p0[1]))
            .attr("class", "inset-region")
            
        #draw inset map
        drawMap(uk, inset)

    #ZOOM MARKERS
    zoomLines = [
            [[102,6],[239,173]]
            [[400,6],[352,173]]
            [[1,550],[71,418]]
            [[202,550],[118,418]]
        ]
    for line in zoomLines
        scotland.svg.append("path")
            .attr("d", d3.svg.line()(line))
            .attr("class", "inset-zoom-line")
    

    #DISTILLERIES
    #draw distilleries / updateable attributes
    W.redrawMaps(W.whiskies)
