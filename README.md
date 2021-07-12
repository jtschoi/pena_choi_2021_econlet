# Data Acquisition and Analyses Files for [Peña and Choi (2021, *Economics Letters*)](https://www.sciencedirect.com/science/article/abs/pii/S0165176521002457)

- Authors: Pablo Peña (pablo@uchicago.edu) and Jun Ho Choi (junhoc@uchicago.edu)
- For questions related to the files in this repository and their maintenance, please contact Jun Ho Choi (junhoc@uchicago.edu).

This repository contains files for acquiring, cleaning, conducting analyses and producing figures with the Wikidata data utilized in the article **["Female representation among notable people born in 1700-2000" (Peña and Choi, 2021, *Economics Letters*)](https://www.sciencedirect.com/science/article/abs/pii/S0165176521002457)**. Contents are as follows.

## Contents

1. [`1_wikidata_retrieve_and_clean/wikidata_retrieve_and_clean.ipynb`](https://github.com/jtschoi/pena_choi_2021_econlet/blob/master/1_wikidata_retrieve_and_clean/wikidata_retrieve_and_clean.ipynb): for acquiring and conducting initial clean-up of data from Wikidata using Python and SPARQL
2. [`2_analyses_and_chart_creation/charts_with_results_1700-2000.do`](https://github.com/jtschoi/pena_choi_2021_econlet/blob/master/2_analyses_and_chart_creation/charts_with_results_1700-2000.do): for analyzing data (acquired using the above-mentioned `.ipynb` file) and producing figures used in Peña and Choi (2021, *Economics Letters*)
3. [`2_analyses_and_chart_creation/countries_by_population.xlsx`](https://github.com/jtschoi/pena_choi_2021_econlet/blob/master/2_analyses_and_chart_creation/countries_by_population.xlsx): necessary file to be used in conjunction with the above-mentioned `.do` file; load the file in a relevant directory as described in the said `.do` file

## Data (originating from Wikidata) utilized in Peña and Choi (2021, *Economics Letters*)

As described in the `.ipynb` file in this repository, due to Wikidata and Wikipedia going through constant updates in their contents, a user may find slightly different results when having downloaded the data as directed in the `.ipynb` file. Therefore, we provide the data we collected in November 2020 and utilized in our article. Please follow [**this Dropbox link**](https://www.dropbox.com/sh/fstus2hcedpd2od/AABtJ_irbh2SIhWQUJMgYbY3a?dl=0) to acquire the said data. The files are in `.csv` format and are organized by countries (designated with relevant ISO 3166-1 alpha-3 codes).
