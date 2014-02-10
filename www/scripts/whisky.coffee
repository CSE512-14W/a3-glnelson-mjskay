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

W.columnNames = [
            "RowID": {include: true, show: true},
            "Distillery": {include: true, show: true},
            "Body": {include: true, show: true},
            "Sweetness": {include: true, show: true},
            "Smoky": {include: true, show: true},
            "Medicinal": {include: true, show: true},
            "Tobacco": {include: true, show: true},
            "Honey": {include: true, show: true},
            "Spicy": {include: true, show: true},
            "Winey": {include: true, show: true},
            "Nutty": {include: true, show: true},
            "Malty": {include: true, show: true},
            "Fruity": {include: true, show: true},
            "Floral": {include: true, show: true},
            "Postcode": {include: true, show: true},
            "Longitude": {include: true, show: true},
            "Latitude": {include: true, show: true},
            "distance": {include: true, show: true},
            "selected": {include: false, show: true}
            ];
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
            "Longitude",
            "Latitude",
            "distance",
            "top5"
            "bottom5"
            ];


W.flavorColumnNames = () ->
    W.tableColumnNames[1..12]

###
Convenience methods for selections of data
###

W.top5 = () ->
  (w for w in W.whiskies when w.top5)

W.bot5 = () ->
  (w for w in W.whiskies when w.top5)

W.filteredWhiskies = () ->
  W.whiskies #TODO

###
Redraw maps and table
###
W.redraw = () ->
    #recalcuate distances
    flavorColumns = W.flavorColumnNames() 
    for whisky in W.whiskies
        #euclidean distance
        whisky.distance = Math.sqrt(
            ((W.selectedWhisky[c] - whisky[c]) ** 2 for c in flavorColumns)
            .reduce((a,b) -> a + b))
        whisky.top5 = false
        whisky.bottom5 = false

    #assign mostSimilar / leastSimilar boolean columns to top/last 5
    sortedWhiskies = W.whiskies.slice(0)    #clone
    sortedWhiskies.sort((a, b) -> a.distance - b.distance)
    for w in sortedWhiskies[1..5]
        w.top5 = true
    for w in sortedWhiskies[-5..]
        w.bottom5 = true

    W.redrawMaps(W.whiskies)
    W.drawTable("#all", W.whiskies, W.tableColumnNames)


###
Given a key, select that whisky (and only that whisky)
###
W.selectWhiskyByKey = (key) ->
    for whisky in W.whiskies
        whisky.selected = W.whiskyKey(whisky) == key
        if whisky.selected
            W.selectedWhisky = whisky

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

