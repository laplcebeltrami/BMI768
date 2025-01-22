function sphere = sphere_delaunay(vertices)
    % function sphere = sphere_delaunay(vertices)
    %
    % (C) 2025 Moo K. Chung
    % University of Wisconsin-Madison
    

    % Number of points
    vertices = double(vertices);

    N = size(vertices,1);
   
    %% Step 1: Estimate Sphere Parameters via Least Squares

    % Extract X, Y, Z coordinates
    X = vertices(:,1);
    Y = vertices(:,2);
    Z = vertices(:,3);

    % Assemble the A matrix and B vector for least squares
    A = [2*X, 2*Y, 2*Z, ones(N,1)];
    B = X.^2 + Y.^2 + Z.^2;

    % Solve the normal equations A * params = B using backslash operator
    params = A \ B;

    % Extract sphere center and radius
    xc = params(1);
    yc = params(2);
    zc = params(3);
    r = sqrt(params(4) + xc^2 + yc^2 + zc^2);

    % Store sphere parameters
    sphereParams = [xc, yc, zc, r];
  
    %% Step 2: Normalize Points to Lie Exactly on the Sphere

    % Subtract the center
    centeredVertices = vertices - sphereParams(1:3);

    % Compute norms
    norms = sqrt(sum(centeredVertices.^2, 2));

    % Avoid division by zero
    norms(norms == 0) = 1;

    % Normalize to unit sphere and scale by radius
    vertices_normalized = (centeredVertices ./ norms) * sphereParams(4) + sphereParams(1:3);

    %% Step 3: Perform Convex Hull to Obtain Spherical Triangulation

     faces = convhulln(vertices_normalized, {'Qt'}); % 'Qt' option for quality triangulation
 
    %% step 4: Return Results
    % The function returns the triangulated faces and the estimated sphere parameters.
    
    sphere.vertices = vertices;
    sphere.faces = faces;
    
end