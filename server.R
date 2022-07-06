#server.r
library(shiny)
library(shinyBS)
library(rjags)
library(coda)
library(msm) # for truncated normal distribution
#set.seed(42)

server <- function(input, output) {
  
     showModal(modalDialog(
      title = "Universtiy of Utrecht: Terms & Conditions",
      "Purpose of the service 'utrecht-university.shinyapps.io' is to provide a digital place 
      for trying out, evaluating and/or comparing methods developed by researchers of Utrecht 
      University for the scientific community worldwide. The app and its contents may not be 
      preserved in such a way that it can be cited or can be referenced to. The web application
      is provided 'as is' and 'as available' and is without any warranty. Your use of this web 
      application is solely at your own risk.You must ensure that you are lawfully entitled and 
      have full authority to upload  data in the web application. The file data must not contain 
      any  data which can raise issues relating to abuse, confidentiality, privacy,  data protection, 
      licensing, and/or intellectual property. You shall not upload data with any confidential or 
      proprietary information that you desire or are required to keep secret.
      By using this app you agree to be bound by the above terms." ))
  
  
  data <- reactive({
    inFile <- input$file
    if (is.null(inFile))
    return(NULL)
    
    unlist(read.csv(inFile$datapath, header=TRUE))
       
    })
  

  gendata <- eventReactive(input$generate, {
    as.numeric(input$meant2+sqrt(input$vart2)*scale(rtnorm(n=input$n2, lower=input$lbound2, upper=input$ubound2)))
    })
  
  
  #######################################################
  
  posterior <- eventReactive(input$run, {
    
    if (is.null(data())){
      y <- gendata()} 
      else{ y <- data()}
  
    if (input$prior == "rnorm") {
      model_string <- paste("model{
        for(i in 1:length(y)) {
        y[i] ~ dnorm(mu, tau)
        }
        mu ~ dnorm(", input$mean, ", 1/", sqrt(input$var),"^2)
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
        mu ~ dnorm(", input$meant,", 1/", sqrt(input$vart),"^2) T(", input$lbound, ",",input$ubound,")
        sigma ~ dlnorm(0, 0.0625)
        tau <- 1 / pow(sigma, 2)}" , sep="")
      
      model <- jags.model(textConnection(model_string), data = list(y = y), n.chains = 1, n.adapt= 1000)
      update(model, 1000);
      mcmc_samples <- coda.samples(model, variable.names=c("mu"), n.iter=2000)
      
      unlist(mcmc_samples)
    }
    
  })
  
  
  output$hist <- renderPlot({
   
    input$run
    isolate({
    
    if (is.null(data()) & is.null(gendata())) {return()}
    if (is.null(posterior())) {return()}
    
    if (is.null(data())){
      likeli <- gendata()} 
    else{ likeli <- data()}

    
    mean_d <- mean(likeli)
    sd_e <- sd(likeli)/sqrt(length(likeli))
    
    likeli <- dnorm(seq(0,200, length=1000),mean_d, sd_e)
    
    if (input$prior == "rnorm") {
      
      # 95% Credible Interval
      lbound <- round(mean(posterior())-1.96*sd(posterior()), digits=2)
      ubound <- round(mean(posterior())+1.96*sd(posterior()), digits=2)
      
      plot(seq(0,200, length=1000), dnorm(seq(0,200, length=1000),input$mean, sqrt(input$var)), 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        dnorm(seq(0,200, length=1000),input$mean, sqrt(input$var)))),
           main = "Normal prior", lwd=2, type="l", col="blue", lty = 2,
           ylab = "Density", xlab = paste(c("95% Credible Interval:"), "[",lbound,";",ubound,"]"))
      
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
      
      # 95% Credible Interval
      lbound <- format(round(mean(posterior())-1.96*sd(posterior()), digits=2))
      ubound <- format(round(mean(posterior())+1.96*sd(posterior()), digits=2))
      
      plot(seq(0,200, length=1000), dunif(seq(0,200, length=1000),input$min, input$max), 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        dnorm(seq(0,150, length=1000),input$mean, sqrt(input$var)))),
           main = "Uniform prior", lwd=2, type="l",col="blue", lty = 2,
           ylab = "Density", xlab = paste(c("95% Credible Interval:"), "[",lbound,";",ubound,"]"))
      lines(seq(0,200, length=1000),likeli, col="green", lwd=2)
      lines(density(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(posterior()), col="red", lwd=2, lty = 2)
      abline(v=mean(mean_d), col="green", lwd=2)
      legend(x="topright", legend=c("Prior","Likelihood","Posterior"),
             lty=c(2,1,2), lwd=2, col=c("Blue", "Green", "Red"),
             cex=1.5)
      

    }
    else if (input$prior == "trnorm") {
      priord <- dnorm(seq(0,200, length=1000), input$meant, sqrt(input$vart))
      ubound2 <- 1000/200*input$ubound
      lbound2 <- 1000/200*input$lbound
      priord[ubound2:length(priord)] = 0
      priord[1:lbound2] = 0
      
      # 95% Credible Interval
      lbound <- format(round(mean(posterior())-1.96*sd(posterior()), digits=2))
      ubound <- format(round(mean(posterior())+1.96*sd(posterior()), digits=2))
      
      plot(seq(0,200, length=1000), priord, 
           xlim=c(0,200),
           ylim=c(0,max(density(posterior())$y, likeli, 
                        priord)),
           main = "Truncated Normal prior", lwd=2, type="l", col="blue", lty = 2,
           ylab = "Density", xlab = paste(c("95% Credible Interval:"), "[",lbound,";",ubound,"]"))
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
    })
    
  
}