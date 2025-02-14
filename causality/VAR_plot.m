function VAR_plot(X, col)
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison

[N, ~] = size(X);

for i = 1:N
    subplot(N, 1, i);
    hold on; plot(X(i, :), col, 'LineWidth', 1.5); hold on;
    xlabel('Time'); ylabel(['X_', num2str(i), '(t)']);
    figure_bigger(20);
    figure_bg('w')
end

