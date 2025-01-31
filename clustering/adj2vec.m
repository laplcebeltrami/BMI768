function vec = adj2vec(adj);
%
% function vec = adj2vec(adj);
% vectorize the square matrix and produce the vector of elemenets 
% in upper triangle. For example, from the distance matrix, it produces the pdist.
% 
% INPUT:
% adj has to be bigger than 2 x 2 matrix
%
%
% (C) 2019 Moo K. Chung 
% University of Wisconsin-Madison
% mkchung@wics.edu
%


n=size(adj,1);
vec=adj(1,2:end);
 
if n>=2
    for i=2:n
        vec= [vec adj(i,i+1:end)];
    end;
    
end
