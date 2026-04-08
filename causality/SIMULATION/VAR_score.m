function score = VAR_score(Ghat, Emat)
% VAR_SCORE  Compare predicted strengths to ground-truth on dominant directions only.
%
%   score = VAR_score(Ghat, Emat)
%
% Inputs:
%   Ghat : n x n predicted directed strengths (e.g., 1 - GC_matrix).
%   Emat : n x n antisymmetric ground-truth flow matrix.
%
% Output:
%   score : struct with fields
%              .rmse     = RMSE on dominant directions (Emat>0)
%              .pearson  = Pearson correlation on dominant directions
%              .spearman = Spearman rank correlation on dominant directions
%              .cosine   = Cosine similarity on dominant directions
%
% Notes:
%   Uses exactly one entry per unordered pair: (i,j) with Emat(i,j) > 0.
%   Diagonal entries are excluded.
%
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu
%
% The code is downloaded from
% https://github.com/laplcebeltrami/hodge
% If you are using the code, refernce one of Hodge papers listed in GitHub.
%
% Update history: November 7, 2025


    n = size(Emat,1);
    % mask for dominant directions (one per unordered pair), excluding diagonal
    mask = (Emat >= 0) & ~eye(n);

    gt = Emat(mask);
    pr = Ghat(mask);

    if isempty(gt)
        score = struct('rmse',NaN, 'pearson',NaN, 'spearman',NaN, 'cosine',NaN);
        return
    end

    % RMSE
    rmse = sqrt(mean((pr - gt).^2));

    % Pearson
    pg = gt - mean(gt);
    pp = pr - mean(pr);
    denomP = sqrt((pg' * pg) * (pp' * pp));
    if denomP == 0, pearson = NaN; else, pearson = (pg' * pp) / denomP; end

    % Spearman (rank correlation)
    rg = tiedrank(gt);
    rp = tiedrank(pr);
    rgc = rg - mean(rg);
    rpc = rp - mean(rp);
    denomS = sqrt((rgc' * rgc) * (rpc' * rpc));
    if denomS == 0, spearman = NaN; else, spearman = (rgc' * rpc) / denomS; end

    % Cosine similarity
    denomC = norm(gt) * norm(pr);
    if denomC == 0, cosine = NaN; else, cosine = (gt' * pr) / denomC; end

    score = struct('rmse',rmse, 'pearson',pearson, 'spearman',spearman, 'cosine',cosine);
end


% function score = VAR_score(Ghat, Emat)
% % VAR_SCORE  Compare predicted strengths to ground-truth on ALL directed entries.
% %
% %   score = VAR_score(Ghat, Emat)
% %
% % Inputs:
% %   Ghat : n x n predicted directed strengths (e.g., 1 - GC_matrix).
% %   Emat : n x n antisymmetric ground-truth flow matrix.
% %
% % Output:
% %   score : struct with fields
% %              .rmse     = RMSE on all off-diagonal entries
% %              .pearson  = Pearson correlation on all off-diagonal entries
% %              .spearman = Spearman rank correlation on all off-diagonal entries
% %              .cosine   = Cosine similarity on all off-diagonal entries
% %
% % Notes:
% %   Uses every directed entry except the diagonal; i.e., both (i,j) and (j,i) are included.
% 
%     n = size(Emat,1);
%     mask = ~eye(n);                  % all off-diagonal entries (both directions)
% 
%     gt = Emat(mask);
%     pr = Ghat(mask);
% 
%     rmse = sqrt(mean((pr - gt).^2));
% 
%     pg = gt - mean(gt);
%     pp = pr - mean(pr);
%     pearson = (pg' * pp) / (sqrt((pg' * pg) * (pp' * pp)) + eps);
% 
%     rg = tiedrank(gt);
%     rp = tiedrank(pr);
%     rgc = rg - mean(rg);
%     rpc = rp - mean(rp);
%     spearman = (rgc' * rpc) / (sqrt((rgc' * rgc) * (rpc' * rpc)) + eps);
% 
%     cosine = (gt' * pr) / (norm(gt) * norm(pr) + eps);
% 
%     score = struct('rmse',rmse, 'pearson',pearson, 'spearman',spearman, 'cosine',cosine);
% end