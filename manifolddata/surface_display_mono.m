function surface_display_mono(surface_mesh, edge_color)
    % SURFACE_DISPLAY_MONO: Display a surface mesh 
    %
    % Syntax:
    %   surface_display_mono(surface_mesh)
    %   surface_display_mono(surface_mesh, show_edges)
    %
    % Inputs:
    %   surface_mesh - A struct containing:
    %       - vertices: Nx3 matrix of vertex coordinates.
    %       - faces: Mx3 matrix of face vertex indices.
    %   show_edges   - (Optional) Boolean flag to display edges.
    %                  true  - Display edges.
    %                  false - Do not display edges.
    %                  Default: false
    %
    % Example:
    %   % Load or define your surface mesh
    %   mesh.vertices = [...]; % Nx3 matrix
    %   mesh.faces = [...];    % Mx3 matrix
    %
    %   % Display mesh without edges
    %   surface_display_mono(mesh)
    %
    %   % Display mesh with edges
    %   surface_display_mono(mesh, true)
    %
    %  (C) 2025 Moo K. Chung
    %  University of Wisconsin-Madison
    
    % Check number of input arguments
    if nargin < 2
       edge_color='none';
    end

    % Extract vertices and faces from the surface mesh struct
    vertices = surface_mesh.vertices;
    faces = surface_mesh.faces;

    % Determine edge color based on show_edges flag
  

    % Create the surface plot
    figure;

    fc=[0.7 0.7 0.7]; %face color
    trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
        'FaceColor', fc, 'EdgeColor', edge_color);
    % [0.5, 1.0, 0.5] green
    %	[0.3, 0.8, 0.3] for a darker green.
	%[0.7, 0.9, 0.7] for a more pastel green.


    % Adjust plot appearance
    axis equal; % Equal scaling for all axes
    axis on;    % Display axis lines and labels
    grid on;    % Show grid lines

    % Enhance lighting and material properties
    camlight('headlight'); % Add a light following the camera
    %camlight
    lighting phong;        % Phong lighting for smooth shading



    set(gcf, 'Color', 'w'); % Fallback to standard MATLAB command


    if exist('figure_bigger', 'file') == 2
        figure_bigger(24); % Custom function to resize figure
    else
        set(gcf, 'Position', get(0, 'DefaultFigurePosition') .* [1 1 1.5 1.5]); % Fallback
    end

    axis off;
  

end