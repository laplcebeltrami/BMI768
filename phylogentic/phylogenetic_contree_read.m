function G = phylogenetic_contree_read(filename)
% For each nuclear locus (e.g., L63), the authors aligned the DNA 
% sequences across individuals and then inferred a phylogeny many 
% times—typically using bootstrap resampling in IQ-TREE. Each bootstrap 
% replicate gives a slightly different tree because the data are noisy. 
% Instead of keeping thousands of replicate trees, IQ-TREE summarizes 
% them into a consensus tree. That consensus tree is written as the 
% extension .contree.
% 
% Load  *.contree Newick tree and return a digraph G with information 
% stored in G.Nodes and G.Edges. 
%
% Output (stored in G)
%   G.Nodes.Name    : node labels (leaves are taxa, internals are I1,I2,...)
%   G.Nodes.type    : "leaf" or "internal"
%   G.Edges.parent  : parent node name (string)
%   G.Edges.child   : child node name (string)
%   G.Edges.file    : source filename (string)
%
% (C) 2026 Moo K. Chung
% University of Wisconsin-Madison

% --- read file (raw Newick)
nwk_raw = strtrim(fileread(filename));

% --- sanitize IQ-TREE / SumTrees Newick -> topology-only Newick
nwk = nwk_raw;
nwk = regexprep(nwk, '^\s*\[&R\]\s*', '');        % remove [&R] if present
nwk = regexprep(nwk, '\[[^\]]*\]', '');           % remove [...] annotations
nwk = regexprep(nwk, '\)\-?\d+(\.\d+)?', ')');    % <— FIX: remove support labels like ")100" or ")0.95"
nwk = regexprep(nwk, ':[^,)\s;]+', '');           % remove branch lengths
nwk = regexprep(nwk, '\s+', '');                  % remove whitespace
if isempty(nwk) || nwk(end) ~= ';'
    nwk = [nwk ';'];                               % ensure terminator
end

% --- convert Newick -> edge list + node table
[edgesS, edgesT, nodeNames, nodeType] = local_newick_to_edgelist(nwk);

% --- build digraph and store metadata
G = digraph(edgesS, edgesT);

% enforce node order consistency for metadata assignment
[tf, idx] = ismember(G.Nodes.Name, nodeNames);
nodeType2 = strings(numel(G.Nodes.Name),1);
nodeType2(tf) = nodeType(idx(tf));
G.Nodes.type = nodeType2;

G.Edges.parent = string(G.Edges.EndNodes(:,1));
G.Edges.child  = string(G.Edges.EndNodes(:,2));
G.Edges.file   = repmat(string(filename), numedges(G), 1);

end


function [edgesS, edgesT, nodeNames, nodeType] = local_newick_to_edgelist(nwk)
% LOCAL_NEWICK_TO_EDGELIST
% Plain Newick -> edge list (parent->child) + node names/types.
% Leaves keep their labels; internal nodes are I1,I2,...

nwk = erase(strtrim(nwk), ';');

nodeID = 0;
stack  = [];                 % stack of internal node IDs

edgesS = strings(0,1);
edgesT = strings(0,1);

nodeNames = strings(0,1);
nodeType  = strings(0,1);

k = 1;
while k <= length(nwk)
    c = nwk(k);

    if c == '('
        nodeID = nodeID + 1;
        internalName = "I" + string(nodeID);
        stack(end+1) = nodeID;

        nodeNames(end+1,1) = internalName;
        nodeType(end+1,1)  = "internal";

        k = k + 1;

    elseif c == ')'
        childID = stack(end); 
        stack(end) = [];

        if ~isempty(stack)
            parentID = stack(end);

            edgesS(end+1,1) = "I" + string(parentID);
            edgesT(end+1,1) = "I" + string(childID);
        end

        k = k + 1;

    elseif c == ','
        k = k + 1;

    else
        % read a leaf label token until delimiter
        j = k;
        while j <= length(nwk) && ~ismember(nwk(j), [',','(',')'])
            j = j + 1;
        end
        label = string(nwk(k:j-1));

        nodeNames(end+1,1) = label;
        nodeType(end+1,1)  = "leaf";

        parentID = stack(end);
        edgesS(end+1,1) = "I" + string(parentID);
        edgesT(end+1,1) = label;

        k = j;
    end
end

% remove duplicate node entries if any (keep first occurrence)
[~, ia] = unique(nodeNames,'stable');
nodeNames = nodeNames(ia);
nodeType  = nodeType(ia);

end