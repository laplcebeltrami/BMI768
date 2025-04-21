%Correlation network simulations via mixed-effects models
%
% 
% (C) 2020 Moo K. Chung 
% mkchung@wisc.edu
% University of Wisconsin-Madison
%
%
% The correlation network simulations are based on the following papers:
%
% Chung, M.K., Lee, H. Ombao. H., Solo, V. 2019 Exact topological inference 
% of the resting-state brain networks in twins, Network Neuroscience 3:674-694
%
% Chung, M.K., Lee, H., Solo, V., Davidson, R.J., Pollak, S.D. 2017  
% Topological distances between brain networks, International Workshop on 
% Connectomics in NeuroImaging, Lecture Notes in Computer Science, in press 
% http://www.stat.wisc.edu/~mchung/papers/chung.2017.CNI.pdf
%
% Chung, M.K., Vilalta, V.G., Lee, H., Rathouz, P.J., Lahey, B.B., Zald, D.H. 
% 2017 Exact topological inference for paired brain networks via persistent 
% homology. Information Processing in Medical Imaging (IPMI) 10265:299-310 
% http://pages.stat.wisc.edu/%7Emchung/papers/chung.2017.IPMI.pdf


n=5; m=5; %Number of subjects in group I and II
p=100; % The number of nodes in networks
sigma =0.1; %sigma controls amount of noise. 0.01 and 0.1 are used.

%C1 and C2 are randomly simulated connectivity matrices 

%-----------------------
%Networks with 4 and 5 modules
A = normrnd(0, 1, n,p);  %1st level model 
figure; imagesc(A)
[X C1] = RG_module(A,4,sigma); %2nd level model for group I
figure; imagesc(X) 
figure; imagesc(C1)   %correlation matrix for group I

[Y C2] = RG_module(A,5,sigma); %2nd level model for group II
figure; subplot(1,2,1); imagesc(A)
subplot(1,2,2); imagesc(Y);

figure; imagesc(C1)
figure; imagesc(C2)  %correlation matrix for group II

%---------------
%Computing correlation from data matrices

Xnorm = corr2norm(X); %center and translate data matrix
C1norm = Xnorm'*Xnorm; %correlation computaion
figure; imagesc(C1norm)

figure; imagesc(C1norm-C1); %Question: why do we have residual if they are identical?
