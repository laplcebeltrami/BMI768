function Y = corr2norm(X);
%
% function Y = corr2norm(X);
%
% Given m x p data matrix X, perform centering and normalization operation
% on X, where m is the number of images and p is the number of voxels or
% nodes. This linear operation will drastically save time in computing large scale 
% correlation matrices of size 25000 by 25000 or larger.
%
% The algorithm is published in the follwoing papers.
%
% Chung, M.K., Vilalta, V.G., Lee, H., Rathouz, P.J., Lahey, B.B., Zald, D.H. 
% 2017 Exact topological inference for paired brain networks via persistent 
% homology. Information Processing in Medical Imaging (IPMI) 10265:299-310
% http://www.stat.wisc.edu/~mchung/papers/chung.2017.IPMI.pdf
%
% Chung, M.K., Hanson, J.L., Ye, J., Davidson, R.J. Pollak, S.D. 2015 
% Persistent Homology in Sparse Regression and Its Application to Brain Morphometry. 
% IEEE Transactions on Medical Imaging, 34:1928-1939
% http://www.stat.wisc.edu/~mchung/papers/chung.2015.TMI.pdf
%
%
% This function is same as norm_matrix.m
%
% (C) Moo K. Chung
%  email://mkchung@wisc.edu
%  Department of Biostatisics and Medical Informatics
%  University of Wisconsin, Madison
%
%
% Update History: 
%       2015 Oct 28 created
%       2016 May 29 sparse version         
%       2017 Dec 25 documentation updated.



%missing data treatment
%meanvol(isnan(meanvol))=0;
%meanvol(meanvol~=0)=1;

[m p]=size(X);

%meanX= nanmean(X,1); %mean without NaN
%for i=1:p
%    X(isnan(X(:,i)),i)=meanX(i); %replace missing with average
%end

meanX=mean(X,1); %recompute mean
meanX=repmat(meanX,m,1);
X1=X-meanX;
diagX1 = sqrt(diag(X1'*X1));
X1=X1./repmat(diagX1', m,1);
Y=X1;




