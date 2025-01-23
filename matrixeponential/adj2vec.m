function vec = adj2vec(adj);
%
% function vec = adj2vec(adj,k);
% vectorize the square matrix and produce the vector of elemenets 
% in upper triangle including diagonal. For example, from the distance matrix, it produces the pdist.
% 
% INPUT:
% adj has to be bigger than 2 x 2 matrix
% k   row index. If k=1. It vectorize from the diagonal. 
% If k=2, it vectorize above the 2nd row exluding diagonal.
%
%example:
%  X=[1 2 3
%     2 2 2
%     3 2 1]
%  adj2vec(X)
%
%     1
%     2
%     2
%     3
%     2
%     1
%
%
%
% (C) 2019 Moo K. Chung 
% University of Wisconsin-Madison
% mkchung@wics.edu

n=size(adj,1);
vec=[];

for i=1:n
    vec= [vec adj(i,1:i)];
end;

vec=vec';