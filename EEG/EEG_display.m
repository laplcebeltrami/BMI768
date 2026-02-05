function EEG_display(Data, chan)
% EEG_DISPLAY  Plot one dataset: all subjects (light gray) + mean (thick red).
%
% Input
%   Data : one of the following
%          (A) ControlF struct with Data.F [256 x Nfreq x nSeg x nSub]
%          (B) Fout     struct with Data.F [256 x Nfreq x nSub]
%          (C) time     struct with Data.X [256 x T x nSub]
%          (D) numeric  array               [256 x T x nSub]
%   chan : vector of channel indices
%
% Notes
%   The x-axis is displayed over a 3-second epoch using a linear time grid.
%   Time is used only for visualization.
%
% (C) 2026 Moo K. Chung
% University of Wisonsin-Madison

dur = 3;  % seconds

% ---- Convert input to time-domain X [256 x T x nSub] ----
if isstruct(Data) && isfield(Data,'X')
    X = Data.X;

elseif isstruct(Data) && isfield(Data,'F')
    if ndims(Data.F) == 4
        Ftmp = EEG_Fourier_average_segments(Data);        % <— FIX: collapse 40 segments (3rd dim)
        Ftmp = EEG_Fourier_truncate_average(Ftmp);        % <— FIX: keep first 300 + collapse condition dim if present
    else
        Ftmp = Data;
    end
    Xtmp = EEG_Fourier_reconstruct(Ftmp, 600);            % fixed display length (even)
    X = Xtmp.X;

else
    X = Data;
end

[~, T, nSub] = size(X);
t = linspace(0, dur, T);

% ---- Plot ----
figure;
for j = 1:numel(chan)
    ch = chan(j);
    hold on;
    subplot(numel(chan), 1, j); hold on;

    for s = 1:nSub
        plot(t, squeeze(X(ch,:,s)), 'Color', [0.75 0.75 0.75]);
    end

    xmean = squeeze(mean(X(ch,:,:), 3));
    plot(t, xmean, 'r', 'LineWidth', 2);                  

    xlim([0 dur]);
    ylabel(sprintf('Ch %d', ch), 'FontSize', 14, 'FontWeight', 'bold');   

    if j == 1
        title('EEG: all subjects (light) and mean (thick red)', ...
            'FontSize', 18, 'FontWeight', 'bold');                    
    end
    if j == numel(chan)
        xlabel('Time (sec)', 'FontSize', 14, 'FontWeight', 'bold');      
    end

    set(gca, 'FontSize', 14);                                           

end

end