% GOAL: Investigating cyclic interaction between multiple time-varying signals
% using the mathemtical ground truth. To do so, we need to
% design a simulation (toy example), where underlying signal has cycles from 
% the start.
% 
% MINIGOAL: We will learn AI-aided coding and building a new  data structure. 
%
% (c) 2026 Moo K. Chung
% University of Wisconsin-Madison

%% Building a grid as 2D cell complex. 
% A cell complex is a combinatorial representation of a space 
% composed of nodes (0-simplices), edges connecting pairs of nodes 
% (1-simplices), and filled-in faces (2-cells) bounded by closed loops of edges. 
% In a two-dimensional grid, each face is typically a square bounded 
% by four edges, explicitly encoding local surface structure beyond pairwise 
% connectivity.

% Such a data structure is not natively supported in MATLAB. 
% We therefore first construct a cell complex data structure to 
% explicitly represent nodes, edges, and faces.
clear; clc;
S = cellcomplex_build(4, 4);
figure; cellcomplex_display(S)

S = cellcomplex_build_checkerbaord(4, 4)
figure; cellcomplex_display(S)

%AI Sanity check - check if AI followed edge indexing in S.faces.edges.   
cellcomplex_summary(S)

%We will perturb the direction of edges with probability p
seed =1; %random number seed
p = 0.1 %fraction of perturbation
Sp = cellcomplex_perturb_edges(S, p, seed); %by default edge directions are randomly pertrubed. 
figure; cellcomplex_display(Sp)

% We will perform edge deletion operation to make the shape more complex. 
% An Erdős–Rényi (ER) random graph model introduces randomness by deciding 
% whether each edge is present independently with a fixed probability p. 
% In the classical G(n,p) model, any pair of nodes amng n-nodes can be 
% connected with probability p. In our setting, randomness is applied in 
% an ER-type manner by independently removing each edge of a fixed grid with 
% probability p.

seed = 2; %random number seed
Spr = cellcomplex_remove_edges(Sp, 0.1, seed)
figure; cellcomplex_display(Spr)

% Introduce flow field on the cell complex. 
% Scalar data on edeges. Default flow will be simply the current edge orientation. 
Sprf = cellcomplex_flow (Spr);
figure; cellcomplex_display(Sprf)

% Genearte time series that follows the given flow pattern. 
% The model is based on Vector Auto regressive (VAR) model, which we will study in one lecture.  
p=4; noise_level = 1
Z = VAR_graph(Sprf.edges,Sprf.flows, p, noise_level) % Used existing codes written for 2025 class. 

figure; cellcomplex_display(Sprf)
graph_overlay_timeseries(Sprf.nodes, Z);