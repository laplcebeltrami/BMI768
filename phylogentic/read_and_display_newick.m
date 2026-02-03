function trees = read_multitrees_newick(newickFile)
% READ_MULTITREES_NEWICK  Read a multi-tree Newick/Extended-Newick file and display each tree.
%
% Input
%   newickFile : filename or full path, e.g.
%               'multitrees.newick'
%
% Output
%   trees : struct array with fields
%           .raw    : raw tree string (as in file, with ';')
%           .plain  : sanitized plain Newick (tree backbone)
%           .G      : digraph object for the backbone
%
% Notes
%   - Does NOT require Bioinformatics Toolbox.
%   - Displays the backbone as a layered directed graph.
%   - Hybrid/network annotations are stripped so you can still visualize the tree part.
%
% (C) 2026 Moo K. Chung
% University of Wisconsin-Madison

txt = fileread(newickFile);                             % <— reads the file content
txt = regexprep(txt, '\r\n|\r', '\n');                  % <— normalize newlines

treeStrs = regexp(txt, '[^;]+;', 'match');              % <— split into trees by ';'
m = numel(treeStrs);

trees = repmat(struct('raw','','plain','','G',[]), 1, m);

% Create ONE figure and layout
figure('Color','w');
tiledlayout('flow','TileSpacing','compact','Padding','compact');
% or: tiledlayout(ceil(sqrt(m)), ceil(sqrt(m))) for a fixed grid

for i = 1:m
    raw = strtrim(treeStrs{i});

    % ---- sanitize Extended Newick -> plain Newick
    nwk = raw;
    nwk = regexprep(nwk, '\s+', '');
    nwk = regexprep(nwk, '\[[^\]]*\]', '');
    nwk = regexprep(nwk, '#H\d+', '');
    nwk = regexprep(nwk, '::[^,)\s;]+', '');
    nwk = regexprep(nwk, '\{[^}]*\}', '');
    nwk = regexprep(nwk, ':[^,)\s;]+', '');
    nwk = regexprep(nwk, ',,', ',');
    nwk = regexprep(nwk, '\(,', '(');
    nwk = regexprep(nwk, ',\)', ')');

    % ---- build graph
    G = local_newick_backbone_to_digraph(nwk);

    trees(i).raw   = raw;
    trees(i).plain = nwk;
    trees(i).G     = G;

    % ---- plot in next tile
    nexttile;
    plot(G,'Layout','layered','NodeLabel',G.Nodes.Name);
    title(sprintf('Tree %d', i),'Interpreter','none','FontSize',9);
end


end

function G = local_newick_backbone_to_digraph(nwk)
% LOCAL_NEWICK_BACKBONE_TO_DIGRAPH  Parse plain Newick string to a digraph (topology only).
% Assumes: labels contain no commas/parentheses/semicolons.

nwk = strtrim(nwk);
if nwk(end) ~= ';'
    nwk = [nwk ';'];                                    % <— ensure terminator
end
nwk = erase(nwk, ';');                                  % <— parse without terminator

nodeID = 0;
stack  = [];                                            % stack of internal node IDs
edgesS = {};
edgesT = {};
names  = {};

k = 1;
while k <= length(nwk)
    c = nwk(k);

    if c == '('
        nodeID = nodeID + 1;
        names{nodeID,1} = sprintf('I%d', nodeID);        % internal node label
        stack(end+1) = nodeID;
        k = k + 1;

    elseif c == ')'
        % close the current internal node; connect it to its parent if parent exists
        child = stack(end); stack(end) = [];
        if ~isempty(stack)
            parent = stack(end);
            edgesS{end+1,1} = names{parent};
            edgesT{end+1,1} = names{child};
        end
        k = k + 1;

    elseif c == ','
        k = k + 1;

    else
        % read a leaf label token until delimiter
        j = k;
        while j <= length(nwk) && ~ismember(nwk(j), [',', '(', ')'])
            j = j + 1;
        end
        label = nwk(k:j-1);

        nodeID = nodeID + 1;
        names{nodeID,1} = label;

        parent = stack(end);
        edgesS{end+1,1} = names{parent};
        edgesT{end+1,1} = label;

        k = j;                                          % <— advance to delimiter
    end
end

G = digraph(edgesS, edgesT);
end