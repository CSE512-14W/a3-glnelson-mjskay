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
    drawTable("#full", W.whiskies, W.tableColumnNames)
    
W.drawTop5 = (div, data, columns) ->
    drawTable("#top5", W.top5(), W.tableColumnNames)

W.drawBot5 = (div, data, columns) ->
    drawTable("#bot5", W.bot5(), W.tableColumnNames)

drawTable = (div, data, columns) ->
    table = d3.select(div).select("table")
                .attr("class", "whisky-table")
    thead = table.select("thead")
    tbody = table.select("tbody")

    #remove selected whiskies from the table
    selectedWhiskies = (w for w in data when w.selected)
    unselectedWhiskies = (w for w in data when not w.selected)
    
    #delete table before redraw
    thead.selectAll("tr").remove()
    tbody.selectAll("tr").remove()
 
    # append the header row
    # TODO fix, 
    th = thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
        .text((column) -> column)
        .on "click", () ->  # click to toggle 
           W.toggleIncludeColumn(W.columnKey(d3.select(this).datum()))
           W.redraw()
         
    # set up flavor headings   
    flavorColumnNames = W.flavorColumnNames()
    th.filter((column) -> column in flavorColumnNames)
        .attr("class", "flavor")
    
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
                columns.map (column) ->
                    column: column
                    value: row[column]
            .enter()
            .append("td")
            
        # create non-flavor cells
        cells.filter((d) -> d.column not in flavorColumnNames) 
            .html((d) -> d.value)
            .on "click", () ->  # click to select 
                W.selectWhiskyByKey(W.whiskyKey(d3.select(this.parentNode).datum()))
                W.redraw()
            
        # create flavor cells
        cells.filter((d) -> d.column in flavorColumnNames) 
            .html((d) -> '<div class="flavor-bar" style="width: ' + (d.value / 4 * 100) + '%; height: 100%;">&nbsp;</div>')
            

    addWhiskies(selectedWhiskies)
    addWhiskies(unselectedWhiskies)

         
W.drawTables = () ->
    W.drawFull()
    W.drawTop5()
    W.drawBot5()
  
W.setupTable = () ->        
    # for some reason right now none of this code is getting called here
    console.log("setup table was called");
    # initial conditions
    # select Ardbeg as default

    # draw baseline TODO
    # redrawBaseline(4)# default is Ardbeg               

    # draw table
    W.drawTables()



