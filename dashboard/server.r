function(input, output, session) {
  
  labelWithInfo = function(label, id) {
    HTML(
      label,
      as.character(
        actionLink(
          id,
          label = '',
          icon = icon(name = 'question-circle', lib = 'font-awesome', 'fa-xs')
        )
      )
    )
  }

  loc = "/home/chanyu/Desktop/school/webscrapping/project/data/"

  bra_content <- read.csv(paste0(loc, "bra_text.csv"))
  arg_content <- read.csv(paste0(loc, "arg_text.csv"))
  por_content <- read.csv(paste0(loc, "por_text.csv"))
  fra_content <- read.csv(paste0(loc, "fra_text.csv"))

  bra_sent <- read.csv(paste0(loc, "bra_sen.csv"))
  arg_sent <- read.csv(paste0(loc, "arg_sen.csv"))
  por_sent <- read.csv(paste0(loc, "por_sen.csv"))
  fra_sent <- read.csv(paste0(loc, "fra_sen.csv"))

  content = list()
  content[["bra"]] = bra_content
  content[["arg"]] = arg_content
  content[["por"]] = por_content
  content[["fra"]] = fra_content
  
  sent_type = c("anger", "anticipation", "disgust", "fear", "joy",
    "sadness", "surprise", "trust", "negative", "positive"
  )

  sent_df = list()
  sent_df[["bra"]] = data.frame(sent_type, n = colSums(bra_sen))
  sent_df[["arg"]] = data.frame(sent_type, n = colSums(arg_sen))
  sent_df[["por"]] = data.frame(sent_type, n = colSums(por_sen))
  sent_df[["fra"]] = data.frame(sent_type, n = colSums(fra_sen))

  source("./page01_data_server.r", encoding = "utf-8", local = T)

  source("./page02_SentiAnalysis_server.r", encoding = "utf-8", local = T)


}

