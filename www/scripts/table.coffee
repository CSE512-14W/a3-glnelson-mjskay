#W.drawHeaderRow = (table) ->
#        table.append("thead")
#         .data(tableColumnNames)
#         .enter()
#         .append("th")
#         .html(function(column) {return column;});
#    };
#    
#W.redrawBaseline = (rowID) ->
#    baseline = [data[rowID-1]]
#    table = d3.select("#baseline")
#          .append("table")
#          .style("border-collapse", "collapse")
#          .style("border", "2px black solid");
#
#    drawHeaderRow(table);
#
#  table.selectAll("tr")
#      .data(data, whiskyKey)
#      .enter().append("tr")
#      .selectAll("td")
#      .data(function(row){
#        return tableColumnNames.map( function(column){
#          return {column: column, value: row[column]};
#        }); 
#      })
#      .enter()
#      .append("td")
#      .style("border", "1px black solid")
#      .style("padding", "5px")
#      .on("mouseover", function(){d3.select(this).style("background-color", "aliceblue")})
#      .on("mouseout", function(){d3.select(this).style("background-color", "white")})
#      .style("font-size", "12px")
#      .html(function(d) {return d.value});
#};
#
  # based on code from http://www.d3noob.org/2013/02/add-html-table-to-your-d3js-graph.html
  # columns has name: string of the column
  #             baselineDraw: function that outputs html to draw the column for baseline
  #               runs off of d3 so
  #
  # assumes the div already hase table, thead, tbody elements in the html
  
W.drawFull = () ->
    drawTable("#full", W.whiskies, W.columnNames)

W.drawSelected = () ->
    if W.selectedWhisky?
        d3.select("#full").select("h2").text("All scotches")
        d3.select("#selected").style("display", "block")
        d3.select("#top5").style("display", "block")
        d3.select("#bot5").style("display", "block")
        drawTable("#selected", [W.selectedWhisky], W.columnNames)
        drawTable("#top5", W.top5(), W.columnNames)
        drawTable("#bot5", W.bot5(), W.columnNames)
    else
        d3.select("#full").select("h2").text("Select a scotch")
        d3.select("#selected").style("display", "none")
        d3.select("#top5").style("display", "none")
        d3.select("#bot5").style("display", "none")
        


W.drawBrushTable = () ->
    if W.brushedWhisky?
        d3.select("#brush").style("display", "block")
        drawTable("#brush", [W.brushedWhisky], W.columnNames)
    else
        d3.select("#brush").style("display", "none")
        

drawTable = (div, data, columns) ->
    table = d3.select(div).select("table")
                .attr("class", "whisky-table")
    thead = table.select("thead")
    tbody = table.select("tbody")

    showColumns = (c for c in columns when c.show)

    #remove selected whiskies from the table
    selectedWhiskies = (w for w in data when w.selected)
    unselectedWhiskies = (w for w in data when not w.selected)
    
    #delete table before redraw
    thead.selectAll("tr").remove()
    tbody.selectAll("tr").remove()
 
    # append the header row
    th = thead.append("tr")
        .selectAll("th")
        .data(showColumns, W.columnKey)
        .enter()
        .append("th")
        .text((column) -> column.name)
        .on "click", () ->  # click to toggle 
           W.toggleColumnByKey(W.columnKey(d3.select(this).datum()))
           W.redraw()

    # set up flavor headings   
    flavorColumnNames = W.flavorColumnNames()
    th.filter((column) -> W.columnKey(column) in flavorColumnNames)
        .attr("class", "flavor")
        .filter((column) -> not column.distance_include)
        .attr("class", "flavor ignored-column")
    
    # create a row for each object in the data
    addWhiskies = (whiskies) ->
        rows = tbody.selectAll("tr")
            .data(data, W.whiskyKey)
            .enter()
            .append("tr")
            .sort((a, b) -> a.distance - b.distance)
    
        # create a cell in each row for each column
        cells = rows.selectAll("td")
            .data (row) ->
                showColumns.map (column) ->
                    column: column
                    value: row[column.name]
            .enter()
            .append("td") #add class here w function
            
        # create non-flavor cells
        cells.filter((d) -> not d.column.flavor) 
            .html((d) -> d.value)
            
        # create flavor cells
        cells.filter((d) -> d.column.flavor) 
            .html((d) -> '<div class="flavor-bar" style="width: ' + (d.value / 4 * 100) + '%; height: 100%;">&nbsp;</div>')
            
        # grey out ignored
        cells.filter((d) -> (not d.column.distance_include)  and d.column.flavor)
            .attr("class", "ignored-cell")

        # click to select
        cells.on "click", () -> 
            W.selectWhiskyByKey(W.whiskyKey(d3.select(this.parentNode).datum()))
            W.redraw()
            
        # brushing
        cells.on "mouseover", () ->
            W.brushWhiskyByKey(W.whiskyKey(d3.select(this.parentNode).datum()))
            W.redraw(sortChanged=false)
            
        cells.on "mouseout", () ->
            W.unbrush()
            W.redraw(sortChanged=false)
            
    addWhiskies(selectedWhiskies)
    addWhiskies(unselectedWhiskies)

         
W.drawTables = () ->
    W.drawSelected()
    W.drawFull()
    
W.updateTableBrush = () ->
    W.drawBrushTable()
    d3.selectAll(".whisky-table")
        .selectAll("tbody")
        .selectAll("tr")
        .data(W.whiskies, W.whiskyKey)
        .attr "class", (w) ->
            if w.brushed
                "brushed"
            else
                ""
    
  
W.setupTable = () ->        
    # for some reason right now none of this code is getting called here
    console.log("setup table was called");
    # initial conditions
    # select Ardbeg as default

    # draw baseline TODO
    # redrawBaseline(4)# default is Ardbeg               

    # draw table
    W.drawTables()



