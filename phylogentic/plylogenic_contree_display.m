function plylogenic_contree_display(G)
% Display a digraph consensus tree G
%
% Example:
%   plylogenic_contree_display(G);
%
% (C) 2026 Moo K. Chung
% University of Wisconsin-Madison

if nargin < 2
    figTitle = 'contree';
end

figure('Color','w');
p = plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'Interpreter','none'); % <— FIX: underscores not subscripts


% Optional: visually distinguish leaves vs internal nodes (no error checking)
leafIdx = find(G.Nodes.type=="leaf");
intIdx  = find(G.Nodes.type=="internal");

highlight(p, leafIdx, 'MarkerSize', 4);   % you may adjust sizes
highlight(p, intIdx,  'MarkerSize', 2);

end