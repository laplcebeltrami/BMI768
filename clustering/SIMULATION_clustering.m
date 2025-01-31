%% SIMULATION: comparsions of various clustering methods
%
% The simultation study is published in
%
% Moo K. Chung, Camille Garcia Ramos, Felipe Branco De Paiva, Jedidiah 
% Mathis, Vivek Prabharakaren, Veena A. Nair, Elizabeth Meyerand, 
% Bruce P. Hermann, Jeffery R. Binder, Aaron F. Struck, 2023 
% Unified Topological Inference for Brain Networks in Temporal 
% Lobe Epilepsy Using the Wasserstein Distance, 
% NeuroImage 15:120436, https://arxiv.org/pdf/2302.06673
%
% This is modifeid from the original codes from
% https://github.com/laplcebeltrami/dynamicTDA
%
% (C) 2021- Moo K. Chung
% Univeristy of Wisconsin-Madison
%
% Update history
% 2021 December 22 created
% 2022 Otober 24 updated
% 2023 March 26 WS_cluster.m added
% 2025 january 30 Reedited and repackaged for BMI768 class

sigma=0.1 %amount of noise
npoints=200 %# of random scatter points along circles

%% SIMULATION 1 DETECTING FALSE POSITIVES
% Random network simulation of no topolgoical difference
coord=simulate_circle_equal(sigma, npoints); 


%% SIMULATION 2 DETECTING FALSE NEGATIVES
% Random network simulation of topolgoical difference

coord=simulate_circle_difference(sigma, npoints); 

%convert scatter points into distance matrices
g= coord2dist(coord);

%nN: number of networks
%NC: number of clusters/groups

[nN nC] = size(coord);
%Visualizing networks
figure;
for j=1:nC
    subplot(2,2,j)
    for i=1:nN
        obs=coord{i,j};
        hold on; plot(obs(:,1), obs(:,2),'.k');
        axis square
        figure_bigger(16)
        xlim([-3 3]); ylim([-3 3]);
        title(['Group ' int2str(j)])
    end
end


%% CLUSTERING
% Each distance is defined and explained in detail in 
% the above reference (Chung et al. 2023).

% Initilize the clustering accuray. 
acc_K =[];  % k-means - Euclidean distance
acc_B0=[];  % bottleneck-0 distance
acc_B1=[];  % bottleneck-1 distance
acc_H = []; % Hierarchical clustering - Gromov-Hausdorff distance
acc_WS =[]; % Wasserstein distance - topoloigcal distance

for i=1:10
    i
    %generate random scatter points
    %Equal topology
    coord=simulate_circle_equal(sigma, npoints);
    %Unequal topology
    %coord=simulate_circle_difference(sigma, npoints); 

    %convert scatter points into distance matrices
    g= coord2dist(coord);

    %perform clustering
    %k-means 
    acc = kmeans_cluster(g);
    acc_K = [acc_K acc.mean];
    
    %bottleneck distance
    acc = WS_bottleneck_cluster(g);
    acc_B0 = [acc_B0 acc.zero];
    acc_B1 = [acc_B1 acc.one];

    %Hierarchical clustering
    acc = GH_cluster(g);
    acc_H = [acc_H acc];

    %Wasserstein distance
    acc  = WS_cluster(g);
    acc_WS=[acc_WS acc.mean];

end

% Performance metrics
[mean(acc_K) std(acc_K)]
[mean(acc_B0) std(acc_B0)]
[mean(acc_B1) std(acc_B1)]
[mean(acc_H) std(acc_H)]
[mean(acc_WS) std(acc_WS)]

% ----------------------
% Pairwise distance matrix 
% The Wasserstein distance is not showing clustering pattern 
% since they are all topologically equivalent while L2-norm
% is showing clustering pattern. Thus k-means clustering that 
% uses the L2-norm is expected not to perform well and reports 
% a lot of false positives. 

figure; 
subplot(2,1,1)
lossMtx = WS_L2distace2matrix(g)
imagesc(lossMtx); colorbar
axis square
figure_bigger(16)
colormap('hot'); caxis([0 100])
title('L2-norm')

subplot(2,1,2)
lossMtx = WS_distace2matrix(g)
imagesc(lossMtx); colorbar
axis square
figure_bigger(16)
colormap('hot'); caxis([0 100])
title('Wasserstein')

figure_bg('w')
%print_pdf('circle-equal')

