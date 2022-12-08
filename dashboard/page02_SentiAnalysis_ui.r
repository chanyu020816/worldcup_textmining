# tab 01 - 資料
tabItem(
  tabName = "page02_SentiAnaly",
  fluidRow(
    box(
      width = 5,
      headerBorder = FALSE,
      collapsible = FALSE,
       tabsetPanel(
        tabPanel(
          "Setting",
          selectInput(
            "page02_team",
            labelWithInfo("Team:", "page01_team_info"),
            choices = c("Argentina", "Portugal", "France", "Brazil")
          ),
          selectInput(
            "pae02_type",
             labelWithInfo("Type:", "page01_type_info"),
            choices = c("Positive / Negative", "Sentiment", "NULL"),
            selected = "NULL"
          ),
          selectInput(
            "page02_dist",
             labelWithInfo("Distinction:", "page01_by_info"),
            choices = c("Time", "Phone Type (Apple / Android", "NULL"),
            selected = "NULL"
          ),
          uiOutput("page02_time")
        )
      )
    ),
    box(
      width = 7,
      headerBorder = FALSE,
      collapsible = FALSE,
      title = "",
      tabsetPanel(
        tabPanel(
          "Twitter content"
        ),
        tabPanel(
          "Word Cloud"
        ),
        side = "right"
      )
    )
  )
)