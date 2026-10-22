# Identifying Mothers and Their Children in Historical US Census Data (Stata)

A Stata code sample from a research assistant project on historical nonmarital fertility in the United States (York University). The code identifies mothers and links them to their children within households in IPUMS full-count census data, one census year at a time.

The census data are not included in this repository, so the code cannot be run as-is. It is shared as a sample of how I work with large historical microdata in Stata.

## What the code does

- **Processes each census year in manageable chunks.** Each year's full-count file is split into subsets of roughly 5 million observations by household (`serial`), so households are never split across chunks.
- **Identifies mothers** using the IPUMS family-interrelationship variables (`momloc`, `stepmom`, `momrule_hist`), in three versions:
  - `mother_v1`: any woman identified as the mother of someone in the household
  - `mother_v2`: women with stepchildren or adopted children
  - `mother_v3`: biological mothers
- **Links mothers to children by the child's age.** For each age `a`, from 0 to 15, it creates an indicator for mothers of a child of that age (`mother_v1_a`, `mother_v2_a`, `mother_v3_a`).
- **Finds the oldest biological child** in the household for each mother (`eldch_bio`) and flags women who have only biological children (`bio_mom`).
- **Calculates age at first birth** (the mother's age minus the age of her oldest biological child in the household) and groups it into age cohorts (10-14, 15-19, 20-24, 25-29 and 30-35).
- **Adds the household head's occupation** (`head_occ`) to each person in the household.


## Files

| File | Description |
|---|---|
| `code/identify_mothers.do` | Identifies mothers and links them to their children |

## Using the code

The script expects this folder layout under a project folder, which you set with the `maindir` global at the top of the script:

```
<project folder>/
├── extracts/      one full-count extract per census year, named like 1880_100%.dta
└── clean_data/    output: mothers_<year>.dta
```

Each extract needs the variables `serial`, `pernum`, `age`, `occ1950`, `momloc`, `stepmom` and `momrule_hist`. As written, the script runs for 1880. To process other census years, add them to the `foreach y in ...` list. A log file for each year is written to the project folder.
