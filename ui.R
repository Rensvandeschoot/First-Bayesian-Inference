
ui <- fluidPage(title="Exploring Bayesian Estimation",
#######################################################
  fluidRow(
    column(12, style="background:  #6699ff;
        padding: 20px; border-width: 20px; border-color: #fff;
           border-style: solid;",
           h1("Exploring Bayesian Estimation (Version 1.1)", span(style = "font-weight: 300"),
              style="color: #fff; text-align: center;"),
           p("Created by: Sonja D. Winter, Lion Behrens & Rens van de Schoot, Utrecht University",
             style="color: #fff; text-align: center;")
           )
  ),
 
  
  fluidRow(
    column(4,
           h2("1. Choose a prior distribution"),
           br(),
           radioButtons(inputId = "prior", label = "Distributions",
                        choices = list("Normal" = "rnorm", "Uniform" = "runif",
                                       "Truncated Normal" = "trnorm")),
           conditionalPanel(
             condition = "input.prior == 'rnorm'",
             numericInput("mean", label = "Mean", value = 100),
             numericInput("var", label = "Variance", value = 10)
           ),
           conditionalPanel(
             condition = "input.prior == 'runif'",
             numericInput("min", label = "Minimum", value = 0),
             numericInput("max", label = "Maximum", value = 150)
           ),
           conditionalPanel(
             condition = "input.prior == 'trnorm'",
             numericInput("meant", label = "Mean", value = 100),
             numericInput("vart", label = "Variance", value = 10),
             numericInput("lbound", label = "Lower bound", value = 0),
             numericInput("ubound", label = "Higher bound", value = 150)
           ),
           
           br(),
   
           h2("2a. Upload your data"),
           p("Please submit data in .csv format with only one column of data
             and the variable name as the header."),
           fileInput(inputId="file", label = h3("Upload"),
                     accept = c(
                       'text/csv',
                       'text/comma-separated-values',
                       'text/tab-separated-values',
                       'text/plain',
                       '.csv',
                       '.tsv'
                     ))),
           
           
           
      column(4,     
           h2("2b. Generate your data"), 
           p("By specifying the parameters below, you can generate data from a truncated
             normal distribution."),
           br(),
           numericInput("meant2", label = "Mean", value = 100),
           numericInput("vart2", label = "Variance", value = 10),
           numericInput("lbound2", label = "Lower bound", value = 40),
           numericInput("ubound2", label = "Higher bound", value = 180), 
           numericInput("n2", label = "Sample Size", value = 50),
           
           actionButton("generate", label = "Generate Data")
           
           
    ),
    column(4,
           h2("3. Find your posterior!"),
           br(),
           p("By clicking the button below, you run the model to find the
             posterior mean of your data with your uploaded data and chosen
             prior distribution. If you change your data or prior, and you
             want to see its effect, just rerun the model by clicking the
             button again!"),
           actionButton("run", label = "Run the model"))
    ),
  fluidRow(
    column(12, 
           h2("Distributions"),
           br(),
           plotOutput("hist")
           )
  ),
  fluidRow(
    column(12, style="background:  #6699ff;
        padding: 0px 200px 0px 200px",
           #\href{http://onlinelibrary.wiley.com/doi/10.1111/cdev.12169/abstract}{}
            p("Based on: van de Schoot, R., Kaplan, D., Denissen, J., Asendorpf, J. B., 
             Neyer, F. J., & Aken, M. A. (2014). A gentle introduction to Bayesian analysis: applications to developmental research. Child development, 85(3), 
             842-860.", style="color: #fff; text-align: center; padding: 20px"
              )
           
    )
  ))