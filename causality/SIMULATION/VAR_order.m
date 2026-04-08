function [bestP, mseVals] = VAR_order(X, Pmax)
% X: N x T data
% Pmax: maximum lag order to test

fracTrain = 0.7;
[N,T] = size(X);
Ttrain = floor(fracTrain * T);
Tval   = T - Ttrain;

Xtrain = X(:,1:Ttrain);
Xval   = X(:,Ttrain+1:end);

Pmax_eff = min(Pmax, Ttrain-1);          % ensure valid design and seed
mseVals  = nan(Pmax,1);

for P = 1:Pmax_eff
    % Train design: Y = A * Z with blocks stacked by lag (lag-1 first)
    Y = Xtrain(:, P+1:Ttrain);           % N x (Ttrain-P)
    Z = zeros(N*P, Ttrain-P);            % (N*P) x (Ttrain-P)
    for lag = 1:P
        Z((lag-1)*N+1:lag*N, :) = Xtrain(:, P+1-lag:Ttrain-lag);
    end
    A = Y / Z;                           % N x (N*P)

    % Recursive validation forecast
    Xhat   = zeros(N, Tval);
    Xstate = Xtrain(:, Ttrain-P+1:Ttrain);  % N x P
    for t = 1:Tval
        z = zeros(N*P,1);
        for lag = 1:P
            z((lag-1)*N+1:lag*N) = Xstate(:, end-lag+1);
        end
        xpred = A * z;
        Xhat(:,t) = xpred;
        Xstate = [Xstate, xpred];        % grow with prediction
    end

    mseVals(P) = mean((Xval(:) - Xhat(:)).^2);
end

% Choose best P among valid orders
[~, idx] = min(mseVals(1:Pmax_eff));
bestP = idx;
end