function G = scurve2tree3D(scurve, mesh)
    % SCURVE2TREE3D Creates a graph from a set of curves with weighted edges in 3D.
    % Inputs:
    %   scurve - A cell array where each cell contains a list of node indices
    %            representing a curve.
    %   mesh   - A structure containing vertex coordinates in 'vertices' field.
    % Outputs:
    %   G      - A graph where nodes represent unique points in the curves and
    %            edges represent connections between these points with weights 
    %            based on the Euclidean distances between the points.

    % (C) 2025 Moo K. Chung
    % University of Wisconsin-Madison

    % Initialize arrays for edges and their corresponding weights
    edges = [];
    weights = [];

    % Extract unique vertices from all curves
    vertex_set = unique(vertcat(scurve{:}));

    % Map the unique vertices to consecutive integers
    map = containers.Map(vertex_set, 1:length(vertex_set));

    % Initialize a matrix to store the coordinates of the unique vertices
    coordinates = zeros(length(vertex_set), size(mesh.vertices, 2));  % 3D coordinates

    % Iterate through each curve in the cell array
    for i = 1:length(scurve)
        tree = scurve{i};

        % Map the nodes in the current curve to their new consecutive indices
        mappedTree = arrayfun(@(x) map(x), tree);

        % Create edges and calculate weights for consecutive nodes in the curve
        for j = 1:length(mappedTree) - 1
            edges = [edges; mappedTree(j) mappedTree(j+1)];

            % Calculate the Euclidean distance between the vertices as edge weight
            point1 = mesh.vertices(tree(j), :);
            point2 = mesh.vertices(tree(j+1), :);
            distance = norm(point1 - point2);
            weights = [weights; distance];

            % Store the coordinates of the points
            coordinates(mappedTree(j), :) = point1;  % 3D coordinates
            coordinates(mappedTree(j+1), :) = point2;  % 3D coordinates
        end
    end

    % Remove any duplicate edges and their corresponding weights
    [edges, ia, ~] = unique(edges, 'rows', 'stable');
    weights = weights(ia);

    % Create the graph with edges and weights
    G = graph(edges(:,1), edges(:,2), weights);

    % Set the Nodes table to contain the original node indices and coordinates
    G.Nodes = table(vertex_set, coordinates, 'VariableNames', {'Vertex', 'Coordinates'});
end
