function [AAL, fig, ax] = AAL_display_surface
% AAL_DISPLAY_SURFACE  Display cortical surface with AAL ROI nodes and labels.
%
% This function loads AAL_template.mat and visualizes the surface together
% with ROI node locations and anatomical ROI labels. Label size and color
% are adaptively scaled by depth to improve readability in 3D view.
%
% Required file (must be on MATLAB path):
%   AAL_template.mat : struct AAL with fields
%     AAL.template   : surface template (as used by figure_patch)
%     AAL.vertices   : [116 x 3] ROI coordinates
%     AAL.labels     : {1 x 116} ROI names
%
% (C) 2026 Moo K. Chung
% University of Wisconsin–Madison

load AAL_template;
% AAL = 
%   struct with fields:
%     template: [1×1 struct]
%     vertices: [116×3 double]
%       labels: {1×116 cell}



t        = AAL.template;                
X        = AAL.vertices;                
roiNames = AAL.labels;                   

AAL.vertices(:,2) = - AAL.vertices(:,2); % Flip Y here. 
% This is stupid matlab inconsistency


minZ = min(X(:,3));
maxZ = max(X(:,3));
ROIfont = 8;
hold on;
figure_patch(t,[0.9 0.9 0.9],0.15);
plot3(X(:,1), X(:,2), X(:,3), 'r.', 'MarkerSize', 12);   % nodes

for i = 1:length(roiNames)
    pos = X(i,:);
    
    zscale = (pos(3) - minZ) / (maxZ - minZ);
    zscale = max(0.5, zscale);
    
    text(pos(1), pos(2)+3, pos(3)+2, roiNames{i}, ...
        'Color', [0 0 0] + (1 - zscale)*0.5, ...
        'FontSize', ROIfont * zscale, ...
        'HorizontalAlignment', 'center');
end

view([-90 90])
%lighting gouraud
%material shiny
camlight;
alpha(0.1);
end


%-----
% Helper function

function figure_patch(surf,color,c);
%
% figure_patch(surf,color,c);
%
% surf : surf mesh
% color: surface color
% c    : amount of transparency
%
% (c) 2010 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu
%
% update history: 2010 April 1; 2013 Dec.26; 
%                 2026 Feb.10removed white background


%surf= reducepatch(surf,0.2); % it reduces the patch size
hold on;

if nargin <=1
    color = [0.74 0.71 0.61];
    c=1;
end

% patch command only works with .vertices and .faces
patchsurf.vertices =surf.vertices;
patchsurf.faces=surf.faces;

p=patch(patchsurf);
set(p,'FaceColor',color,'EdgeColor','none');


daspect([1 1 1]);
view(3); 
axis tight; axis vis3d off;
 

lighting gouraud;
material shiny;

axis off
%set(gcf,'Color','w') ;

%colorbar
%background='white'; whitebg(gcf,background);
%set(gcf,'Color',background,'InvertHardcopy','off');

end



