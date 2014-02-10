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

###
Return the key for joining column data in d3
###
W.columnKey = (column) -> column.name


W.columnNames = [
  {name: "RowID", distance_include: false, flavor: false, show: false, more: false, less: false, same:false, toggle_state:0},
  {name: "Distillery", distance_include: false, flavor: false, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Body", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Sweetness", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Smoky", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Medicinal", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Tobacco", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Honey", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Spicy", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Winey", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Nutty", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Malty", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Fruity", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Floral", flavor: true, distance_include: true, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "Postcode", distance_include: false, flavor: false, show: false, more: false, less: false, same:false, toggle_state:0},
  {name: "Longitude", distance_include: false, flavor: false, show: false, more: false, less: false, same:false, toggle_state:0},
  {name: "Latitude", distance_include: false, flavor: false, show: false, more: false, less: false, same:false, toggle_state:0},
  {name: "distance", flavor: false, distance_include: false, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "top5", flavor: false, distance_include: false, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "bottom5", flavor: false, distance_include: false, show: true, more: false, less: false, same:false, toggle_state:0},
  {name: "selected", flavor: false, distance_include: false,  show: false, more: false, less: false, same:false, toggle_state:0}];

###
use if implement value filtering

W.max = 4
W.min = 0

W.includeAll = (c) ->
  c.more=W.min
  c.less=W.max
  c.same=false

(W.includeAll(c) for c in W.columnNames)

###

W.columnFilterName = (c) ->
  if c.more
    "> "+c.name
  else if c.same
    "= "+c.name
  else if c.less
    "< "+c.name
  else
    c.name

W.clearFilter = (c) ->
  c.more = false
  c.less = false
  c.same = false

W.toggleColumn = (c) ->
  if not c.distance_include
    c.distance_include = true
    W.clearFilter(c)
  else if c.distance_include and (not c.more) and (not c.less) and (not c.same)
    c.more = true
  else if c.distance_include and (c.more) and (not c.less) and (not c.same)
    c.more = false
    c.same = true
  else if c.distance_include and (not c.more) and (not c.less) and (c.same)
    c.same = false
    c.less = true
  else if c.distance_include and (not c.more) and (c.less) and (not c.same)
    c.less = false
    c.distance_include = false


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
  (W.columnKey(c) for c in W.columnNames when c.distance_include)

W.toggleColumnByKey = (key) ->
  (W.toggleColumn(c) for c in W.columnNames when W.columnKey(c) == key)

W.whiskyInFilter = (w) ->
   (((
     if w.selected
       true
     else if c.less
       w[c.name] < W.selectedWhisky[c.name]
     else if c.more
       w[c.name] > W.selectedWhisky[c.name]
     else if c.same
       w[c.name] == W.selectedWhisky[c.name]
     else
       true
    ) for c in W.columnNames)
   ).reduce((a,b) -> a and b)

###
Convenience methods for selections of data
###

W.top5 = () ->
  (w for w in W.whiskies when w.top5)

W.bot5 = () ->
  (w for w in W.whiskies when w.bottom5)

W.filteredWhiskies = () ->
  ( w for w in W.whiskies when W.whiskyInFilter(w))

###
Redraw maps and table
###
W.redraw = (sortChanged=true) ->
    if sortChanged
        if W.selectedWhisky?
            #recalcuate distances
            flavorColumns = W.flavorColumnNames()
            distanceColumns = W.distanceColumnNames() 
            for whisky in W.whiskies
                #euclidean distance
                whisky.distance = Math.sqrt(
                    ((W.selectedWhisky[c] - whisky[c]) ** 2 for c in distanceColumns)
                    .reduce((a,b) -> a + b))
                whisky.top5 = false
                whisky.bottom5 = false
        else 
            for whisky in W.whiskies
                whisky.distance = 3     #default when nothing selected
                whisky.top5 = false
                whisky.bottom5 = false           

    #assign mostSimilar / leastSimilar boolean columns to top/last 5
    sortedWhiskies = (w for w in W.filteredWhiskies() when not w.selected)    #clone + skip selected
    sortedWhiskies.sort((a, b) -> a.distance - b.distance)
    for w in sortedWhiskies[0..4]
        w.top5 = true
    for w in sortedWhiskies[-5..]
        w.bottom5 = true

    W.redrawMaps(W.filteredWhiskies())
    
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

