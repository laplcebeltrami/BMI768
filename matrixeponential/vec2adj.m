function adj = vec2adj(vec,k);
%
% function adj = vec2adj(vec,k);
% Makes square matrix of size k x k out of vectorized uppper triangle entires

% INPUT:
% vec = vectorized upper triangle entires including diagonals
%
% OUTPUT
% adj = square matrix of size k x k
%
%
% (C) 2021 Moo K. Chung 
% University of Wisconsin-Madison
% mkchung@wics.edu

adj=zeros(k,k);

for i=1:k
    len = (i-1)*i/2; %length of all the entries in the previous iteration
    adj(i,1:i) = vec(len+1:len+i);
    adj(1:i,i) = vec(len+1:len+i);
end;




