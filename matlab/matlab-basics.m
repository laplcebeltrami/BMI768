% MATLAB PROGRAMMING - BASICS 
% Advanced Topics will be covered later. 
% Moo K. Chung
% mkchung@wisc.edu


%% Symbolic computation examples (MATLAB Symbolic Math Toolbox)
clear; clc;

% Simplification/derivation
syms x y
f = (x^2 - 1)/(x - 1);
fs = simplify(f);                 % should simplify to x+1 except at x=1

g = sin(x)^2 + cos(x)^2;
simplify(g)

% Differentiation, gradient
dF_du = diff(f,x)
gradF = gradient(f,[x y]);        % 2x1 symbolic gradient

% Taylor expansion
syms t
h = exp(t)*cos(t);
T5 = taylor(h,t,'ExpansionPoint',0,'Order',6)  % up to t^5

% Solve algebraic equations (exact and numeric)
syms z
eq = z^3 - 2*z - 5 == 0;
sol_exact = solve(eq,z)         % exact roots (symbolic)
vpa(sol_exact,5)           % <-- 5 digit solution

% System of equations
syms p q
eqs = [p^2 + q^2 == 1, p - q == 1/2];
sol_sys = solve(eqs,[p q],'Real',true)


% Integration 
I1 = int(exp(-x^2),x)          % will give erf(x) = 2/sqrt(pi) \int_0^x e^{-t^2} dt
I2 = int(sin(x)/x,x,0,inf)       % classic integral = pi/2

% Linear algebra: eigenvalues/eigenvectors
syms lam
A = [a b; b a];                   % symmetric 2x2
[eV,eD] = eig(A)                 % symbolic eigendecomposition

% Matrix inversion
syms a b c
A = [a b 0 1;
     0 a 1 0;
     0 1 c 0;
     1 0 0 b];
inv(A)

% Solve an ODE symbolically
% y'(x) + y = x, y(0)=1
syms Y(x)
ode = diff(Y,x) + Y == x;
cond = Y(0) == 1;
Ysol = dsolve(ode,cond)

% Convert symbolic expression to numeric function (fast evaluation)
syms s
phi = exp(-s^2) * sin(3*s);
phi_fun = matlabFunction(phi,'Vars',s)    % function handle
xs = linspace(-2,2,400);
ys = phi_fun(xs);
figure;
plot(xs,ys);
xlabel('s'); ylabel('\phi(s)');

%---------
%% VARIABLE ASSIGNMENT
% MATLAB is dynamically typed: a variable can change its type at runtime.

x = 17
% x is assigned a scalar double value.
% MATLAB does not require explicit type declaration.

x = 'hat'
% x is reassigned as a character array.
% The previous numeric value is overwritten.

x = [3*4, pi/2]
% x is now a numeric row vector.
% Expressions are evaluated first (3*4 = 12, pi/2 ≈ 1.57).

help sin

y = 3*sin(x)
% sin(.) operates elementwise on vectors.
% The result y is a vector of the same size as x.

clear x
% Removes variable x from the workspace entirely.
% Useful for avoiding accidental reuse of stale variables.

x.number = 17;
% x is now a structure with a field named 'number'.
% Structures allow grouping heterogeneous data under one variable.

x.string = 'hat'
% Adds a second field to the structure x.
% Fields can store different data types.

x.vector = [3*4, pi/2]
% Adds a vector-valued field.
% Structures are fundamental for organizing complex data and parameters.

%----------
% ITERATION
% Example: summation of integers from 1 to 100

total = 0;
for i = 1:100
    total = total + i;
end
% A for-loop iterates over a sequence.
% Here, i takes values 1,2,...,100 and accumulates their sum.
%
% Analytic solution:
% 1 + 2 + ... + 100 = 101*50 = 5050
% Loops are often conceptually simple
% but not always computationally necessary.

x = 1:100;
sum(x)

% Vectorized computation.
% MATLAB is optimized for array operations; sum(x) is clearer and faster
% than an explicit loop for this task.

total = 0;
for i = 100:-1:1
    total = total + i;
end
% The loop direction can be reversed.

total = 0;
for i = 100:2:1
    total = total + i;
end
total
% This loop does NOT execute.
% The colon operator requires the step to move toward the endpoint.
% Correct version:
total = 0;
for i = 100:-2:1      % <— fixed: step sign must match direction
    total = total + i;
end
% This sums only the even numbers from 100 down to 2.
% It illustrates how the colon operator [start:step:end]

%----------------------
%% CONDITIONAL STATEMENTS

x = -50:50;
% x is a row vector of integers from -50 to 50.
% MATLAB uses vectorized arithmetic by default.

y = cos(x)./(x.^2 + 1);
% Elementwise operations:
%   cos(x)      applies cosine to each element of x
%   x.^2        squares each element
%   ./          performs elementwise division
% Elementwise operations in MATLAB:  .*, ./, .^ when working with arrays.

figure; plot(x,y)
% Simple visualization to understand the behavior of the function
% before performing numerical analysis.

% Example Study: Finding maximum
n = length(x)
% length returns the number of elements in the vector.
% This defines the loop boundary explicitly.

% initial value
ind = 1;
temp = y(ind);
% Initialization step is critical.
% We assume the first element is the current maximum before comparison.
% temp stores the current maximum value, ind stores its index.

% find maximum
for i = 2:n
   if y(i) > temp
       ind  = i;
       temp = y(i);
   end
end
% Conditional statement (if) is evaluated at each iteration.
% When a larger value is found, both the maximum value (temp)
% and its location (ind) are updated.

[x(ind) y(ind)]


%--------------------------
% FUNCTION Assignment and handling

g = @(x) cos(x)./(x.^2 + 1);
integral(g, -50, 50)
% integral() uses adaptive numerical quadrature - Riemann sum with adaptive intervals


% ALGEBRAIC (SYMBOLIC) DIFFERENTIATION IN MATLAB
% MATLAB performs algebraic differentiation using the Symbolic Math Toolbox.
% The computation is exact (symbolic), not numerical.

syms x
% Declare x as a symbolic variable.

f = cos(x)/(x^2 + 1);
% Define an algebraic expression symbolically.

df = diff(f, x);
%df =
% - sin(x)/(x^2 + 1) - (2*x*cos(x))/(x^2 + 1)^2
% diff computes the exact derivative df/dx using calculus rules

simplify(df)
% simplify attempts to algebraically reduce the expression. 
%- sin(x)/(x^2 + 1) - (2*x*cos(x))/(x^2 + 1)^2

% Higher-order derivatives:
d2f = diff(f, x, 2)
% Computes the second derivative d^2 f / dx^2.
%(4*x*sin(x))/(x^2 + 1)^2 - (2*cos(x))/(x^2 + 1)^2 - cos(x)/(x^2 + 1) + (8*x^2*cos(x))/(x^2 + 1)^3
% Evaluate the symbolic derivative at a point:
subs(df, x, 0)
% Substitutes x = 0 into the symbolic derivative.

% Convert symbolic derivative to a numeric function:
df_fun = matlabFunction(df)
% Allows fast numerical evaluation, e.g., df_fun(1.5).
df_fun =
%
%  function_handle with value:
%
%    @(x)-sin(x)./(x.^2+1.0)-x.*cos(x).*1.0./(x.^2+1.0).^2.*2.0

df_fun([-:0.1:1]')
% ans =
% 
%     0.6909
%     0.7743
%     0.8519
%     0.9147
%     0.9506

%---------------------
% RANDOM NUMBERS
% MATLAB random numbers are generated from discrete uniform integers
% and then transformed into other distributions.

help unidrnd
% unidrnd generates discrete uniform random integers.

n = 10;
x = unidrnd(n, [1 10])
% Generates 10 integers uniformly from {1,2,...,10}.
% This is purely discrete randomness.

n = 10000;
x = unidrnd(n, [1 10]);
x = x / n
% Scaling integers by n maps them into (0,1].
% This illustrates how continuous random numbers
% are constructed from discrete integers.

x = unifrnd(0,1, [1 10])
% Generates 10 samples from a uniform distribution on (0,1).
% unifrnd generates continuous uniform random numbers
% on a specified interval using internal transformations.

n = 100000;
x = unifrnd(-1,1, [1 n]);
figure; hist(x,100)
% Uniform distribution on (-1,1).
% The support of the distribution is clearly bounded.

y = atanh(x);
figure; hist(y,100)
% Nonlinear transformation of a uniform variable.
% The resulting distribution is no longer uniform.
% This illustrates a core principle:
% new distributions are generated by transforming
% underlying uniform random variables.

%-------------------------
% PLOTTING Curves
% Illustrates basic plotting concepts in MATLAB:
% scatter plots, explicit curves, and parametric (implicit) curves.

% Explicit representation
% y = f(x)
x=-1:0.01:1;
y = sqrt(1 - x.^2);
figure; plot(x,y,'+k')
hold on; plot(x,-y,'+k')
hold on; plot(x,y,'-r')
hold on; plot(x,-y,'-r')
% y is explicitly defined as a function of x.
% The two plots correspond to the upper and lower halves of a curve.
% Elementwise power (.^) is essential for vector x.

% -------------------------------------------------
% Parametric represention - better for visualizing closed curves and
% surfaces 
theta = 0:0.05:2*pi;
x = cos(theta);
y = sin(theta);
figure; plot(x,y,'+k')
hold on; plot(x,y,'-r')
% Parametric form avoids multivalued issues.
% x and y are both functions of a parameter (theta),
% which is often the cleanest way to represent closed curves.


%-------------------------
% Example study: COMPUTATION OF PI (Monte Carlo)
% Idea: sample points uniformly in the unit square [0,1]x[0,1].
% The quarter-unit circle has area pi/4, so P( x^2+y^2 <= 1 ) = pi/4.
% Thus pi ≈ 4 * (fraction of points inside the quarter circle).

figure; axis square;

n = 100;
x = unifrnd(0,1,[1,n]);
y = unifrnd(0,1,[1,n]);
r = sqrt(x.^2 + y.^2);
hold on; plot(x,y,'+k')
% Plot all sampled points in the square.

p = 0;
for i = 1:n
    if r(i) <= 1
        p = p + 1;
        hold on; plot(x(i),y(i),'or')
    end
end
% Conditional statement counts points inside the quarter circle.
% Red circles mark accepted points (inside r<=1).

ourPi = 4*p/n
% Monte Carlo estimator of pi.

% more efficient codes
p = length(find(r <= 1));
OurPi = 4*p/n
% Same computation without an explicit loop.
% Uses logical condition r<=1 and counts the TRUE entries.

% rate of convergence
OurPi = [];
for n = 1:10000
    n
    x = unifrnd(0,1,[1,n]);
    y = unifrnd(0,1,[1,n]);
    r = sqrt(x.^2 + y.^2);
    p = length(find(r <= 1));
    OurPi = [OurPi 4*p/n];
end
figure; plot(OurPi)

%Question: What is the rate of convergence. 



%---------
% Matrix and its visulaization 
%Krnonecker product
B=unifrnd(0,1,[5 5])

figure
imagesc(B)
colorbar 
colormap('hot')
% This is an image. 

A=ones(5,5);
C=kron(A,B);

figure
imagesc(C)
colorbar 
colormap('hot')

%--------------------------
% MATRIX EQUSTIONS

m = 3; n = 2;
%A = zeros(m,n)
% zeros(m,n) creates an m-by-n matrix initialized to zero.
% Preallocation is important for efficiency.

A(1,1) = 1
A(1,3) = 1
% Matrix indexing uses (row, column).
% NOTE: This line will cause an index error because A has only 2 columns.
% It illustrates that matrix dimensions must be respected.
A(5,5) % Older matlab used to automatically exatend it to 5 by 5 matrices

% -------------------------------------------------
% AX = b : DETERMINED SYSTEM (square, full rank)
%   x1      + x3 = 4
%  -x1 + x2 + x3 = 4
%   x1 - x2 + x3 = 2
      
A = [ 1  0  1
     -1  1  1
      1 -1  1 ];

b = [4 4 2]';

X = A\b
% Backslash operator solves AX = b.
% -------------------------------------------------
% OVER-DETERMINED SYSTEM (more equations than unknowns)
% No exact solution exists
%   x1              = 4
%  -x1 + x2         = 4
%   x1 - x2         = 2

A = [ 1  0  0
     -1  1  0
      1 -1  0 ];

b = [4 4 2]';
% X =
%      4
%      8
%    Inf
%
X = A\b %Nonsense operation. Gaussian elemenation cannot solve this problem.  
% Because A is singular and the system is inconsistent, the behavior can be numerically unstable.



X = pinv(A)*b
% Moore–Penrose pseudoinverse solution.
% pinv(A)*b returns the Moore–Penrose pseudoinverse solution:
% it minimizes ||A*X - b||_2 and among all minimizers chooses the minimum-norm X.
% X =
% 
% 4.0000
% 5.0000
% 0


% -------------------------------------------------
% UNDER-DETERMINED SYSTEM (more unknowns than equations)
%   2x1 - 2x2 = -8
%  -2x1 + 2x2 =  8

A = [ 2 -2
     -2  2 ];
b = [-8 8]';

X = pinv(A)*b
% Infinitely many solutions exist.
% pinv returns the minimum-norm solution.

A = [ -1  1
       0  0 ];
b = [4 0]';

X = pinv(A)*b
%Question: This is not coincidence. WHy solution is invaraint of b? 








