
function cellcomplex_display(S)
% CELLCOMPLEX_DISPLAY  Display a 2D cell complex S with fields:
%   S.nodes : [K x 2] node coordinates
%   S.edges : [E x 2] undirected edge list (node indices)
%   S.faces : struct array with field .vertices (at least) listing face vertices
%
% Minimum-change philosophy: use graph_directed_plot as-is, by converting
% undirected edges to a directed edge list (i->j with i<j), and passing [] weights.
%
% (C) 2026 Moo K. Chung style display helper

Nodes = S.nodes;
Edges = S.edges;

% draw 1-skeleton using stored directed edges 
graph_directed_plot(Nodes, Edges, [], 'k');                         

hold on;
% ---- overlay faces (if provided)
if isfield(S,'faces') && ~isempty(S.faces)
    if isstruct(S.faces) && isfield(S.faces,'vertices') && ~isempty(S.faces.vertices)

        F = size(S.faces.vertices,1);

        % face sign: +1 / -1 / 0
        if isfield(S.faces,'sign') && ~isempty(S.faces.sign)
            fs = S.faces.sign(:);
        else
            fs = zeros(F,1);
        end

        for f = 1:F
            if fs(f)==0
                continue                                              % <— FIX: shade only consistent faces
            end

            v  = S.faces.vertices(f,:);
            xy = Nodes(v,:);
            xy = [xy; xy(1,:)];                                       % close polygon

            plot(xy(:,1), xy(:,2), 'k', 'LineWidth', 2);

            if fs(f) > 0
                patch(xy(:,1), xy(:,2), 'r', 'FaceAlpha', 0.08, 'EdgeColor','none');  % <— FIX: light red for +
            else
                patch(xy(:,1), xy(:,2), 'b', 'FaceAlpha', 0.08, 'EdgeColor','none');  % <— FIX: light blue for -
            end
        end

    elseif isstruct(S.faces) && numel(S.faces) > 1
        % fallback: older style struct array (shades only if per-face sign exists and is nonzero)
        for f = 1:numel(S.faces)

            if isfield(S.faces(f),'sign') && ~isempty(S.faces(f).sign)
                fs = S.faces(f).sign;
            else
                fs = 0;
            end
            if fs==0
                continue                                              % <— FIX
            end

            if isfield(S.faces(f),'verts') && ~isempty(S.faces(f).verts)
                v = S.faces(f).verts(:);
            elseif isfield(S.faces(f),'vertices') && ~isempty(S.faces(f).vertices)
                v = S.faces(f).vertices(:);
            else
                continue
            end

            xy = Nodes(v,:);
            xy = [xy; xy(1,:)];

            plot(xy(:,1), xy(:,2), 'k', 'LineWidth', 2);

            if fs > 0
                patch(xy(:,1), xy(:,2), 'r', 'FaceAlpha', 0.08, 'EdgeColor','none');  % <— FIX
            else
                patch(xy(:,1), xy(:,2), 'b', 'FaceAlpha', 0.08, 'EdgeColor','none');  % <— FIX
            end
        end
    end
end

% if isfield(S,'faces') && ~isempty(S.faces)
%     for f = 1:numel(S.faces)
%         if isfield(S.faces(f),'verts') && ~isempty(S.faces(f).verts)
%             v = S.faces(f).verts(:);
%             xy = Nodes(v,:);
%             xy = [xy; xy(1,:)];  % close polygon
% 
%             plot(xy(:,1), xy(:,2), 'k', 'LineWidth', 2);             % face boundary
%             patch(xy(:,1), xy(:,2), 'k', 'FaceAlpha', 0.05, 'EdgeColor','none');
%         end
%     end
% end


axis equal;
hold off;

end