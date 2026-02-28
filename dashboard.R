# ===================== LIBRARIES =====================
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(e1071)
library(corrplot)

# ===================== UI =====================
ui <- dashboardPage(
  skin = "yellow",
  
  dashboardHeader(title = "Advanced Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Numeric Analysis", tabName = "numeric", icon = icon("chart-bar")),
      menuItem("Categorical Analysis", tabName = "categorical", icon = icon("chart-pie")),
      menuItem("Advanced Analytics", tabName = "advanced", icon = icon("brain"))
    )
  ),
  
  dashboardBody(
    
    tags$style(HTML("
      .content-wrapper, .right-side {
        background: linear-gradient(to right, #eef2f3, #dfe9f3);
      }
      .box {
        border-radius: 12px;
        box-shadow: 2px 2px 15px rgba(0,0,0,0.1);
      }
      h2 {font-weight: bold; color:#2c3e50;}
    ")),
    
    fluidRow(
      column(12,
             h2("COMPREHENSIVE EDA DASHBOARD",
                align="center",
                style="margin-bottom:25px;"))
    ),
    
    tabItems(
      
      # ================= OVERVIEW =================
      tabItem(tabName="overview",
              fluidRow(
                box(width=12, title="Upload CSV File", status="primary",
                    solidHeader=TRUE,
                    fileInput("file","Choose CSV File", accept=".csv"))
              ),
              fluidRow(
                valueBoxOutput("rows"),
                valueBoxOutput("cols"),
                valueBoxOutput("missing"),
                valueBoxOutput("missing_percent")
              ),
              fluidRow(
                box(width=12, title="Dataset Preview",
                    status="info", solidHeader=TRUE,
                    DTOutput("table"))
              )
      ),
      
      # ================= NUMERIC =================
      tabItem(tabName="numeric",
              uiOutput("num_select"),
              fluidRow(
                box(width=6, title="Histogram", status="primary",
                    solidHeader=TRUE, plotOutput("hist")),
                box(width=6, title="Boxplot", status="warning",
                    solidHeader=TRUE, plotOutput("box"))
              ),
              fluidRow(
                box(width=12, title="Statistical Interpretation",
                    status="info", solidHeader=TRUE,
                    verbatimTextOutput("interpret"))
              )
      ),
      
      # ================= CATEGORICAL =================
      tabItem(tabName="categorical",
              uiOutput("cat_select"),
              fluidRow(
                box(width=6, title="Bar Chart", status="primary",
                    solidHeader=TRUE, plotOutput("bar")),
                box(width=6, title="Pie Chart", status="warning",
                    solidHeader=TRUE, plotOutput("pie"))
              )
      ),
      
      # ================= ADVANCED =================
      tabItem(tabName="advanced",
              
              uiOutput("num_select2"),
              
              fluidRow(
                box(width=12, title="Anomaly Detection (IQR Method)",
                    status="danger", solidHeader=TRUE,
                    verbatimTextOutput("outlier_text"))
              ),
              
              fluidRow(
                box(width=12, title="Normality Test (Shapiro-Wilk)",
                    status="info", solidHeader=TRUE,
                    verbatimTextOutput("normal_test"))
              ),
              
              fluidRow(
                box(width=12, title="Predictive Modeling (Custom Linear Regression)",
                    status="success", solidHeader=TRUE,
                    
                    radioButtons("reg_option",
                                 "Choose Regression Mode:",
                                 choices = c("Select Variables Manually",
                                             "Use Best Correlated Variables"),
                                 selected = "Use Best Correlated Variables"),
                    
                    uiOutput("reg_select_ui"),
                    
                    plotOutput("reg_plot"),
                    verbatimTextOutput("reg_text")
                )
              )
      )
    )
  )
)

# ===================== SERVER =====================
server <- function(input, output) {
  
  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # ===== KPIs =====
  output$rows <- renderValueBox({
    req(data())
    valueBox(nrow(data()), "Total Rows", icon=icon("list"), color="pink")
  })
  
  output$cols <- renderValueBox({
    req(data())
    valueBox(ncol(data()), "Total Columns", icon=icon("columns"), color="green")
  })
  
  output$missing <- renderValueBox({
    req(data())
    valueBox(sum(is.na(data())), "Missing Values", icon=icon("exclamation"), color="red")
  })
  
  output$missing_percent <- renderValueBox({
    req(data())
    percent <- round((sum(is.na(data()))/(nrow(data())*ncol(data())))*100,2)
    valueBox(paste0(percent,"%"), "Missing %", icon=icon("percent"), color="yellow")
  })
  
  # ===== TABLE =====
  output$table <- renderDT({
    req(data())
    datatable(head(data(),10))
  })
  
  # ===== NUMERIC SELECT =====
  output$num_select <- renderUI({
    req(data())
    nums <- names(data())[sapply(data(), is.numeric)]
    if(length(nums)==0) return(NULL)
    selectInput("num_var","Select Numeric Variable:", choices=nums)
  })
  
  output$hist <- renderPlot({
    req(input$num_var)
    ggplot(data(), aes_string(input$num_var))+
      geom_histogram(fill="#3498db", bins=30)+theme_minimal()
  })
  
  output$box <- renderPlot({
    req(input$num_var)
    ggplot(data(), aes_string(y=input$num_var))+
      geom_boxplot(fill="#e67e22")+theme_minimal()
  })
  
  output$interpret <- renderPrint({
    req(input$num_var)
    x <- data()[[input$num_var]]
    cat("Mean:",mean(x,na.rm=TRUE),"\n")
    cat("Median:",median(x,na.rm=TRUE),"\n")
    cat("SD:",sd(x,na.rm=TRUE),"\n")
    cat("Skewness:",skewness(x,na.rm=TRUE),"\n")
  })
  
  # ===== CATEGORICAL =====
  output$cat_select <- renderUI({
    req(data())
    cats <- names(data())[sapply(data(), function(x) is.character(x)|is.factor(x))]
    if(length(cats)==0) return(NULL)
    selectInput("cat_var","Select Categorical Variable:", choices=cats)
  })
  
  output$bar <- renderPlot({
    req(input$cat_var)
    ggplot(data(), aes_string(input$cat_var, fill=input$cat_var))+
      geom_bar()+theme_minimal()+theme(legend.position="none")
  })
  
  output$pie <- renderPlot({
    req(input$cat_var)
    df <- data()%>%count(.data[[input$cat_var]])
    ggplot(df, aes(x="",y=n,fill=.data[[input$cat_var]]))+
      geom_bar(stat="identity",width=1)+coord_polar("y")+theme_void()
  })
  
  # ===== ADVANCED =====
  output$num_select2 <- renderUI({
    req(data())
    nums <- names(data())[sapply(data(), is.numeric)]
    if(length(nums)==0) return(NULL)
    selectInput("num_var2","Select Variable for Advanced Analysis:", choices=nums)
  })
  
  output$outlier_text <- renderPrint({
    req(input$num_var2)
    x <- data()[[input$num_var2]]
    Q1 <- quantile(x,0.25,na.rm=TRUE)
    Q3 <- quantile(x,0.75,na.rm=TRUE)
    IQR_val <- Q3-Q1
    lower <- Q1 - 1.5*IQR_val
    upper <- Q3 + 1.5*IQR_val
    outliers <- sum(x<lower | x>upper, na.rm=TRUE)
    cat("Outliers Detected:", outliers,"\n")
  })
  
  output$normal_test <- renderPrint({
    req(input$num_var2)
    x <- na.omit(data()[[input$num_var2]])
    if(length(x)>3 & length(x)<5000){
      print(shapiro.test(x))
    } else {
      cat("Sample size not suitable for Shapiro test.")
    }
  })
  
  # ===== REGRESSION =====
  output$reg_select_ui <- renderUI({
    req(data())
    nums <- names(data())[sapply(data(), is.numeric)]
    if(input$reg_option=="Select Variables Manually"){
      tagList(
        selectInput("x_var","Select X Variable:",choices=nums),
        selectInput("y_var","Select Y Variable:",choices=nums)
      )
    }
  })
  
  best_features <- reactive({
    nums <- data()[, sapply(data(), is.numeric)]
    req(ncol(nums)>=2)
    
    cor_matrix <- cor(nums,use="complete.obs")
    cor_matrix[lower.tri(cor_matrix,diag=TRUE)] <- NA
    
    max_val <- max(abs(cor_matrix),na.rm=TRUE)
    idx <- which(abs(cor_matrix)==max_val,arr.ind=TRUE)[1,]
    
    list(
      x = colnames(cor_matrix)[idx[2]],
      y = rownames(cor_matrix)[idx[1]]
    )
  })
  
  output$reg_plot <- renderPlot({
    req(data())
    req(input$reg_option)
    
    nums <- data()[, sapply(data(), is.numeric)]
    req(ncol(nums)>=2)
    
    if(input$reg_option=="Select Variables Manually"){
      req(input$x_var,input$y_var)
      x <- data()[[input$x_var]]
      y <- data()[[input$y_var]]
      xname <- input$x_var
      yname <- input$y_var
    } else {
      best <- best_features()
      x <- data()[[best$x]]
      y <- data()[[best$y]]
      xname <- best$x
      yname <- best$y
    }
    
    df <- na.omit(data.frame(x,y))
    model <- lm(y~x,data=df)
    
    ggplot(df,aes(x=x,y=y))+
      geom_point(color="blue")+
      geom_smooth(method="lm",se=FALSE,color="red")+
      theme_minimal()+
      labs(x=xname,y=yname)
  })
  
  output$reg_text <- renderPrint({
    req(data())
    req(input$reg_option)
    
    nums <- data()[, sapply(data(), is.numeric)]
    req(ncol(nums)>=2)
    
    if(input$reg_option=="Select Variables Manually"){
      req(input$x_var,input$y_var)
      x <- data()[[input$x_var]]
      y <- data()[[input$y_var]]
    } else {
      best <- best_features()
      x <- data()[[best$x]]
      y <- data()[[best$y]]
    }
    
    df <- na.omit(data.frame(x,y))
    model <- lm(y~x,data=df)
    summary(model)
  })
  
}

# ================= RUN =================
shinyApp(ui, server)
