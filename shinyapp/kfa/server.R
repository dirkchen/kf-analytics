library(ggplot2) # for ggplot, qplot
library(psych) # for corr.test
library(gdata) # for trim
library(xts) # for time series analysis
library(reshape) # for melt
library(RCurl) # for accessing Google spreadsheet
library(igraph) # for SNA
library(RColorBrewer) # for colors in SNA

# setwd("/home/bodong/src/r/shinyapp/kfa")

# read notes
# hashtag <- "icls2012"
df <- read.csv("ctl1799.csv")
df$date <- strptime(df$time, "%m/%d/%Y %H:%M:%S")

shinyServer(function(input, output) {
  
  ## 1. Basic (descriptive and correlation) analysis
  
  # get data
  descriptiveData <- function() {
    table <- as.data.frame(table(df$from_user))
    colnames(table) <- c("user", "notes")
    
    table <- table[with(table, order(-notes, user)), ] # sort
    
    row.names(table) <- NULL # remove original row.names to avoid confusion
    
    table
  }
  
  # show data table
  output$basic_table <- reactiveTable(function() {
    descriptiveData()
  })
  
  # total notes plot
  output$basic_notes_plot <- reactivePlot(function() {
    table <- descriptiveData()
    
    r_levels <- as.character(table$user)
    table$user <- factor(table$user, levels = r_levels)
    p <- ggplot(table, aes(x=user)) + geom_bar(aes(y = notes)) + theme(axis.text.x=element_text(angle=90))
    print(p)
  })
  
  ## 2. Temporal analysis
  
  output$ts_plot <- reactivePlot(function() {
    df$scaledtime <- switch(input$timescale,
                            byday = df$date,
                            bywday = sapply(as.character(df$time), function(x) {p <- strptime(x, "%m/%d/%Y %H:%M:%S"); p$wday}),
                            byhr = sapply(as.character(df$time), function(x) {p <- strptime(x, "%m/%d/%Y %H:%M:%S"); p$hour})
                            )
    p <- ggplot(df, aes(x=scaledtime)) + geom_bar(aes(y = (..count..)))
    print(p)
  })
  
  output$ts_hr_wday_plot <- reactivePlot(function(){
    df$wday <- sapply(as.character(df$time), function(x) {p <- strptime(x, "%m/%d/%Y %H:%M:%S"); p$wday})
    df$hour <- sapply(as.character(df$time), function(x) {p <- strptime(x, "%m/%d/%Y %H:%M:%S"); p$hour})
    p <- ggplot(df)+geom_jitter(aes(x=wday,y=hour))
    print(p)
  })
  
  output$ts_user_plot <- reactivePlot(function() {
    p <- ggplot(df) + geom_point(aes(x=date,y=from_user,color=from_user))
    print(p)
  })
  
  ## 3. ngram
  
  # prepare data
  ngramData <- function(query) {
    table <- data.frame(date = df$date)
    
    text <- tolower(as.character(df$text))
    for(q in query) {
      # construct a frequency vector
      count <- unlist(lapply(text, function(tweet) length(unlist(strsplit(tweet, q))) - 1 ))
      
      # attach to a data frame
      table[[q]] <- count
    }
    
    table
  }
  
  # plot ngram
  output$ngram_plot <- reactivePlot(function() {
    if(trim(input$ngram_query) == "") return
    
    queryStr <- tolower(input$ngram_query)
    query <- trim(unlist(strsplit(queryStr, split=",")))
    query <- unique(query[query != ""]) # remove empty and repetitive elements
    
    table <- ngramData(query)
    
    ts <- xts(table[1:length(query)+1], table$date)
    ts.sum = apply.daily(ts[, 1], sum)
    ts.sum.df = data.frame(date=index(ts.sum), coredata(ts.sum))
    
    for(i in 2:length(query)) {
      if(i > length(query)) break # in case only one term
      ts.sum = apply.daily(ts[,i], sum)
      ts.sum.df1 = data.frame(date=index(ts.sum), coredata(ts.sum))
      #colnames(ts.sum.df) = c("date", query[i])
      ts.sum.df <- cbind(ts.sum.df, ts.sum.df1[, 2])
      colnames(ts.sum.df)[length(ts.sum.df)] <- query[i]
    }
    
    ts.df <- melt(ts.sum.df, id = "date")
    colnames(ts.df) <- c("date", "term", "frequency")
    p <- ggplot(ts.df, aes(date, frequency, colour = term)) + geom_line()
    
    print(p)
  })
  
  ## 4. sna
  
  scale <- function(v, min, max) {
    v.min <- min(v)
    v.max <- max(v)
    min + (max-min)*(v-v.min)/(v.max-v.min)
  }
  
  output$sna_plot <- reactivePlot(function() {
    df_vertices <- read.csv("ctl1799_vertices.csv")
    df_vertices <- subset(df_vertices, (buildon > 0 | bebuilton > 0)) # remove zombie users
    
    df_edges <- read.csv("ctl1799_edges.csv")
    df_edges <- subset(df_edges, (read > 0 | buildon > 0 | pick > 0)) # remove empty edges
    df_edges <- subset(df_edges, (from %in% df_vertices$id & to %in% df_vertices$id)) # remove edges related to zombie users
    
    sna_full <- graph.data.frame(d = df_edges, vertices = df_vertices)
    sna_partial <- delete.edges(sna_full, E(sna_full)[get.edge.attribute(sna_full, name = input$sna_network) == 0])
    # add layout
    read_layout <- layout.fruchterman.reingold(sna_partial)
    # add color
    group_vertex_colors = get.vertex.attribute(sna_full, "group")
    unique_group_vertex <- unique(get.vertex.attribute(sna_full, "group"))
    colors <- brewer.pal(length(unique_group_vertex), "Set1")
    i <- 1
    for(group in unique_group_vertex) {
      group_vertex_colors[group_vertex_colors == group] = colors[i]
      i <- i + 1
    }
    # set the vertex size by read
    read_vertex_sizes = scale(get.vertex.attribute(sna_full, input$sna_network), 10, 30)
    # set label as uid
    id_vertex_label = get.vertex.attribute(sna_full, "id")
    p <- plot(sna_partial,
              main = input$sna_network,
              layout=read_layout,
              #vertex.label.color = c("SkyBlue2"),
              vertex.color=group_vertex_colors, 
              vertex.label=id_vertex_label, 
              edge.arrow.size=.5,
              #edge.arrow.width=2,
              vertex.size=read_vertex_sizes)
    print(p)
  })

})
