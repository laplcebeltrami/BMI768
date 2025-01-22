%Solving linear equations
%
% Moo K. Chung
% mkchung@wisc.edu

m=3; n=2;
A = zeros(m,n)

A(1,1)=1
A(1,3)=1

%AX=b
%Determined system

A=  [1 0 1
    -1 1 1
    1 -1 1]

b=[4 4 2]'

X=A\b


%Over-determined system

A=[1 0 0
    -1 1 0
    1 -1 0]

b=[4 4 2]'

X=A\b


X=pinv(A)*b

pinv(A'*A)*A'*b


A=[6 -4
    -4 4]
b=[4 4]'

X=A\b

%under-determined system
A=[2 -2
    -2 2]
b=[-8 8]'

X=pinv(A)*b

A=[-1 1
    0 0]
b=[4 0]'

X=pinv(A)*b


A=[-1 1
   -1 1]
b=[4 4]'

X=pinv(A)*b


A=[-1 1
    1 -1]
b=[4 -4]'

X=pinv(A)*b




