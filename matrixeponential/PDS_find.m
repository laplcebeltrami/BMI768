function X_estimate=PDS_find(X)
% function X_estimate=PDS_find(X)
%
% Given symmetric matrix X, it find the closest PDS matrix following the
% basis method published in Huang, S.-G., Samdin, S.B., Ting, C.M., 
% Ombao, H., Chung, M.K. 2020 Statistical model for dynamically-changing 
%correlation matrices with application to brain connectivity. 
% Journal of Neuroscience Methods 331:108480 
% http://pages.stat.wisc.edu/~mchung/papers/huang.2020.NM.pdf
%
% 
% INPUT
% X:       symmetric matrix possibly non PDS.
%
% OUTPUT
% X_estimate: PDS matrix closest to X
%
%
% If you are using the code, please reference the paper
%
% (C) 2021 Moo K. Chung  mkchung@wisc.edu
%          Universtiy of Wisconsin-Madison
%
% Update history:
%     2021 Jan. 15 Chung restructured


k=size(X,1);


%Find basis in the space of symmetric matrices
basis=PDS_basis(k);

%vectorization of the upper elements of X including diagonals
vec = adj2vec(X);

%Solve nonnegative linear least-squares problem
c = lsqnonneg(basis,vec);

%Estimate in the space of positive definite symmetric matrices
%This is given as a vector
vec_estimate = basis*c;

%convert to matrix
X_estimate = vec2adj(vec_estimate,k);


