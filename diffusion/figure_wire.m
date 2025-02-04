function figure_wire(surf, Ecolor, Fcolor);
%
%figure_wire(surf, Ecolor, Fcolor);
%
% The function colors mesh faces and edges 
%
% surf  : surface mesh
% Ecolor: edge color 
% Fcolor: face color
%
% For instance, we can have Ecolor=[0.8 0.8 0.8]
%
% (C) 2008 Moo K. Chung 
%  University of Wisconsin, Madison
%
%  Email: mkchung@wisc.edu
%
% 
% 2008 created
% 2013 Sept. 5 nargin added
% 2019 May 1 updated

%surf= reducepatch(surf,0.2); 

if nargin <3
    Fcolor='w';
    Ecolor='k';
end

background='white';
whitebg(gcf,background);

newsurf.vertices=surf.vertices;
newsurf.faces=surf.faces;

p=patch(newsurf);
set(p,'FaceColor',Fcolor,'EdgeColor',Ecolor);

%daspect([1 1 1]);
%view(view_angle);  
%axis tight
%camlight; 


%set(gcf,'Color',background,'InvertHardcopy','off');

%lighting gouraud
%material shiny; 
%shading interp;

%alpha(0.1);