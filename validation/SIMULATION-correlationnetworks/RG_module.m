function [X rho] = RG_module(A,k, sigma)
%function [X rho] = RG_module(A,k, sigma)
%
%Given A with parmater k, sigma, the function adds a modular structure to 
%the correlation matrix corr(A)
%
%
%A     : Given data matrix of size n x p, where n is the number of subjects 
%        (or networks) and p is the number of nodes. 
%k     : Number of modules
%n     : Number of subjects
%p     : Number of nodes
%sigma : variabily in module
%X     : Matrix A is transformed to X incoporating the modular structure
%rho   : corr(X) having the modular structure
%
%Read the following paper for the explanation of the model.
%
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
%
%
%
%(C) Moo K. Chung   mkchung@wisc.edu
%    Universtiy of Wisconsin-Madison   
% 
% 2017 August 3 Tested in iMAC (macOS 10.12.5) with MATLAB R2016a
% 2020 April 14 Manual updated

[n p] =size(A);
c = round(p/k); % c = number of nodes in a module. p/k has to be interger.

for l=0:(k-1) %for l-th module
    
    for i=(1+l*c):(l+1)*c 
        X(:,i) =A(:,1+l*c) + normrnd(0,sigma,n,1);  
    end
    
end
    
rho = corr(X);