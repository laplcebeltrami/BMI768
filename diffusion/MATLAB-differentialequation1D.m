% Differential Equation
% (C) Moo K. Chung 
% University of Wisconsin
% mkchung@wisc.edu

%---------------------------------
% Differentiation in 1D

%Gaussian Kernel  in 1D
K=inline('exp(-(x.^2)/2/sigma^2)');
dx= -50:50;
weight=K(10,dx)/sum(K(10,dx))
figure; plot(weight);
%Question: This is truncated kernel. 
% Why Gaussian kernel has to be truncatd.


%Derivative of truncated Gaussian kernel
dweight = diff(weight) %computed by taking finite difference
hold on; plot(dweight, 'r');


% Jump discontinuity detection in 1D signal
x=1:1000;
noise=normrnd(0, 0.1, 1,1000);
%ground truth
signal=[zeros(1,300) ones(1,400) zeros(1,300)];
figure; plot(signal, 'k', 'LineWidth', 3);
y= signal + noise;
hold on; plot(y, '.k');

%Gaussian kernel smoothing
smooth=conv(y,weight,'same');
hold on;plot(smooth, 'r:', 'LineWidth', 3); 

%Boundary/edge/jump detection
dsignal=conv(y,dweight,'same');
hold on;plot(dsignal, 'b', 'LineWidth', 3); 

figure; plot(dsignal, 'b', 'LineWidth', 3); 
find(dsignal == max(dsignal)) %time point where direvative changes
find(dsignal == min(dsignal)) %time point where direvative changes


%------------------------------
% EEG of epilpsy seizure patient
% See if we can detect the time point of seizure. 
%
% This is data published in 
% Wang, Y., Ombao, H., Chung, M.K. 2018 Topological data 
% analysis of single-trial electroencephalographic signals. 
% Annals of Applied Statistics, 12:1506-1534
% https://pages.stat.wisc.edu/~mchung/papers/wang.2018.annals.pdf
% 
% Channel names
% left central c3 
% Sampling rate is 100 Hertz 
% Total Time point = 32000+
% First half is preseizure; right half is seizure


c3=load('c3.formatted');
d=size(c3);
d(1)*d(2)

c3=reshape(c3', d(1)*d(2),1);
c3=c3(1:d(1)*d(2)-2);
figure; plot(c3) %whole EEG 

d=length(c3)/2
c3sub = c3(1:d)
hold on; plot(c3sub, 'r:') %pre seizure colored red

K=inline('exp(-(x.^2)/2/sigma^2)');
dx= -500:500;

weight=K(20,dx)/sum(K(20,dx))
smooth=conv(c3,weight,'same');
hold on;plot(smooth, 'k-');

%Edge detection via differentiation may not work.  
dweight = diff(weight)
dsignal=conv(c3,dweight,'same');
hold on;plot(dsignal, 'k', 'LineWidth', 4); 

%Let's try a different emthod 
%The variance map approach also don't work
% Variance is often useed feature in EEG sginal analysis.

for i=1:length(c3)-50
    c3var(i)=var(smooth(i:i+50));
end

hold on;plot(c3var, 'k', 'LineWidth', 3); 

%Suggestion: We will study TDA approach later 
%            using the Morse filtrations.

%----------------------------------
% Diffusion Equation in 1D
% We will sove the diffusion equations using the 
% eigenctions of Laplace-Beltrami operator

%Simulate signal
x=1:1000;
noise=normrnd(0, 0.5, 1,1000);
signal= [zeros(1,300) ones(1,400) zeros(1,300)];
figure; plot(signal, 'k', 'LineWidth',2);
y= signal + noise; %noise added signal
hold on; plot(y, ':k');

%Gaussian kernel smoothing
K=inline('exp(-(x.^2)/2/sigma^2)');
dx= -50:50;
weight=K(10,dx)/sum(K(10,dx))
smooth=conv(y,weight,'same');
hold on;plot(smooth, 'r', 'LineWidth', 3); 

%Diffusion equation
L = [1 -2 1] %1D Laplacian = 2nd derivative
%Lsmooth = conv(y,L,'same');

g=y; %initial value
for i=1:1000  %total diffusion time =10
    Lg = conv(g,L,'same');
    g = g+ 0.01*Lg;
end
hold on;plot(g, 'g', 'LineWidth', 2);     

g=y; %initial value
for i=1:1000000  %total diffusion time =10
    Lg = conv(g,L,'same');
    g = g+ 0.01*Lg;
end
hold on;plot(g, ':b', 'LineWidth', 5);     

%Question: what will happen if you run the iteration 
%for infinite number of times?


