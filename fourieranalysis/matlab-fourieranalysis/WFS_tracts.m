function [wfs beta]=WFS_tracts(tract,para,k)
% wfs =WFS_tracts(tract,para,10)
%
% tract: 3 x n_vertex coordianates of 3D curve
% para : arc-length parameterization
% k : degree
%
% (C) Moo K. Chung & Nagesh Adluru 2008
%     mkchung@wisc.edu
%     University of Wisconsin-Madison
%
% Update history: 
%  2008, Original code by Moo K. Chung 
%  2009 Jan. 21 Nagesh Adluru removed the for-loop. 
%  2025 Apr 21. Additional comments on the normlizing factor \sqrt(2)

n_vertex=length(para);
para_even=[-para(n_vertex:-1:2) para];
tract_even=[tract(:,n_vertex:-1:2) tract];

%psi1=inline('sqrt(2)*cos(pi*l.*x)');%Commented it out on January 26, 2009.
%psi2=inline('sqrt(2)*sin(pi*l.*x)');

%Y= psi*beta
% inv(psi)*Y = psi \ Y= beta
% Y=[];
% for i=0:k
%     psi=psi1(i,para_even');
%     Y=[Y psi];
% end

%January 21, 2009.
%Nagesh Adluru.
%Removing the above for-loop

Y=zeros(2*n_vertex-1,k+1);
para_even=repmat(para_even',1,k+1);
pi_factors=repmat([0:k],2*n_vertex-1,1).*pi;
Y=cos(para_even.*pi_factors).*sqrt(2);

%sqrt(2) will not make the first basis function normalized to 1. 
%It was simply multiflied for all basis for algoirthmic convienence. 

%----------------------------
beta=pinv(Y'*Y)*Y'*tract_even';
hat= Y*beta;
wfs=hat(n_vertex:(n_vertex*2-1),:);

