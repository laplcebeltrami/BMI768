function sulcalcurve_displaynodes(mesh, scurve, c,width)  
% function sulcalcurve_displaynodes(mesh, scurve, c)
% 
% Displays node of scurve on mesh with color c. 
%
% INPUT
%
% mesh   : surface mesh in MATLAB format
% scurve : Collection of curves with coordinates. scurve{i} is the i-th
%          curve data
% c      : color of curve
%
%
% (C) 2020 Moo K. Chung, Ilwoo Lyu 
%
% mkchung@wisc.edu
% Department of Biostatistics and Medical Informatics
% University of Wisconsin-Madison
%
% Update history: 2020 August updated 


nCurve = size(scurve,1);


for i = 1: nCurve
    index = scurve{i};
    curv = mesh.vertices(index, :);
    
    hold on; plot3(curv(:, 1), curv(:, 2), curv(:, 3),  c, 'LineWidth', width);
end


% set the final visualization options
%shading interp;
axis vis3d;
axis off;