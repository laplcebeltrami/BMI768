function Mtx = WS_L2distance2matrix(g)
%function Mtx = WS_L2distance2matrix(g)
%
% Compute loss matrix whose entries are pair-wise losses/distances. The
% method is explained in Simulation study 2:
%
% Generate random modular network introduced in Songdechakraiwut, T. Chung, 
% M.K. 2020 Topological learning for brain networks, arXiv: 2012.00675.
%
%
% INPUT
% name    : algorithm name 'top' will use the topological loss in the paper
% g1,g2   : two groups of networks
% param   : parameters for baseline algorithms. Not used now
%
% OUTPUT
% lossMtx : loss matrix 
%
% Update history
%     2021 June 25, Moo Chung
%     modified from Tan's code

d = length(g);
Mtx = zeros(d);

for i = 1:d
    adj1 = g{i};
    for j = i + 1:d
        adj2 = g{j};
        L2 = sqrt(sum(sum((adj1-adj2).^2))/2);
        Mtx(i, j) = L2;
        Mtx(j, i) = L2;
    end
end
    

