function [wfs beta]=WFS_tracts(tract,para,k)
% wfs =WFS_tracts(tract,para,10)
%
% Cosine Series Representation
%
% tract: 3 x n_vertex
% para : arc-length parameterization
% k : degree
%
%
% (C) Moo K. Chung & Nagesh Adluru 2009
%     mkchung@wisc.edu
%     University of Wisconsin-Madison
%
% Update history: December 7, 2009

n_vertex=length(para);
para_even=[-para(n_vertex:-1:2) para];
tract_even=[tract(:,n_vertex:-1:2) tract];

%psi1=inline('sqrt(2)*cos(pi*l.*x)');
%Commented it out on January 26, 2009.
%psi2=inline('sqrt(2)*sin(pi*l.*x)');
%Y= psi*beta
% inv(psi)*Y = psi \ Y= beta
% Y=[];
% for i=0:k
%     psi=psi1(i,para_even');
%     Y=[Y psi];
% end
%Removing the above for-loop.

Y=zeros(2*n_vertex-1,k+1);
para_even=repmat(para_even',1,k+1);
pi_factors=repmat([0:k],2*n_vertex-1,1).*pi;

Y=cos(para_even.*pi_factors).*sqrt(2); %design matrix
beta=pinv(Y'*Y)*Y'*tract_even'; %least squares estimation

hat= Y*beta;   %model fit

wfs=hat(n_vertex:(n_vertex*2-1),:)';

