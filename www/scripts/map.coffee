###
Return the key for joining whisky data in d3
###
whiskyKey = (whisky) -> whisky.RowID

###
Return the distance measure for ordering the given whisky
###
whiskyDistance = (whisky) -> Math.random() * 5 + 1    #TODO: properly map this to distance

# Setup maps 
width = 600
height = 550#1160


#SPEYSIDE INSET
speyside = { 
    svg: d3.select("body").append("div").append("svg")
        .attr("width", width/2)
        .attr("height", height/3)
        .style("border", "1px solid #ddd")

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
scotland = {
    #d3 map object used for building map
    svg: d3.select("body").append("div").append("svg")
        .attr("width", width - 200)
        .attr("height", height)
        .style("border", "1px solid #ddd")

    #projection used to map long/lat to cartesian coords
    projection: d3.geo.albers()
        .center([0, 55.4])
        .rotate([4.4, 0])
        .parallels([50, 60])
        .scale(1200 * 5)
        .translate([width / 2 - 100, height / 2 + 160])
}

insets = [
    speyside
]


### 
Draw/redraw map points given a set of whiskies. Updates attributes
that are mapped to distillery distance from baseline, etc.
 
whiskies: array of whiskies, e.g. rows from whisky.csv
### 
redrawMap = ({svg, projection}, whiskies) ->
    distilleries = svg.selectAll("circle")
        .data(whiskies, whiskyKey)

    #update existing distilleries
    distilleries
        .transition()
        .attr("r", whiskyDistance)

    #create non-existing ones    
    distilleries
        .enter().append("circle")
            .attr("cx", (d) -> projection([d.Longitude, d.Latitude])[0])
            .attr("cy", (d) -> projection([d.Longitude, d.Latitude])[1])
            .attr("r", 0)
            .transition()
            .attr("r", whiskyDistance)
            
    #remove exiting ones
    distilleries
        .exit()
            .transition()
            .attr("r", 0)
            .remove()
    
###
Return true if a distillery is to be shown on an inset map
instead of the main map
###
isWhiskyInInset = (whisky) ->
    for map in insets
        if map.p0[0] < whisky.Longitude < map.p1[0] and map.p0[1] < whisky.Latitude < map.p1[1]
            return true
    false
    
###
Redraw all maps / insets
###
redrawMaps = (whiskies) -> 
    #first, draw main map with points in insets omitted
    whiskySubset = (w for w in whiskies when not isWhiskyInInset(w))
    redrawMap(scotland, whiskySubset)

    #then, draw inset maps
    for map, i in insets 
        redrawMap(map, whiskies)
            
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

    #Based on http://bost.ocks.org/mike/map/ 

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
            
# load UK map data and distillery data
queue()
    .defer(d3.json, "uk.json")
    .defer(d3.csv, "whiskies.csv")
    .await (error, uk, whiskies) ->

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
                .attr("class", "inset")
                
            #draw inset map
            drawMap(uk, inset)

        #DISTILLERIES
        #draw distilleries / updateable attributes
        redrawMaps(whiskies)

        #save some globals for exploring in-browser
        window.scotland = scotland
        window.insets = insets
        window.redrawMap = redrawMap
        window.redrawMaps = redrawMaps
        window.whiskies = whiskies
