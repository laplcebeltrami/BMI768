function graph_directed_plot(coord, elist, weights, color_edge)
% Graph_directed_plot  Plot a directed graph with given node coordinates,
% edge list, and edge weights.
%
% INPUTS
%   coord   : n-by-2 node coordinates [x y]
%   elist   : m-by-2 edges [u v] (1-based node indices)
%   weights : m-by-1 edge weights (real, non-sparse). If empty or wrong
%             length, defaults to ones(m,1).
%   color_edge       : edge color
%
% OUTPUT
%   A plotted directed graph.
%   
%
% (c) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu 
% 
% The code is downloaded from 
% https://github.com/laplcebeltrami/hodge
% If you are using the code, refernce one of Hodge papers listed in GitHub.  
%
% Update history: November 7, 2025


% Ensure types/shapes that digraph accepts
elist   = full(double(elist));
Estart  = elist(:,1);
Eend    = elist(:,2);

m = size(elist,1);
n = size(coord,1);


% Weights: make real, full, double column; default to ones if empty/mismatch
if isempty(weights)
    weights = ones(m,1);
end

% build digraph 

n = size(coord,1);                                    % <— FIX
G = digraph(Estart, Eend, weights, n);                % <— FIX

p = plot(G, ...
    'Layout', 'force', ...
    'LineWidth', 4, ...
    'NodeColor', [0 0 0], ...
    'MarkerSize', 10, ...
    'NodeFontSize', 20, ...
    'EdgeFontSize', 20);

p.XData = coord(:,1);
p.YData = coord(:,2);

p.ArrowSize = 15;                                    
p.EdgeColor = color_edge;


% Axes cosmetics
ax = gca;
set(ax, 'FontSize', 10, 'XTick', [], 'YTick', []);
ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];
%set(gcf, 'Position', [200 200 300 250]);


% Hide all built-in labels 
p.EdgeLabel = strings(m,1);



end