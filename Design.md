# JHUFall2026FunctionalFinalProjectTJB
# Trung Phung, Jung Yoon, Benjamin Albeyta

1. Overview of the purpose of the project:
Missing data is a pervasive problem in data science. It happens when there are "?" or "NA" symbol in the data table, instead of the usual values. This project is the state-of-the-art imputation algorithm for data missing-not-at-random. This will be accomplished through the use of a variety of sampling techniques, such as a sample from an assumed uniform distribution, or gibbs sampling; in relation to user provided CSV data sets; and a graph giving the relations between the provided data.

2. Complete Mock use of the application:
A mock use of the application would include the folder_path data_filename, vertex_filename, edge_filename, method name and result_filename. The user would provide the folder the exe would be pointed at in folder_path, as well as the name of the provided data file, the vertex data file name and the edge data file name; all of which are CSV files. Alongside the method name (the amount of methods we are going to implement depends on time so I will not list out all possibilities here) and a result filename which will make a new file with the unknown data filled in based on the method specified by the user; this file will be created in the same folder specified.

Supposed this is the Data:

This is the Verticies:

This is the Edges:


3. A list of libraries you are using or plan to use in your implementation.
We will be using the OCamlGraph library, which we have specified works in demo subfolder. 

4. Commented module type declarations (.mli files) which will be your initial specification. 

5. An implementation plan: a list of the order in which you will implement features and by what date you hope to have them completed.
TP JY BA
_____________________________________________________________________________________________________________________________________
|                   Task                    |  Responsible  |    To-Do Date     | Completed |               Comments                |
_____________________________________________________________________________________________________________________________________
|       Create .mli Files                   |     TP/JY     |    11/18/2026     |   Done    |                                       |
|       Install OCaml Graphs library        |      All      |    11/18/2026     |   Done    |                                       |
|       Finish the Design.md doc            |      BA       |    11/18/2026     |           |                                       |  
|       Create Basic Dune files             |      All      |    11/18/2026     |           |                                       |  
|       Create CSV intake processing        |      TBD      |    11/22/2026     |           |                                       |  
|       Create d-seperation processing      |      TBD      |    11/28/2026     |           |                                       |  
|       Create --help lines                 |      JY       |    11/18/2026     |           |                                       |  
|       Create functor definition file      |      TBD      |    11/25/2026     |           |                                       |  
|       Create CSV output processing        |      TBD      |    11/23/2026     |           |                                       |  
|       Create Base Sampling                |      TBD      |    11/30/2026     |           |                                       |  
|     Create Tests for base sample type     |      TBD      |    11/30/2026     |           |                                       |  
| Create structure for choosing sample type |      TBD      |    11/20/2026     |           |                                       |  
|       Create / implement main             |      TBD      |    12/1/2026      |           |                                       |
_____________________________________________________________________________________________________________________________________

Include a couple sentences here below: / include the creations of the other sample types after the inital date here and make this presented a bit better

6. You may also include any other information that will make it easier to understand your project.