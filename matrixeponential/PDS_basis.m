function basis=PDS_basis(p)
% function basis=PDS_basis(p)
%
% generate the PDS basis exp(I_ij)
% 
% INPUT
% p:        number of nodes
%
% OUTPUT
% basis:    vectorization of all exp(I_ij) in a matrix of size (p*(p+1)/2) x  (p^2)
%
%
% Find the exponential map of basis in the space of symmetric matrices
% The method follows publication
%
% Huang, S.-G., Samdin, S.B., Ting, C.M., 
% Ombao, H., Chung, M.K. 2020 Statistical model for dynamically-changing 
%correlation matrices with application to brain connectivity. 
% Journal of Neuroscience Methods 331:108480 
% http://pages.stat.wisc.edu/~mchung/papers/huang.2020.NM.pdf
%
% If you are using the code, please reference the paper
%
%
% (C) 2019 Shih-Gu Huang shihgu@gmail.com
%          Moo K. Chung  mkchung@wisc.edu
%          Universtiy of Wisconsin-Madison
%
% Update history:
%     2019 Sep. 15 Huang created 
%     2021 Jan. 15 Chung restructured


psi=zeros(p,p,p*(p+1)/2); % p*(p+1)/2 exponential maps
% First p elements are diagonal matrices: exp(I_ii) for i=1:p
for i=1:p
    I=zeros(p);
    I(i,i)=1;   % In I_ii, (i,i)-th entry is 1, and the others are 0
    psi(:,:,i)=expm(I);
end

% The other p*(p+1)/2-p elements are  exp(I_ij) for 1<=j<i<=p
ind=p+1;       %ind starts from p+1 to p*(p+1)/2
for i=1:p
    for j=1:i-1
        I=zeros(p);
        I(i,j)=1/sqrt(2);           % In I_ij, (i,j)-th and (j,i)-th entries are 1/sqrt(2), and the others are 0
        I(j,i)=1/sqrt(2);
        psi(:,:,ind)=expm(I);
        ind=ind+1;
    end
end
basis=reshape(psi,p^2,[]);  % vectorized each pxp exponetial map into (p^2)x1 vector
basis=basis';

% Matrix for least square estimation  (p*(p+1)/2) x (p^2)
%psiLSE=pinv(psi2d'*psi2d)*psi2d';  
