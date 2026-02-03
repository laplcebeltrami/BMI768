function H = phylogenetic2graph(P)
% PHYLOGENETIC2GRAPH
% Strip all labels/metadata from digraph P (from phylogenetic_contree_read)
% and keep only the underlying directed graph structure (parent -> child).
%
% Output:
%   H : digraph with vertices 1..n, no node names, no edge attributes.
%
% Example:
%   P = phylogenetic_contree_read('L387.0.fasta.contree');
%   H = phylogenetic2graph(P);
%
% (C) 2026 Moo K. Chung
% University of Wisconsin-Madison

E = P.Edges.EndNodes;             % [m x 2] node names: parent -> child
names = string(P.Nodes.Name);     % [n x 1] node names

[~, s] = ismember(string(E(:,1)), names);   % parent indices
[~, t] = ismember(string(E(:,2)), names);   % child indices

H = digraph(s, t);                % <— FIX: directed graph (parent → child)

end
