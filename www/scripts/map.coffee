#Initial map code based on http://bost.ocks.org/mike/map/ 


# Setup map appearance 
width = 960
height = 1160

projection = d3.geo.albers()
    .center([0, 55.4])
    .rotate([4.4, 0])
    .parallels([50, 60])
    .scale(1200 * 5)
    .translate([width / 2, height / 2])

path = d3.geo.path()
    .projection(projection)

svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)

# load UK map data distillery locations 
queue()
    .defer(d3.json, "uk.json")
    .defer(d3.csv, "whiskies.csv")
    .await (error, uk, whiskies) ->
        window.whiskyCoords = ([w.Longitude, w.Latitude] for w in whiskies)
    
        #draw map backgrounds
        svg.selectAll(".subunit")
            .data(topojson.feature(uk, uk.objects.subunits).features)
            .enter().append("path")
            .attr("class", (d) -> "subunit " + d.id)
            .attr("d", path)
        #draw borders
        svg.append("path")
            .datum(topojson.mesh(uk, uk.objects.subunits, (a, b) -> a != b)) # select borders
            .attr("d", path)
            .attr("class", "subunit-boundary")
        #draw distilleries
        svg.append("path")
            .datum(type: "MultiPoint", coordinates: window.whiskyCoords)
            .attr("class", "points")
            .attr("d", path)     

