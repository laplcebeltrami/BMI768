function VAR_plot(X, col)
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison

[N, ~] = size(X);

for i = 1:N
    subplot(N, 1, i);
    hold on; plot(X(i, :), col, 'LineWidth', 1.5); hold on;
    xlabel('Time'); ylabel(['X_', num2str(i), '(t)']);
    figure_bigger(14);
   
end



function figure_bigger(c)
%
% function figure_bigger(c)
% 
% The function makes the fonts used in the figure bigger
%
% (C) 2013-. Moo K. Chung
% Department of Biostatistics and Medical Informatics
% University of Wisconsin-Madison
%
% mkchung@wisc.edu
% Update: November 27, 2013

set(gca, 'Fontsize',c);
%title(gcf, 'FontSize', c)
set(gcf,'Color','w','InvertHardcopy','off');

