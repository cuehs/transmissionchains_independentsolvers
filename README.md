# Transmission Chains or Independent Solvers? A Comparative Study of Two Collective Problem-Solving Methods


Complete experimental paradigm, simulation code, evaluation code, and data to replicate the results from:
``Transmission Chains or Independent Solvers? A Comparative Study of Two Collective Problem-Solving Methods``

## Getting Started

The project structure consists of three main parts

 1) The experimental paradigm in *experiment*
 2) The experimental data in *data*
 3) Evaluation and simulation code in *evaluation*
 
## Experiment

The experiment requires Java 1.7 for the backend server and a web browser supporting websockets on the participants device.  
To run the experiment:
 0) Download and unpack [jetty](https://www.eclipse.org/jetty/)
 1) change the IP address (``$IP``) in ``experiment/frontend/js/index.js`` to the correct ``$IP`` of the server
 2) change the pathPrefix in ``experiment/backend/World.java`` (``$filepath``). The variable should point to the landscape file.
 3) build java artifact 
 4) copy java artifact to ``webapp`` jetty folder
 5) copy ``landscapes.json`` (for example from ``data/full/``)  to ``$filepath``
 6) SSH to server and copy webapp to server
 7) set jetty home to the home of the unpaced jetty folder (``JETTY_HOME=``)
 8) go to jetty home (``cd $JETTY_HOME``)
 9) start server in screen and detach (``screen -d -m java -jar $JETTY_HOME/start.jar jetty.http.port=8082``)
 10) check if server is running (open browser to ``$IP:8082``)
 
## Data

All data is saved in csv or json files. With the exception of landscapes.json all data is [tidy](https://en.wikipedia.org/wiki/Tidy_data).

### movement.csv

All participants' decisions

```
time, playerId, level, type, step, behavior, values, mask
```

Column ``type`` determines if the value of ``position`` or ``payoff`` is in the column ``values``.  
Column ``behavior`` is either ``**s**starting position``, ``**e**nd position*, ``**n**ew solution``, or ``**b**ack to the last solution``.  
Column ``mask`` determines the dimensions a participant can manipulate.  

### participant.csv

Demographic information of all participants

```
starting time, userid id, age, gender
```

### structure.csv

Relationship between playerId, level, and landscape

```
playerId,level,landscapeId,isSmooth,isSequential,isLowStrength,times
```
Column ``landscapeId`` relates to the landscape id in the ``landscapes.json`` file.  
Column ``isSmooth`` is true, if the landscape is a K=1 landscape. Otherwise the landscape is K=8.  
Column ``isSequential`` describes if this line is part of a transmission chain (true) or indipendend solver group (false).  
Column ``isLowStrength`` is true, if S=3. Otherwise S=8.  

### landscapes.json

NK-landscapes normalized according to the procedure described in the manuscript

one line is one landscape as key-value pairs

## Data analysis

The data analysis uses R version 3.4.1. It heavily relies on the [tidyverse](https://www.tidyverse.org/). 

### load and preprocess experimental data

run ``read_data.R ``

### run simulations

run ``run_simulation.R ``

### figures

run ``read_data.R ``
run ``run_simulation.R ``
run ``compare_exp_sim.R ``

## Authors

See the list of [contributors](contributors.txt) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
