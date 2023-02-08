# UI
dashboardPage(
  # 標題
  header = dashboardHeader(
    title = "World Cup Semi Analysis",
    status = "#f0fafe"

  ),
  # 側邊選單
  sidebar = dashboardSidebar(
    sidebarMenu(
      # tab 01 - 資料
      menuItem(
        "Twitter Data",
        tabName = "page01_data",
        icon = icon(name = "twitter", lib = "font-awesome")
      ),
      
      # tab 02 - 散佈圖
      menuItem(
          "Sentiment Analysis",
          tabName = "page02_SentiAnaly",
          icon = icon(name = "chart-bar")
      )
    ),
  skin = "light",
  minified = FALSE
  ),
  # 主要頁面
  body = dashboardBody(
    tabItems(

      source("./page01_data_ui.r", encoding = "utf-8", local = T)$value ,

      source("./page02_SentiAnalysis_ui.r", encoding = "utf-8", local = T)$value
    )
  ),
  # 頁尾
  footer = dashboardFooter(
    right = "Stat-3B-劉宸宇"
  )
)
