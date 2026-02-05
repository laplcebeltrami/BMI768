function eeg256_graph_overlay(S, lineWidth)
% EEG256_GRAPH_OVERLAY  Overlay an undirected sensor graph S on the current scalp plot.
% Modified to use the new data structure:
%   S.vertices : [Nv x 2] coordinates
%   S.edges    : [Ne x 2] undirected edge list (indices into S.vertices)
%   S.labels   : {Nv x 1} (optional; not used here)
%
% Usage:
%   eeg256_layout_plot(chanlocs256); hold on;
%   eeg256_timeseries_overlay(chanlocs256, PatientsEC(:,:,segIdx,subjIdx), 250);
%   S = eeg256_build_graph(chanlocs256,'delaunay',[]);
%   eeg256_graph_overlay(S, 0.20);
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

if nargin < 2 || isempty(lineWidth)
    lineWidth = 0.20;
end

V = S.vertices;
E = S.edges;

hold on;

Ne = size(E,1);
for e = 1:Ne
    i = E(e,1);
    j = E(e,2);

    xi = V(i,1); yi = V(i,2);
    xj = V(j,1); yj = V(j,2);

    if ~isfinite(xi) || ~isfinite(yi) || ~isfinite(xj) || ~isfinite(yj)
        continue;
    end

    plot([xi xj], [yi yj], 'k-', 'LineWidth', lineWidth);
end

% ---- add nodes as dots ----
hold on;
plot(V(:,1), V(:,2), '.k', 'MarkerSize', 5);

end