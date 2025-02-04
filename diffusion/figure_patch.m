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
%
% update history: April 1, 2010; Dec.26, 2013


%surf= reducepatch(surf,0.2); % it reduces the patch size

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
camlight

alpha(c);

axis off
set(gcf,'Color','w') ;

%colorbar
background='white'; whitebg(gcf,background);
set(gcf,'Color',background,'InvertHardcopy','off');





