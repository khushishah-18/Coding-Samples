# Cannabis Legalization and Canadian Labour Productivity (Python)

*Causal evaluation of Canada's 2018 recreational cannabis legalization using the synthetic control method.* Group project for ECON 526 at UBC, co-authored with Roa'a Hamed.

> This folder is a shortened version of the project. The full notebook, including covariate selection and additional robustness checks, is in the full repository: https://github.com/khushishah-18/ECON-526---Roa-a-Khushi

## Research question

Did the legalization of recreational cannabis in Canada in 2018 causally affect labour productivity?

## Data

- Labour productivity (GDP per hour worked, USD) and country-level covariates for 37 countries, annual, 1997 to 2023 (`scm_dataset.csv`)
- Treated unit: Canada. Pre-treatment period 1997 to 2018, post-treatment period 2019 to 2023.
- Donor pool: the other countries, excluding the United States (state-level legalization during the pre-treatment period) and the Netherlands (decriminalization).

## Method

- **Synthetic control** with donor weights constrained to be non-negative and sum to one (simplex), matching on productivity, investment and industry, using the `scpi_pkg` package. Variables are standardized before estimation.
- **Treatment effect** is the gap between Canada's actual productivity and its synthetic control.
- **Placebo (permutation) inference:** the same procedure is applied to each donor country as if it had been treated, then compared with Canada's gap using post/pre prediction error ratios and placebo-based p-values.

## Results

Canada's gap relative to its synthetic control (USD per hour worked) was small and mixed in sign across the post-treatment years: -0.31 (2019), +2.66 (2020), +0.42 (2021), +0.60 (2022) and -0.43 (2023). None of these is unusual relative to the placebo distribution (one-sided placebo p-values between 0.31 and 0.86), so the analysis does not provide evidence of an effect on aggregate productivity. The post-treatment period is short, which limits what the method can detect.

## Files

| File | Description |
|---|---|
| `SCM - Cannabis (sample).ipynb` | Shortened notebook: data preparation, synthetic control estimation, treatment effects, and placebo inference |
| `scm_dataset.csv` | Dataset used in the analysis |

## Running the notebook

Install the packages: `pip install pandas numpy matplotlib scikit-learn plotly scpi_pkg`. Open the notebook from this folder so that it can find `scm_dataset.csv`.
