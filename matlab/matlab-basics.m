%INTRODUCTION TO MATLAB
%Moo K. Chung
%mkchung@wisc.edu


%ITERATION
%sum between 1 and 100

total=0
for i=1:100
    total = total +i
end

%101 x 50 = 5050

x=1:100
sum(x)

total=0
for i=100:-1:1
    total = total +i
end


total=0
for i=100:2:1
    total = total +i
end

%----------------------
%CONDITIONAL STATEMENTS

x=-50:50
y=cos(x)./(x.^2+1)
figure; plot(x,y)


n=length(x)

%initial value
ind=1;
temp=y(ind)

%find maximum
for i=2:n
   if y(i)>temp
       ind=i;
       temp=y(i);
   end
end
   

%--------------------------
% FUNCTIONS

[xmax, mymax] = max2(x,y)



%---------------------
% RANDOM NUMBERS

help unidrnd

n=10
x=unidrnd(n, [1 10])

n=10000
x=unidrnd(n, [1 10])
x=x/n


help unifrnd

x=unifrnd(0,1, [1 10])

n=100000;
x=unifrnd(0,1, [1 n]);
figure; hist(x,100)


n=100000;
x=unifrnd(-1,1, [1 n]);
figure; hist(x,100)

y=atanh(x);
figure; hist(y,100)



%-------------------------
% DATA VISUZLIATION

%scatter points
x=unifrnd(-1,1,[1, 100])
y=unifrnd(-1,1,[1,100])
figure; plot(x,y,'+k')
hold on; plot(x,y, 'r')


% 2D explict curves

y=sqrt(1-x.^2)
figure; plot(x,y,'+k')
hold on; plot(x,-y,'+k')


x=sort(x);
y=x.^2;
figure; plot(x,y,'+k')
hold on; plot(x,y,'r')

% circle

x=-1:0.05:1
y=sqrt(1-x.^2);
figure; plot(x,y,'+k')
hold on; plot(x,-y,'+k')



%implicit curve

theta=0:0.05:2*pi
x=cos(theta)
y=sin(theta)
figure; plot(x,y,'+k')


%-------------------------
% COMPUTATION OF PI
figure; axis square;

n=100
x=unifrnd(0,1,[1, n]);
y=unifrnd(0,1,[1, n]);
r=sqrt(x.^2 + y.^2);
hold on; plot(x,y,'+k')

p=0
for i=1:n
    if r(i)<=1
        p=p+1;
        hold on; plot(x(i),y(i),'or')
    end
end

ourPi = 4*p/n

%more efficient codes

p=length(find(r<=1))
OurPi = 4*p/n



% rate of convergence

OurPi=[];
for n=1:10000
    n
    x=unifrnd(0,1,[1, n]);
    y=unifrnd(0,1,[1, n]);
    r=sqrt(x.^2 + y.^2);
    p=length(find(r<=1));
    OurPi = [OurPi 4*p/n];
end

figure; plot(OurPi)

%This is not efficient code.


%--------------------------
% MATRIX

m=3; n=2;
A = zeros(m,n)

A(1,1)=1
A(1,3)=1

%AX=b
%Determined system

A=[1 0 1
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

%visualizing krnonecker product
B=unifrnd(0,1,[5 5])

figure
imagesc(B)
colorbar 
colormap('hot')

A=ones(5,5);
C=kron(A,B);

figure
imagesc(C)
colorbar 
colormap('hot')






