data {
    int<lower=0>       N;        // Number of effect sizes
    int<lower=0>       K;        // Number of Studies
    vector[N]          Y;        // Effect sizes
    vector<lower=0>[N] V;        // Variance of ES
    int<lower=0>       Study[N]; // Study indicator
}

parameters {
    vector[K] theta_dummy;       // Study effects
    vector[N] d_dummy;           // True effects
    vector<lower=0>[K] sigma;    // Study level variance
    real mu;                     // Mean effect size
    real<lower=0> tau;           // Between study variance 
}

transformed parameters {
    vector[K] theta;
    vector[N] d;
    for (i in 1:K){
        theta[i] = mu + theta_dummy[i] * tau;
    }
    for (i in 1:N){
        d[i] = theta[Study[i]] + d_dummy[i] * sigma[Study[i]];
    }
}

model {
    // Model
    for (i in 1:N){
        Y[i] ~ normal(d[i], sqrt(V[i]));
    }
    d_dummy ~ normal(0,1);
    theta_dummy ~ normal(0,1);
    
    // Prior
    mu ~ normal(0, 1);
    tau ~ student_t(3, 0, 0.5);
    sigma ~ inv_gamma(3, 0.5);   
}