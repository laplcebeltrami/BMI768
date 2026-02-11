function flow2display(edgeflows, E, vertices, q)
% FLOW_TO_DISPLAY  Plot directed edge flows (top-q by |flow|) on given vertices.
%
% INPUTS
%   edgeflows : (m x 1) edge-flow values aligned with E (signed preferred)
%   E         : (m x 2) edge list (any orientation). Function enforces i<j base.
%   vertices  : (p x 2) or (p x 3) node coordinates
%   q         : number of *largest-|flow|* directed edges to display
%
% Notes
%   - Use this for visualizing one slice of Ytau_all by passing edgeflows = Ytau_all(:,t).
%   - Colormap is fixed to winter(256) (cold map).
%   - Direction is encoded by sign(edgeflows): + => a->b, - => b->a (after i<j base).
%
% (C) 2026 Moo K. Chung
% University of Wisconsin–Madison

edgeflows = edgeflows(:);

% --- enforce i<j base orientation and make flow sign relative to base ---
Ei = E(:,1); Ej = E(:,2);
swapMask = Ei > Ej;
a = Ei; b = Ej;
a(swapMask) = Ej(swapMask);
b(swapMask) = Ei(swapMask);
flows = edgeflows;
flows(swapMask) = -flows(swapMask);     % <— flip sign if endpoints swapped

% --- rank by |flow| ---
[~, order] = sort(abs(flows), 'descend');
q    = min(q, numel(flows));
keep = order(1:q);

a     = a(keep);
b     = b(keep);
flows = flows(keep);
Wmag  = abs(flows);

% --- build directed list from sign(flows) ---
sgn = sign(flows);
sgn(sgn==0) = 1;                         % draw forward for zeros
Emat = [ a.*(sgn>=0) + b.*(sgn<0), ...
         b.*(sgn>=0) + a.*(sgn<0) ];

% --- coordinates ---
coord = vertices;
if size(coord,2) == 2
    coord(:,3) = 0;
end
coord(:,2) = -coord(:,2);                % <— keep your display convention

p = size(coord,1);

% --- cold colormap ---
cmap = winter(256);

% --- build directed graph and base plot ---
hold on;
G = digraph(Emat(:,1), Emat(:,2), Wmag, p);
%P = plot(G, ...
%    'XData', coord(:,1), 'YData', coord(:,2), 'ZData', coord(:,3), ...
%    'Marker', 'none', 'NodeLabel', {}, 'NodeColor', 'none');

% Add a small offset (e.g., 1 or 2 units) to ensure it sits above the mesh
P = plot(G, ...
    'XData', coord(:,1), 'YData', coord(:,2), 'ZData', coord(:,3) + 1, ... 
    'Marker', 'none', 'NodeLabel', {}, 'NodeColor', 'none');


P.LineWidth = 0.4;
P.EdgeColor = [0.85 0.85 0.85];
P.ArrowSize = 10;

% --- per-edge color from magnitudes ---
numColors = size(cmap,1);
wmin = min(Wmag); wmax = max(Wmag);

if wmax > wmin
    idx = round( (Wmag - wmin) / (wmax - wmin) * (numColors-1) ) + 1;
else
    idx = ones(size(Wmag));
end
idx = max(1, min(numColors, idx));
C   = cmap(idx,:);

% --- width scaling by magnitude ---
if wmax > wmin
    LW = 0.8 + 2.2 * (Wmag - wmin) ./ (wmax - wmin);
else
    LW = 1 * ones(size(Wmag));
end

for e = 1:numedges(G)
    highlight(P, Emat(e,1), Emat(e,2), 'EdgeColor', C(e,:), 'LineWidth', LW(e));
end

set(gcf,'Renderer','opengl');
set(gca,'SortMethod','childorder');
end