###
Common code for whisky dataset
###

###
Return the key for joining whisky data in d3
###
W.whiskyKey = (whisky) -> whisky.RowID

###
Return the distance measure for distilleries on the map
###
W.whiskyDistance = (whisky) -> (13 - whisky.distance)**2 / 169 * 10

W.columnNames = ["RowID",
            "Distillery",
            "Body",
            "Sweetness",
            "Smoky",
            "Medicinal",
            "Tobacco",
            "Honey",
            "Spicy",
            "Winey",
            "Nutty",
            "Malty",
            "Fruity",
            "Floral",
            "Postcode",
            "Longitude",
            "Latitude",
            "distance",
            "selected"];
W.tableColumnNames = [     # dictionary
            "Distillery",
            "Body",
            "Sweetness",
            "Smoky",
            "Medicinal",
            "Tobacco",
            "Honey",
            "Spicy",
            "Winey",
            "Nutty",
            "Malty",
            "Fruity",
            "Floral",
            "Postcode",
            "Longitude",
            "Latitude",
            "distance",
            "top5"
            "bottom5"
            ];


W.flavorColumnNames = () ->
    W.tableColumnNames[1..12]

###
Redraw maps and table
###
W.redraw = () ->
    if W.selectedWhisky?
        #recalcuate distances
        flavorColumns = W.flavorColumnNames() 
        for whisky in W.whiskies
            #euclidean distance
            whisky.distance = Math.sqrt(
                ((W.selectedWhisky[c] - whisky[c]) ** 2 for c in flavorColumns)
                .reduce((a,b) -> a + b))
            whisky.top5 = false
            whisky.bottom5 = false
    else 
        for whisky in W.whiskies
            whisky.distance = 3     #default when nothing selected
            whisky.top5 = false
            whisky.bottom5 = false
            

    #assign mostSimilar / leastSimilar boolean columns to top/last 5
    sortedWhiskies = (w for w in W.whiskies when not w.selected)    #clone + skip selected
    sortedWhiskies.sort((a, b) -> a.distance - b.distance)
    for w in sortedWhiskies[0..4]
        w.top5 = true
    for w in sortedWhiskies[-5..]
        w.bottom5 = true

    W.redrawMaps(W.whiskies)
    W.drawTable("#baseline", W.whiskies, W.tableColumnNames)


###
Given a key, select that whisky (and only that whisky)
###
W.selectWhiskyByKey = (key) ->
    for whisky in W.whiskies
        whisky.selected = W.whiskyKey(whisky) == key
        if whisky.selected
            W.selectedWhisky = whisky

# key of brushed whisky, or null if none brushed (e.g. whisky the mouse is over)
W.brushedWhisky = null

###
Given a key, brush that whisky (and only that whisky)
###
W.brushWhiskyByKey = (key) ->
    for whisky in W.whiskies
        whisky.brushed = W.whiskyKey(whisky) == key
        if whisky.brushed
            W.brushedWhisky = whisky

###
Set no whisky to be brushed
###
W.unbrush = () ->
    for whisky in W.whiskies
        whisky.brushed = false
    W.brushedWhisky = null
    

queue()
    .defer(d3.json, "uk.json")
    .defer(d3.csv, "whiskies.csv")
    .await (error, uk, whiskies) ->
        W.whiskies = ({
                RowID: d.RowID,
                Distillery: d.Distillery,
                Body: +d.Body,
                Sweetness: +d.Sweetness,
                Smoky: +d.Smoky,
                Medicinal: +d.Medicinal,
                Tobacco: +d.Tobacco,
                Honey: +d.Honey,
                Spicy: +d.Spicy,
                Winey: +d.Winey,
                Nutty: +d.Nutty,
                Malty: +d.Malty,
                Fruity: +d.Fruity,
                Floral: +d.Floral,
                Postcode: d.Postcode,
                Longitude: +d.Longitude,
                Latitude: +d.Latitude,
                distance: 3, # default value
                selected: d.RowID == "4" # default value
                top5: false
                bottom5: false
              } for d in whiskies)
        
        W.setupTable()
        W.setupMaps(uk)

