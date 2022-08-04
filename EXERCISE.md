## Exercise

The exercise aims to play around with data and priors to see how these
influence the posterior using the Shiny App [First Bayesian
Infertence](https://github.com/Rensvandeschoot/First-Bayesian-Inference).

a) Pretend you know nothing about IQ except that it cannot be smaller than 40
and that values larger than 180 are impossible. Which prior will you choose?

b) Generate data for 22 individuals and run the Bayesian model (default
option). Write down the prior and data specifications, and download the plot.

c) Change the prior to a distribution which would make more sense for IQ: we
know it cannot be smaller than 40 or larger than 180, AND it is expected to be
normally distributed around 100 (=prior mean). However, how sure are you about
these values (=prior variance)? Try values for the prior variance of 10 and 1.
Write down the prior and data specifications, run the two models, and download
the plot. How would you describe the relationship between your level of
uncertainty and the posterior variance?

d) Now, re-run the model with a larger sample size (n=100). Write down the
prior and data specifications, run the model, and download the plot. How are
the current results different from the results under 'c'?

e) Repeat steps 'c' and 'd' but now for a different prior mean using a sample
size of 22 (assuming your prior knowledge conflicts with the data, e.g.,
IQ_mean=90). Write down the prior and data specifications, run the model, and
download the plot. How did the new results differ when compared to the results
with a 'correct' prior mean?

f) What happens if your prior mean is exceptionally far away from the data,
for example, IQ_mean=70 (using n=22). Write down the prior and data
specifications, run the model, and download the plot. How did the new results
differ when compared to the results with a 'correct' prior mean? Note that
this situation is extreme, and in reality, the prior is much closer to the
data.

g) So far, we assumed the variance of IQ to be known, which is not realistic.
Re-run models 'e' and 'f'' using the option 'Run with Sigma Unknown'. In the
background, the software JAGS estimates the mean of IQ and its variance using
MCMC-sampling. The posterior is no longer analytically obtained but is
approximated. As a result, the posterior distribution looks wobbly, and every
time you hit the 'run'-button, it will look a bit different (give it a try).
Can you describe the difference between the previous results under 'f'' and
the current results? If you run the model again, but with n=50 the posterior
is again a compromise between the prior and the data. Can you explain? (Note
that this is a difficult question!)
