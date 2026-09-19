function figure_dtigraph(adj,vertices)
% (c) Moo K. Chung 
%     mkchung@wisc.edu
% October 12, 2009

set(gcf,'Color','white','InvertHardcopy','off');
for i=1:size(vertices,1)
    hold on;
    plot3(vertices(i,1),vertices(i,2),vertices(i,3),'.r');
    %text(vertices(i,1)+0.5,vertices(i,2)+0.5,vertices(i,3)+0.5,num2str(i),'Color','k');
end;


k=1;
for i=1:size(vertices,1)
    for j=1:size(vertices,1)
        if adj(i,j)==1
            hold on;
            %pause;
            plot3(vertices([i j],1), vertices([i j],2), vertices([i j],3),'-b','LineWidth',1);
%             plot3(vertices([i j],1), vertices([i j],2), vertices([i j],3),'-bo',...
%                 'LineWidth',1,...
%                 'MarkerEdgeColor','r',...
%                 'MarkerFaceColor','r',...
%                 'MarkerSize',5)
%             axis equal
            % uncomment to get a movie
            M(k) = getframe; k=k+1;
        end;
    end;
end;








