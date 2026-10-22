# Bank of Canada Governor's Challenge: Impulse Response Analysis (R)

R code from our team's work in the Bank of Canada Governor's Challenge (September to November 2024, York University). The script estimates how Canadian CPI, real GDP and unemployment respond to an interest rate shock using local projections, and plots the responses to a 25 basis point rate cut.

> This folder is a shortened version of the project. The full repository, including the dataset-construction script and plots with superimposed confidence bands, is here: https://github.com/khushishah-18/Bank-of-Canada

## What the code does

- Reads a quarterly Canadian dataset (1996 Q1 to 2024 Q2; sources: Statistics Canada, the Bank of Canada, FRED and Yahoo Finance)
- Estimates a separate linear local projection for each outcome with `lp_lin` from the `lpirfs` package: 4 lags, a 12-quarter horizon, and controls for the exchange rate and lagged changes in the VIX, commodity prices and the S&P 500
- Plots each impulse response with confidence bands in `ggplot2`

## Files

| File | Description |
|---|---|
| `code/02_impulse_responses.R` | Estimation and plotting |
| `data/BOCdatatrim.csv` | Quarterly dataset used by the script |

## Running the code

Install the packages with `install.packages(c("tidyverse", "lpirfs", "ggview"))`. Set the R working directory to this folder and run `code/02_impulse_responses.R`.

## Note

This is shared for demonstration purposes and does not present the final results or the final version of the code and data used in the competition. It is a working version of the script, not a cleaned-up pipeline.
