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

W.columnNames = {
            "RowID": {distance_include: false, show: true},
            "Distillery": {distance_include: false, show: true},
            "Body": {distance_include: true, show: true},
            "Sweetness": {distance_include: true, show: true},
            "Smoky": {distance_include: true, show: true},
            "Medicinal": {distance_include: true, show: true},
            "Tobacco": {distance_include: true, show: true},
            "Honey": {distance_include: true, show: true},
            "Spicy": {distance_include: true, show: true},
            "Winey": {distance_include: true, show: true},
            "Nutty": {distance_include: true, show: true},
            "Malty": {distance_include: true, show: true},
            "Fruity": {distance_include: true, show: true},
            "Floral": {distance_include: true, show: true},
            "Postcode": {distance_include: false, show: true},
            "Longitude": {distance_include: false, show: true},
            "Latitude": {distance_include: false, show: true},
            "distance": {distance_include: false, show: true},
            "selected": {distance_include: false, show: true}
            }
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
            ];


W.flavorColumnNames = () ->
  W.tableColumnNames[1..12]

W.distanceColumnNames = () ->
  (key for key, value of W.columnNames when value.distance_include)

###
Convenience methods for selections of data
###

W.top5 = () ->
  (w for w in W.whiskies when w.top5)

W.bot5 = () ->
  (w for w in W.whiskies when w.bottom5)

W.filteredWhiskies = () ->
  W.whiskies #TODO

###
Redraw maps and table
###
W.redraw = (sortChanged=true) ->
    if sortChanged
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
    
    #only redraw table if sort changed
    if sortChanged
        W.drawTables()

    W.updateTableBrush()


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
                selected: false #d.RowID == "4" # default value
                top5: false
                bottom5: false
              } for d in whiskies)
        
        W.setupTable()
        W.setupMaps(uk)
        #W.redraw() #tried to fix page load blank tables, causes type error

