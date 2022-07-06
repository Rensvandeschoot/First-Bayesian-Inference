#server.r
library(shiny)
library(rjags)
library(coda)
#set.seed(42)

server <- function(input, output) {
  
  data <- reactive({
    inFile <- input$file
    if (is.null(inFile))
      return(NULL)
    
    unlist(read.csv(inFile$datapath, header=TRUE))
  })
  
  posterior <- eventReactive(input$run, {
    if (is.null(data())) {return()}
    
    y <- data()
    if (input$prior == "rnorm") {
      model_string <- paste("model{
        for(i in 1:length(y)) {
        y[i] ~ dnorm(mu, tau)
        }
        mu ~ dnorm(", input$mean, ", 1/", input$sd,"^2)
        sigma ~ dlnorm(0, 0.0625)
        tau <- 1 / pow(sigma, 2)}" , sep="")
      
      model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
      update(model, 1000);
      mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
      
      unlist(mcmc_samples)
    }
    else if (input$prior == "runif") {
      model_string <- paste("model{
        for(i in 1:length(y)) {
          y[i] ~ dnorm(mu, tau)
        }
        mu ~ dunif(", input$min,",", input$max,")
        sigma ~ dlnorm(0, 0.0625)
        tau <- 1 / pow(sigma, 2)}" , 
                            sep="")
      
      model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
      update(model, 1000);
      mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
      
      unlist(mcmc_samples)
    }
    else if (input$prior == "trnorm") {
      model_string <- paste("model{
        for(i in 1:length(y)) {
        y[i] ~ dnorm(mu, tau)
        }
        mu ~ dnorm(", input$meant,", 1/", input$sdt,"^2) T(", input$lbound, ",",input$ubound,")
        sigma ~ dlnorm(0, 0.0625)
        tau <- 1 / pow(sigma, 2)}" , sep="")
      
      model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
      update(model, 1000);
      mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
      
      unlist(mcmc_samples)
    }
    
  })
  
  
  output$hist <- renderPlot({
    if (is.null(data())) {return()}
    if (is.null(posterior())) {return()}
    
    likeli <- data()
    
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli))
    
    likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)
    
    if (input$prior == "rnorm") {
      plot(seq(0,200, length=1000), dnorm(seq(0,200, length=1000),input$mean, input$sd), 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        dnorm(seq(0,200, length=1000),input$mean, input$sd))),
           main = "Normal prior", lwd=2, type="l", col="blue", lty = 2,
           ylab = "Density", xlab = "")
      lines(seq(0,200, length=1000),likeli, col="green", lwd=2)
      lines(density(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(mean_d), col="green", lwd=2)
      abline(v=input$mean, col="blue", lwd=2, lty = 2)
      legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
             lty=c(2,1,2), lwd=2, col=c("Blue", "Green", "Red"),
             cex=1.5)
    }
    else if (input$prior == "runif") {
      plot(seq(0,200, length=1000), dunif(seq(0,200, length=1000),input$min, input$max), 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        dnorm(seq(0,150, length=1000),input$mean, input$sd))),
           main = "Uniform prior", lwd=2, type="l",col="blue", lty = 2,
           ylab = "Density", xlab = "")
      lines(seq(0,200, length=1000),likeli, col="green", lwd=2)
      lines(density(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(mean_d), col="green", lwd=2)
      legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
             lty=c(2,1,2), lwd=2, col=c("Blue", "Green", "Red"),
             cex=1.5)
    }
    else if (input$prior == "trnorm") {
      priord <- dnorm(seq(0,200, length=1000), input$meant, input$sdt)
      ubound2 <- 1000/200*input$ubound
      lbound2 <- 1000/200*input$lbound
      priord[ubound2:length(priord)] = 0
      priord[1:lbound2] = 0
      
      plot(seq(0,200, length=1000), priord, 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        priord)),
           main = "Truncated Normal prior", lwd=2, type="l", col="blue", lty = 2,
           ylab = "Density", xlab = "")
      lines(seq(0,200, length=1000),likeli, col="green", lwd=2)
      lines(density(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(mean_d), col="green", lwd=2)
      abline(v=input$meant, col="blue", lwd=2, lty = 2)
      legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
             lty=c(2,1,2), lwd=2, col=c("Blue", "Green", "Red"),
             cex=1.5)
    }
    
  })
  
}