
%--------------------------------------------------------------------------
% This code replicates the main, block and independent resampling bootstrap
% specifictions of the paper "On the Performance of Cryptocurrency Funds" 
% by Bianchi and Babiak (2022).
%
% The data contains the anonimized fund returns and a proxy for the market 
% portfolio. 
%
% The exercise pertains the simple alpha and ols t-statistics based on the
% panel estimation. The dataset does not include the strategy classification
% so the panel bootstrap with clustered (at the strategy level) standard
% errors is not implemented.

clear all; clc; pause(0.01), randn('seed',3212), rand('seed',3212), warning off

% adding folders
addpath([pwd '/Data/']);
addpath([pwd '/Functions/']);
addpath([pwd '/Tables/']);

% upload data
Data        = readtable('DataReplication.xlsx','ReadVariableNames',true);

b           = 1000; % Set bootstrap iterations
y           = Data.returns; % fund returns
id          = Data.id; % fund ids
time        = Data.time; % time 

OKforReg    = (isfinite(y)); % check for inf and nan

% clean data for missing/inf/nan
y           = y(OKforReg);
id          = id(OKforReg);
time        = time(OKforReg);

% load the factor
X           = Data.mkt;
X           = X(OKforReg,:);


fe_boost    = panel(id,time,y,X,'fe');
[ieff, se, t, p] = ieffects( fe_boost );

vecY        = y;
mxX         = X;


boots_type  = '_main'; 


if strcmp('_main',boots_type)
    
    [mxBSAlpha, mxBSAlphaTstat, mxBSBetas, mxBSBetasTstat] = fnc_bootstrap_baseline(vecY,mxX,id,time,b);

elseif strcmp('_independent',boots_type)

    [mxBSAlpha, mxBSAlphaTstat, mxBSBetas, mxBSBetasTstat] = fnc_bootstrap_independ(vecY,mxX,id,time,b);

elseif strcmp('_block',boots_type)

    nblock     = 3;
    [mxBSAlpha, mxBSAlphaTstat, mxBSBetas, mxBSBetasTstat] = fnc_bootstrap_block(vecY,mxX,id,time,b,nblock);

end

% Generate the boxchart

alpha_boot = mean(sort(mxBSAlpha, 2))';
alpha_hat  = ieff;
alpha      = [[alpha_hat;alpha_boot],[ones(size(alpha_hat,1),1)*1;ones(size(alpha_hat,1),1)*2]];

t_boot     = mean(sort(mxBSAlphaTstat, 2))';
t_hat      = t;
tstat      = [[t_hat;t_boot],[ones(size(t_hat,1),1)*1;ones(size(t_hat,1),1)*2]];

figure(1)
tiledlayout(1,2)

ax1 = nexttile;
b = boxchart(ax1,alpha(:,1)*100,'GroupByColor',alpha(:,2),'Notch','on');
b(1,1).MarkerSize  = 10;
b(2,1).MarkerSize  = 10;
set(ax1, 'ActivePositionProperty', 'position','FontSize',24)
ylabel(ax1,'alpha (% monthly)')
xlabel(ax1,'alpha')
legend('Actual','Bootstrap')

ax2 = nexttile;
b = boxchart(ax2,tstat(:,1),'GroupByColor',tstat(:,2),'Notch','on');
b(1,1).MarkerSize  = 10;
b(2,1).MarkerSize  = 10;
set(ax2, 'ActivePositionProperty', 'position','FontSize',24)
ylabel(ax2,'t-stat')
xlabel(ax2,'t-stat')
legend('Actual','Bootstrap')


% Generate the table with the CDF

perc_cuts       = [1 10 20 30 40 50 60 70 80 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99, 100];
dec_points      = 2;

alpha_sim = 100*mean(sort(mxBSAlpha, 2), 1)';
alpha_act = 100*sort(alpha_hat);
tstat_sim = mean(sort(mxBSAlphaTstat, 2), 1)';
tstat_act = sort(t_hat);

alpha_sim_cuts  = prctile(alpha_sim, perc_cuts);
alpha_act_cuts  = prctile(alpha_act, perc_cuts);
tstat_sim_cuts  = prctile(tstat_sim, perc_cuts);
tstat_act_cuts  = prctile(tstat_act, perc_cuts);

alpha_funds_cuts  = nan(size(alpha_sim_cuts));
tstat_funds_cuts  = nan(size(alpha_sim_cuts));
num_funds_cuts  = nan(size(alpha_sim_cuts));

for i = 1:length(alpha_sim_cuts)
    
    num_funds_cuts(i)   = sum(alpha_sim<=alpha_sim_cuts(i));    
    alpha_funds_cuts(i) = 100*sum(alpha_act>=alpha_sim_cuts(i))/length(alpha_act);    
    tstat_funds_cuts(i) = 100*sum(tstat_act>=tstat_sim_cuts(i))/length(alpha_act);    
    
end

row_header              = {''};
column_header           = {''};
populate_data           = {''};

row_header(1:2,1)       = {' ', 'Pct'};
row_header(3:length(perc_cuts)+2,1)      = num2cell(perc_cuts');
column_header(1,1:7)    = {'Alpha', ' ',    ' ',    'Tstat',    ' ',    ' ',    'Funds'}; 
column_header(2,1:7)    = {'Sim',   ' Act', ' %>Sim', 'Sim',      'Act',   ' %>Sim', ' '}; 

populate_data(1:length(perc_cuts),1)   = num2cell(round(alpha_sim_cuts', dec_points));
populate_data(1:length(perc_cuts),2)   = num2cell(round(alpha_act_cuts', dec_points));
populate_data(1:length(perc_cuts),3)   = num2cell(round(alpha_funds_cuts', dec_points));
populate_data(1:length(perc_cuts),4)   = num2cell(round(tstat_sim_cuts', dec_points));
populate_data(1:length(perc_cuts),5)   = num2cell(round(tstat_act_cuts', dec_points));
populate_data(1:length(perc_cuts),6)   = num2cell(round(tstat_funds_cuts', dec_points));
populate_data(1:length(perc_cuts),7)   = num2cell(round(num_funds_cuts', dec_points));

Filename            = [pwd,'/Tables/CDFAlphasTstats.xls'];
data_cell           = populate_data;
info_to_write       = [row_header,[column_header; data_cell]];
writecell(info_to_write, Filename);
