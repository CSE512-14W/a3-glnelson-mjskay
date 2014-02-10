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
  
W.drawTable = (div, data, columns) ->
    table = d3.select(div).select("table")
                .attr("class", "whisky-table")
    thead = table.select("thead")
    tbody = table.select("tbody")

    #remove selected whiskies from the table
    selectedWhiskies = (w for w in data when w.selected)
    unselectedWhiskies = (w for w in data when not w.selected)
    
    # append the header row
    # TODO fix, 
    thead.selectAll("tr").remove()
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
            .text((column) -> column)
    
    # create a row for each object in the data
    tbody.selectAll("tr").remove()
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
            .html((d) -> d.value)
            .on "click", () ->  # click to select 
                W.selectWhiskyByKey(W.whiskyKey(d3.select(this.parentNode).datum()))
                W.redraw()

    addWhiskies(selectedWhiskies)
    addWhiskies(unselectedWhiskies)

W.setupTable = () ->        
    # for some reason right now none of this code is getting called here
    console.log("setup table was called");
    # initial conditions
    # select Ardbeg as default

    # draw baseline TODO
    # redrawBaseline(4)# default is Ardbeg               

    # draw table
    W.drawTable("#baseline", W.whiskies, W.tableColumnNames)



