import pickle
import pystan


def stan_fit(name, model_code, data, verbose=False):
    stanc_ret = pystan.stanc(model_code=model_code, verbose=verbose)
    dump('%s_stanc' % name, stanc_ret)
    print(stanc_ret)

    stan_model = pystan.StanModel(stanc_ret=stanc_ret, verbose=verbose)
    dump('%s_model' % name, stan_model)
    print(stan_model)

    stan_fit = pystan.stan(model_code=model_code, data=data, verbose=verbose, n_jobs=1)
    dump('%s_fit' % name, stan_fit)
    print(stan_fit)


def dump(name, obj):
    with open(name + '.pkl', 'wb') as fp:
        pickle.dump(obj, fp)


def test_schools():
    schools_code = """
    data {
        int<lower=0> J; // number of schools
        real y[J]; // estimated treatment effects
        real<lower=0> sigma[J]; // s.e. of effect estimates
    }
    parameters {
        real mu;
        real<lower=0> tau;
        real eta[J];
    }
    transformed parameters {
        real theta[J];
        for (j in 1:J)
            theta[j] = mu + tau * eta[j];
    }
    model {
        eta ~ normal(0, 1);
        y ~ normal(theta, sigma);
    }
    """
    schools_dat = {'J': 8,
                   'y': [28,  8, -3,  7, -1,  1, 18, 12],
                   'sigma': [15, 10, 16, 11,  9, 11, 10, 18]}
    stan_fit('schools', schools_code, schools_dat, verbose=True)


def test_matrix():
    model_code = """
    data {
        int<lower=0> n;
        int<lower=0> m;
        real A[n, m];
        real y[n];
    }

    parameters {
        real delta[m];
    }

    transformed parameters {
        real w[n];
        for (i in 1:n) {
            w[i] = dot_product(A[i], delta);
        }
    }

    model {
        y ~ normal(w, 1);
    }
    """
    data = {'n': 2,
            'm': 3,
            'A': [[-1, 0, 1], [0, -1, 1]],
            'y': [0, 1]}
    stan_fit('matrix', model_code, data, verbose=True)


if __name__ == "__main__":
    test_schools()
    test_matrix()
