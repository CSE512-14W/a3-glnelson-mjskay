###
Common code for whisky dataset
###

###
Return the key for joining whisky data in d3
###
W.whiskyKey = (whisky) -> whisky.RowID

###
Return the distance measure for ordering a given whisky
###
W.whiskyDistance = (whisky) -> Math.random() * 2 + 1    #TODO: properly map this to distance

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
            "distance"];



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
                distance: +d.Latitude, # default value
                selected: false # default value
              } for d in whiskies)
        
        W.setupTable()
        #W.setupMaps(uk)

