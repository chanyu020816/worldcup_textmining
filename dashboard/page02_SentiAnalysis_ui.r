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
            "Team",
            choices = c(
              "Brazil" = "bra",
              "Argentina" = "arg",
              "Portugal" = "por",
              "France" = "fra"
            )
          ),
          selectInput(
            "page02_dist",
            "Distinction",
            choices = c(
              "Period" = "period",
              "Resource" = "phone",
              "NULL"
            ),
            selected = "NULL"
          ),
          uiOutput("page02_period"),
          selectInput(
            "page02_type",
            "Type",
            choices = c("Positive / Negative", "Sentiment", "NULL"),
            selected = "NULL"
          ),
          sliderInput(
            "page02_max_num",
            "Select the maximum number of words",
            min = 5, max = 50, value = 20
          )
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
          "Bar Chart",
          plotOutput("page02_bar", width = "100%", height = "1200px")
        ),
        tabPanel(
          "Pie Chart",
          plotOutput("page02_pie", width = "100%", height = "1200px")
        ),
        tabPanel(
          "Line Graph (period)",
          plotOutput("page02_line", width = "100%", height = "1200px")
        ),
        side = "right"
      )
    )
  )
)