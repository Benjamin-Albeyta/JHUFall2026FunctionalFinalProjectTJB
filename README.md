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


Structure:
Data
  InitalData.cvs graph.cvs method.txt
src
  Library
    talon, graph etc etc
  Sampling
    Each file contains code for each sampling method
  Processing
    File for taking in data into code, file for putting out data into code, functordefinition.ml, module type
  bin
    main.ml, test.ml

Each subdirectory could have a dune, or there could be one overall

functordefinion.ml: Takes all the different types and uses those; ensuring viability of the program no matter the type of data input used

module type: would need all the information needed for the functor to then define

(Pick a variant type that better represents the states; rather than true and false and rather than 1,0)

Has Dict with 4 entries (T,T), (T,F), (F,T), (F,F):
  (T,T) - represents both values known
  (T,F) - first value known second unknown
  (F,T) - first value unknown second known
  (F,F) - both values unknown (as such no inital dict needed)

DictTT: contains a list of paired values that are known
DictTF: contains a list of single values known (unknown values not needed)
DictFT: contains a list of single values known (unknown values not needed)

sampling functions should take the DictTT and use that along with graph file and for example DictTF, to get a DictTF approximation via whatever method is given.

User Input:
- User provides a cvs file for the provided data, a cvs file for the graph representation and a file for specifying method (currently a .txt file)
- User recieves a cvs file for the data fully completed

Goal for later: 
- We need to call the graph first to output a list of the panda's variable, in order to sample ? for each of the columns, as it will need to be called repeatedly.