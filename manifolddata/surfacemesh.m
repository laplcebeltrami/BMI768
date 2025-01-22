% Statistical Models on Manifolds
% Advanced case study from MRI
% Data was published in 


surface_display_mono(whiteL)
hold on; scurve_display(whiteL, gcurve,'r', 1.5) %display gyral graph edges
hold on; scurve_displaynodes(whiteL, gcurve,'r',3) %display graph nodes
hold on; scurve_display(whiteL, scurve, 'b', 1.5) %display sulcal graphs
hold on; scurve_displaynodes(whiteL, scurve,'b',3) %display graph nodes
% Define the target reduction ratio (e.g., 50% reduction)


surface_display_mono(whiteL)
hold on; scurve_display(whiteL, gcurve,'r', 1.5) %display gyral graph edges
hold on; scurve_displaynodes(whiteL, gcurve,'r',3) %display graph nodes
hold on; scurve_display(whiteL, scurve, 'b', 1.5) %display sulcal graphs
hold on; scurve_displaynodes(whiteL, scurve,'b',3) %display graph nodes
% Define the target reduction ratio (e.g., 50% reduction)
targetReduction = 0.5;


%Determine the equation of circle using linear equations. 



vertices = sphereL.vertices;
vertices= vertices/100;
sphereL.vertices = vertices;
figure; plot3(vertices(:,1), vertices(:,2), vertices(:,3),'.y')
hold on; scurve_display(sphereL, gcurve,'r', 1.5) %display gyral graph edges
hold on; scurve_displaynodes(sphereL, gcurve,'r',3) %display graph nodes
hold on; scurve_display(sphereL, scurve, 'b', 1.5) %display sulcal graphs
hold on; scurve_displaynodes(sphereL, scurve,'b',3) %display graph nodes


sphere = sphere_delaunay(vertices);
surface_display_mono(sphere, 'w') 
