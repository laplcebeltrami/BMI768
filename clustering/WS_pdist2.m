function lossMtx = WS_pdist2(con_i,con_j)
%lossMtx = WS_pdist2(X,Y)
%    
% Compute matrix whose entries are pairwise Wasserstein distance. 
% The method is explained in Simulation study 2 in 
%
% [1] Generate random modular network introduced in Songdechakraiwut, T. Chung, 
% M.K. 2022 Topological learning for brain networks, Annals of Applied Statistics arXiv: 2012.00675.
% 
% [2] Songdechakraiwut, T., Shen, L., Chung, M.K. 2021 Topological learning and 
% its application to multimodal brain network integration, Medical Image 
% Computing and Computer Assisted Intervention (MICCAI), LNCS 12902:166-176 
%
% INPUT
% con_i,con_j  : two groups of networks. The size of X matrix should be p x p x n_Group_i 
%                                  The size of Y matrix should be p x p x n_Group_j 
% OUTPUT
% lossMtx : loss matrix 
%
%
% (C) 2022 Moo K. Chung
%     University of Wisconsin-Madison
% mkchung@wisc.edu 
%
%  Update history
%     2022 November 5, Chung, The code replaces WS_distancemat.m that is extremly slow due to double-loop.


nGroup_i = size(con_i,3);
nGroup_j = size(con_j,3);

for i=1:nGroup_i
    [Wb Wd] = WS_decompose(con_i(:,:,i));
    Wb_i(i,:) =Wb(:,3);
    Wd_i(i,:) =Wd(:,3);
end

for j=1:nGroup_j
    [Wb Wd] = WS_decompose(con_j(:,:,j));
    Wb_j(j,:) =Wb(:,3);
    Wd_j(j,:) =Wd(:,3);
end

X=[Wb_i Wd_i];  %figure; imagesc(X)
Y=[Wb_j Wd_j];  %figure; imagesc(Y)

D11 = pdist2(X,X,'euclidean'); 
D12 = pdist2(X,Y,'euclidean'); 
D21 = D12';   
D22 = pdist2(Y,Y,'euclidean'); 

D=[D11 D12;  
   D21 D22]; 

lossMtx=D;
