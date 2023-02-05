# tab 01 - 資料
tabItem(
  tabName = "page01_data",
  fluidRow(
    box(
      width = 5,
      headerBorder = FALSE,
      collapsible = FALSE,
      tabsetPanel(
        tabPanel(
          "Setting",
          selectInput(
            "page01_team",
            "Team",
            choices = c(
              "Brazil" = "bra",
              "Argentina" = "arg",
              "Portugal" = "por",
              "France" = "fra"
            )
          ),
          h6('WordCloud:', style = 'font-Weight: bold; font-size: 20px; font_color: blue'),
          selectInput(
            "page01_dist",
            "Distinction",
            choices = c(
              "Period" = "period",
              "Resource" = "phone",
              "NULL"
            ),
            selected = "NULL"
          ),
          uiOutput("page01_dist_result"),
          # selectInput(
          #   "page01_comparison",
          #   "Type",
          #   choices = c("Positive / Negative", "NULL"),
          #   selected = "NULL"
          # ),
          sliderInput(
            "page01_max_num",
            "Select the maximum number of words",
            min = 20, max = 200, value = 50
          )
        )
      )
    ),
    box(
      width = 7,
     # height = '200px',
      headerBorder = FALSE,
      collapsible = FALSE,
      title = "",
      tabsetPanel(
        tabPanel(
          "Twitter content",
          uiOutput("content")
        ),
        tabPanel(
          "Word Cloud",
          withSpinner(
            plotOutput("wordcloud", width = "100%", height = "800px"),
            color = "#0dc5c1"
          )
        ),
        tabPanel(
          "Comparision Cloud",
           withSpinner(
            plotOutput("comparison_plot", width = "100%", height = "1000px"),
            color = "#0dc5c1"
          )
        )
      )
    )
  )
)