


# 🟡 Advanced EDA Dashboard (Shiny)
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/24c1aca1-16f0-4937-ab7c-fdbaa1b3d3ed" />



**Interactive R Shiny dashboard for Comprehensive Exploratory Data Analysis (EDA).** Quickly analyze your dataset without writing complex code.

---

## 🔹 Features

* **Overview**

  * Upload CSV files and preview datasets
  * View total rows, columns, missing values, and missing %

* **Numeric Analysis**

  * Histograms & boxplots for numeric variables
  * Key statistics: Mean, Median, Standard Deviation, Skewness

* **Categorical Analysis**

  * Bar charts & pie charts for categorical variables

* **Advanced Analytics**

  * Outlier detection (IQR method)
  * Normality testing (Shapiro-Wilk)
  * Predictive modeling with linear regression

    * Option to select variables manually or use best correlated variables

* **Interactive & Visual**

  * User-friendly dashboard with KPIs and responsive charts
  * Clean and colorful design using `shinydashboard`

---

## 🔹 Benefits

* Quickly understand and explore any CSV dataset
* Identify patterns, anomalies, and statistical insights instantly
* Helps students, analysts, and professionals save time and make data-driven decisions

---

## 🔹 Libraries Required

```R
shiny, shinydashboard, DT, ggplot2, dplyr, e1071, corrplot
```

---

## 🔹 How to Run

1. Install the required libraries.
2. Save the R script as `app.R`.
3. Run in RStudio or R console:

```R
shiny::runApp("path/to/app.R")
```

4. Upload a CSV file and start exploring your data.

---

✅ **Professional, interactive, and easy-to-use dashboard for fast EDA.**



