function graph_directed_plot(coord, elist, weights)
% Graph_directed_plot  Plot a directed graph with given node coordinates,
% edge list, and edge weights.
%
% INPUTS
%   coord   : n-by-2 node coordinates [x y]
%   elist   : m-by-2 edges [u v] (1-based node indices)
%   weights : m-by-1 edge weights (real, non-sparse). If empty or wrong
%             length, defaults to ones(m,1).
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
else
    weights = full(double(weights(:)));
    if numel(weights) ~= m
S        warning('weights has length %d but elist has %d rows; using ones.', numel(weights), m);
        weights = ones(m,1);
    end
    if ~isreal(weights)
        warning('weights is complex; using real(weights).');
        weights = real(weights);
    end
    if any(isnan(weights) | isinf(weights))
        warning('weights contains NaN/Inf; replacing with zeros.');
        bad = isnan(weights) | isinf(weights);
        weights(bad) = 0;
    end
end

% -------- build digraph --------
G = digraph(Estart, Eend, weights);

% Labels rounded for readability
EWeights = round(G.Edges.Weight, 3);

% -------- plot --------
p = plot(G, ...
    'Layout', 'force', ...         % initial layout (will be overwritten by coords)
    'EdgeLabel', EWeights, ...
    'LineWidth', 4, ...
    'NodeColor', [0 0 0], ...
    'MarkerSize', 10, ...
    'NodeFontSize', 20, ...
    'EdgeFontSize', 20);

% Set node coordinates
p.XData = coord(:,1);
p.YData = coord(:,2);

% Arrow/edge style
p.ArrowSize = 20;
p.EdgeColor = 'k';

% Axes cosmetics
ax = gca;
set(ax, 'FontSize', 10, 'XTick', [], 'YTick', []);
ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];
%set(gcf, 'Position', [200 200 300 250]);




% ======== Custom edge styling/labels with de-overlap and 0.1 highlighting ========
hold on;

% 1) Hide all built-in labels (we will draw our own)  <— avoid overlap with defaults
p.EdgeLabel = strings(m,1);


for k = 1:m
    i = Estart(k); 
    j = Eend(k);

    % Midpoint and a small normal offset to avoid collisions
    vi   = coord(i,:); 
    vj   = coord(j,:);
    mid  = (vi + vj)/2;
    dirv = vj - vi;
    nrm  = [-dirv(2), dirv(1)];
    if any(nrm)      % normalize if nonzero
        nrm = nrm / norm(nrm);
    end
    pos  = mid + 0.06 * nrm;  % <— tweak 0.06 as needed for your scale

    if weights(k) >= 5
        % Green edge + arrowhead  <— highlight target edges
        highlight(p, i, j, 'EdgeColor', [0 0.5 0]);  % dark green

        % Green, bold label for 0.1  <— custom label
        text(pos(1), pos(2), sprintf('%.1f', weights(k)), ...
            'Color', [0 0.5 0], 'FontSize', 20, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    else
        % Black label for other edges
        text(pos(1), pos(2), sprintf('%.3g', weights(k)), ...
            'Color', 'k', 'FontSize', 20, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end

axis off; box off; grid off

end