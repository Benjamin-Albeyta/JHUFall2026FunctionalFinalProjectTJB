# JHUFall2026FunctionalFinalProjectTJB

# Trung Phung, Jung Yoon, Benjamin Albeyta

- Library:
  - csv is a bit outdated, 2019
  - Raven features:
    Supports loading CSV datasets and transforming data.
    - For python like functionality handling dataset
  - Graph:
    Choose to just use or implement our own
    - Either fork
    - Or create our own graph function based on our needs
- Data Structure
  - Immuatable array
    - Keys: Headers
    - Values: Columns
- Questions/Suggestions
  - How do we represent N/A or mixed types
  - Use option to handle N/A
  - Use functors for different data types


- Abstract:
  Missing data is a pervasive problem in data science. It happens when there are "?" or "NA" symbol in
  the data table, instead of the usual values (numbers). This project is the state-of-the-art imputation
  algorithm for data missing-not-at-random. Description:
    1. The user is required to provide a data file (e.g., .csv file) to the program.
    2. The program fires up an UI for user to draw a graph which represents the data generation
        process (nodes, edges between nodes).
    3. The user choose an algorithm in the list.
      1. complete-case analysis : simply delete all rows with missing data
      2. expectation maximization
      3. a research code that recursively fit and sample distributions.
    4. The program takes both the data and the graph and impute missing values (denoted by "NA" in
        the data file), write the imputed data to an output file.
      1. This process involves fitting models using the given data, and sampling from the fitted
          distribution.
    5. Also, it could be cool if our program had a way to randomly remove some data entries. That would
        let us compare the original data with the imputed results and see how well different imputation
        methods perform. Since we'd know the true values ahead of time, we could get a better sense of
        the accuracy of each algorithm and give users an idea of the range of error they can expect.