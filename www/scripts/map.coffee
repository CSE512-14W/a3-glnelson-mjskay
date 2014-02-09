#Initial map code based on http://bost.ocks.org/mike/map/ 


#some globals for exploring in-browser
`
var map;
var whiskies;
var whiskyKey;
`

# Setup map appearance 
width = 960
height = 1160

projection = d3.geo.albers()
    .center([0, 55.4])
    .rotate([4.4, 0])
    .parallels([50, 60])
    .scale(1200 * 5)
    .translate([width / 2, height / 2])

#path projection: function taking an array of [long, lat]s and returning an svg
#path (value of "d" attribute) projected into map space following the points in the array.
projectPath = d3.geo.path()
    .projection(projection)

map = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)

#whisky key function for joining data
whiskyKey = (whisky) -> whisky.RowID

# load UK map data distillery locations 
queue()
    .defer(d3.json, "uk.json")
    .defer(d3.csv, "whiskies.csv")
    .await (error, uk, whiskies) ->

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

        #draw distilleries
        map.selectAll("circle")
            .data(whiskies, whiskyKey)
            .enter().append("circle")
                .attr("cx", (d) -> projection([d.Longitude, d.Latitude])[0])
                .attr("cy", (d) -> projection([d.Longitude, d.Latitude])[1])
                .attr("r", (d) -> Math.random() * 5 + 1)
            

        #map.append("path")
        #    .datum(type: "MultiPoint", coordinates: whiskyCoords)
        #    .attr("class", "points")
        #    .attr("d", path)     

