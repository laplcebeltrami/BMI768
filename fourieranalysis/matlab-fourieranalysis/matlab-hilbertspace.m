%% Hilbert space theory in 1D
% (c) Moo K. Chung
% University of Wisconsin-madison
% mkchung@wisc.edu

%% White matter fiber tract data
% Data was published in
% Chung, M.K., Adluru, N., Lee, J.E., Lazar, M., Lainhart, J.E., Alexander, 
% A.L., 2010. Cosine series representation of 3D curves and its application 
% to white matter fiber bundles in diffusion tensor imaging. 
% Statistics and Its Interface. 3:69-80 
% https://www.stat.wisc.edu/~mchung/papers/chung.2010.SII.pdf
%
% Additional MATLAB codes:
% http://brainimaging.waisman.wisc.edu/~chung/tracts/

%Load tract data
load SL.mat;

figure1 =figure;
for i=1:10000
    tract=SL{i}'; %1000th tract out of total 10000 tracts
    hold on; plot3(tract(1,:),tract(2,:),tract(3,:),'.')
end


%%Exact 100-th tract
tract=SL{100}
% map x,y,z coordinates onto the unit interval [0,1]
[arc_length  para]=parameterize_arclength(tract);
figure2 =figure
subplot(3,1,1); plot(para, tract(1,:));
subplot(3,1,2); plot(para, tract(2,:));
subplot(3,1,3); plot(para, tract(3,:));

%cosine series representation in [0,1]

tract=SL{100}
tract=tract';
figure(3)
plot3(tract(1,:),tract(2,:),tract(3,:),'.b')
[arc_length  para]=parameterize_arclength(tract);
[wfs beta]=WFS_tracts(tract,para,5);
hold on; plot3(wfs(1,:),wfs(2,:),wfs(3,:),'-r')

%% Simulation
% Let's simulate 3D helical curves. 
% Deterministic simulation of 3D curve 
% $(x,y,z) =(t \sin(t), t\cos(t), t)$.

t=0:0.1:10
tract=[t.*sin(t); t.*cos(t); t];
figure; plot3(tract(1,:),tract(2,:),tract(3,:),'.b')
%
[arc_length  para]=parameterize_arclength(tract);  %computing arclength
[wfs beta]=WFS_tracts(tract,para,19);  %computing cosine series expansion
hold on; plot3(wfs(1,:),wfs(2,:),wfs(3,:),'r')
legend('simulated data', 'Cosine series representation')

%% Question
% Why 20 basis functions fit the curve segment perfectly?


% Stocastic simulation
% Let's add noise and generate 20 more tracts
% We are tring to generate similarly shaped random tracts
% Let tract1 be a clinical population.

t=0:0.1:10
figure;
view(3);
tract1=zeros(3,101,20);
for i=1:20
    tract1(:,:,i)=[t.*sin(t+normrnd(0,0.1)); t.*cos(t+normrnd(0,0.1)); t+normrnd(0,0.1)];
    hold on; plot3(tract1(1,:,i),tract1(2,:,i),tract1(3,:,i),'--');
end;


%% Interactive curve drawing in MATLAB
% The left mouse button picks points and the right mouse button picks last point.

% The code was used in generating a toy example:
% Wang, Y., Chung, M.K., Fridriksson, J. 2022 Spectral permutation test on 
% persistent diagrams, International conference on acoustics,speech and signal 
% processing (ICASSP) 1461-1465
% https://pages.stat.wisc.edu/~mchung/papers/wang.2022.ICASSP.pdf


figure; 
I = imread('toy-key.tif');
imshow(I);
hold on
xy = [];
n = 0;
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    plot(xi,yi,'ko')
    n = n+1;
    xy(:,n) = [xi;yi];
end
hold on;
plot([xy(1,:) xy(1,1)], [xy(2,:) xy(2,1)], 'k-');


%% Cosine series representation of the above closed curve

[arc_length  para]=parameterize_arclength(xy);
figure;
subplot(2,1,1); plot(para, xy(1,:));
subplot(2,1,2); plot(para, xy(2,:));

%cosine series representation in [0,1]
figure;plot(xy(1,:),xy(2,:),'o-')
[wfs beta]=WFS_tracts(xy,para,5);
hold on; plot(wfs(1,:),wfs(2,:),'-r')

%It seems like working but not exactly correct. 
% Why?We didn't force the periodic constraint in the representation.
%% Problem. Force the periodic constraint and refit CSR. How?
