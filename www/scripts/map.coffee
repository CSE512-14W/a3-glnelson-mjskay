#whisky key function for joining data
whiskyKey = (whisky) -> whisky.RowID

# Setup map 
width = 960
height = 1160

#d3 map object used for building map
map = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)

# Setup map projection
projection = d3.geo.albers()
    .center([0, 55.4])
    .rotate([4.4, 0])
    .parallels([50, 60])
    .scale(1200 * 5)
    .translate([width / 2, height / 2])

###
path projection: function taking an array of [long, lat]s and returning an svg path
string (value of <path d="...">) projected into map space following the points in the array.
Used to draw paths on the map.
###
projectPath = d3.geo.path()
    .projection(projection)

### 
Draw/redraw map points given a set of whiskies. Updates attributes
that are mapped to distillery distance from baseline, etc.
 
whiskies: array of whiskies, e.g. rows from whisky.csv
### 
redrawMap = (whiskies) ->
    distilleries = map.selectAll("circle")
        .data(whiskies, whiskyKey)

    #update existing distilleries
    distilleries
        .transition()
        .attr("r", (d) -> Math.random() * 5 + 1)        #TODO: map this to distance

    #create non-existing ones    
    distilleries
        .enter().append("circle")
            .attr("cx", (d) -> projection([d.Longitude, d.Latitude])[0])
            .attr("cy", (d) -> projection([d.Longitude, d.Latitude])[1])
            .attr("r", 0)
            .transition()
            .attr("r", (d) -> Math.random() * 5 + 1)    #TODO: map this to distance
            
    #remove exiting ones
    distilleries
        .exit()
            .transition()
            .attr("r", 0)
            .remove()
            
# load UK map data and distillery data
queue()
    .defer(d3.json, "uk.json")
    .defer(d3.csv, "whiskies.csv")
    .await (error, uk, whiskies) ->

        #INITIAL MAP SETUP
        #Based on http://bost.ocks.org/mike/map/ 

        #draw map backgrounds
        map.selectAll(".subunit")
            .data(topojson.feature(uk, uk.objects.subunits).features)
            .enter().append("path")
            .attr("class", (d) -> "subunit " + d.id)
            .attr("d", projectPath)

        #draw borders
        map.append("path")
            .datum(topojson.mesh(uk, uk.objects.subunits, (a, b) -> a != b)) # select borders
            .attr("d", projectPath)
            .attr("class", "subunit-boundary")

        #draw distilleries / updateable attributes
        redrawMap(whiskies)




        #save some globals for exploring in-browser
        window.map = map
        window.redrawMap = redrawMap
        window.whiskies = whiskies
