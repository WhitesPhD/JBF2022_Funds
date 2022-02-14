# JBF2022_Funds

Bootstrap implementation for the paper _**“On the Performance of Cryptocurrency Funds”**_ by Bianchi and Babiak (2022) 

The folder contains:

Main.m : the main Matlab file for data uploading, bootstrap selection and plot/table with the results.

Functions:

A folder with the functions to implement the bootstrap 
1. fnc_bootstrap_baseline.m (baseline bootstrap of the paper)
2. fnc_bootstrap_block.m (block-bootstrap)
3. fnc_bootstrap_independ.m (independent resampling bootstrap)

The data pertains 100 funds randomly selected from the original dataset of the paper. Funds are anonymised. The file contains the returns on a proxy for the market portfolio as a risk factor. Since there is no identification of the strategy in the dataset provided here, the bootstrap does not differentiate for the risk exposure to market risk across different strategies. However, in the paper we show that results do not change significantly by assuming a strategy-specific risk exposure. In addition, notice that the bootstrap pertains the alphas and the t-stat (non-robust). This option can be changed by changing the specification of the panel regression adding ‘vartype’,’cluster’ creating a group-specific clustering indicator (more details in the paper). 

Note:

To be implemented the bootstrap requires the installation of the Panel Data toolbox published by Javier Barbiero Ramirez. 

Link here: https://uk.mathworks.com/matlabcentral/fileexchange/51320-panel-data-toolbox-for-matlab

Alternatively, you could use any other in-house panel fixed-effect estimator you have created. 

