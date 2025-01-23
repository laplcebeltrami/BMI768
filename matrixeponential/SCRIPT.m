% The scripts explains computation involving the tangent space (space of symmetric
% matrices) and its exponential map (space of positive definite symmetric
% matrices, which is a curved manifold).
%
% Given symmetric matrix X, PDS_find.m find the closest PDS matrix 
% following the basis method published in 
%
% Huang, S.-G., Samdin, S.B., Ting, C.M., Ombao, H., Chung, M.K. 2020 
% Statistical model for dynamically-changing correlation matrices with 
% application to brain connectivity. Journal of Neuroscience Methods 331:108480 
% http://pages.stat.wisc.edu/~mchung/papers/huang.2020.NM.pdf
%
%
% (C) 2021 Moo K. Chung  mkchung@wisc.edu
%          Universtiy of Wisconsin-Madison
%
% Update history:
%     2021 Jan. 15 created
%     2023 July 11 commented
%

%symmetric matrix of rank 2
X=[1 2 3
   2 2 2
   3 2 1]

%Find eigenvalues
%[U,S,V] = svd(X)
%It has eigenvalues 6, 2 and 0
%S = 6.0000         0         0
%         0    2.0000         0
%         0         0    0.0000
         
%We can estimate the closest positive definite symmetric matrix to X
%by running

X_esimate = PDS_find(X)

%Find eigenvalues
%[U,S,V] = svd(X_estimate)
%The estimated matrix has eigenvalues 6.0061, 1.8495 and 0.0477
%
%S = 6.0061         0         0
%         0    1.8495         0
%         0         0    0.0477

%Error givgen in terms of Frobius norm
norm(X-X_estimate,'fro')
%0.3378


%Another example

A=normrnd(0,1,10,3) 
X=A*A'; %matrix of size 10 x 10 with only 3 positive eigenvalues
[U,S,V] = svd(X)

%We convert this to matrix of size 10 x 10 with 10 positive eigenvalues
X_estimate = PDS_find(X)
[U,S,V] = svd(X_estimate)






