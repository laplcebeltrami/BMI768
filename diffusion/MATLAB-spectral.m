% Diffusion on Manifolds
%
% (C) 2022- Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu

%-------------------------
%% Hippocampus surface mesh data
% Surface data is published in 
% Chung, M.K., Kim, S.-G., Schaefer, S.M., van Reekum, C. M., Schmitz, L.P., 
% Sutterer, M., Davidson, R.J. 2014. Improved statistical power with a 
% sparse shape model in detecting an aging effect in the hippocampus and 
% amygdala, Proceedings of SPIE Medical Imaging 9034, 90340Y
% http://pages.stat.wisc.edu/~mchung/papers/chung.2014.SPIE.pdf

load hippocampus.mat   
% Contains left and right hippocampus surface

figure;figure_patch(hippoleft,'r',0.5)
hold on;
figure_patch(hipporight,'y',0.5)
axis on;
legend('Left', 'Right');
% The left and right has to be flipped. 
% This is a routine problem in converting from the 
% original MRI scans to software packages. 

center = (mean(hippoleft.vertices) + mean(hipporight.vertices))/2
% Flip left and right hippocampus by mirroring across the mid-sagittal plane
hippoleft_flipped = hippoleft;
hipporight_flipped = hipporight;

hippoleft_flipped.vertices(:, 1) = 2 * center(1) - hippoleft.vertices(:, 1);
hipporight_flipped.vertices(:, 1) = 2 * center(1) - hipporight.vertices(:, 1);

% Re-plot the flipped hippocampi
figure;
figure_patch(hippoleft_flipped, 'r', 0.5);
hold on;
figure_patch(hipporight_flipped, 'y', 0.5);
axis on;
legend('Left', 'Right');

%------------------------------
%% Eigenfunctions of Laplace-Beltrami operator
% Eigenfunctions are estimated using the finite element 
% method (FEM) based on the cotan formulation published in
%
% Chung and Taylor, 2004 Diffusion smoothing on brain surface 
% via finite element method. IEEE International Symposium on 
% Biomedical Imaging: Nano to Macro pp. 432-435: 
% https://pages.stat.wisc.edu/~mchung/papers/BMI2004/diffusion_biomed04.pdf
%
% Chung, M.K. 2013. Statistical and Computational Methods in Brain 
% Image Analysis,   CRC Press. Chapter 13 

[A, C] =FEM(hippoleft);
figure; subplot(1,2,1); imagesc(abs(A)); colorbar
set(gcf,'Color','w')  %Set the background as white.
subplot(1,2,2); imagesc(abs(C)); colorbar
set(gcf,'Color','w') 
%print -r300 -dtiff FEMC  %Save figure image as tiff file. 

%Computes 100 eigenvectors and eigenvalues from the smallest.  
[V,D] = eigs(C,A, 100,'sm');
figure; plot (diag(D));

% visualize first 10 eigenfunctions

for i=1:10
    figure;
    figure_trimesh(hippoleft,V(:,i),'rwb');
    caxis([-0.04 0.04]); 
    view(146,24);
    camlight('headlight'); 
    %print('-dtiff', '-r300',strcat('hippo-eigen', num2str(i),'.tif'))
end;


%----------------------------------------------------
%% Diffusion on Manifold
%
% The method is based on
% Seo et al. 2010. Heat kernel smoothing using Laplace-Beltrami 
% eigenfunctions. MICCAI 6363:505-512

figure; subplot(1,2,1); figure_wire(hippoleft,'k','w') 
view([140 10])

[A, C] =FEM(hippoleft);
[V, D] = eigs(C,A,500,'sm'); 

%Diffusion on hippocampus surface coordinates
hippolefts = lb_smooth([],hippoleft, 0.2, 500, V, D);
subplot(1,2,2);figure_wire(hippolefts,'k','w') 
view([140 10])

%Diffusion on simulated functional data defined on hippocampus

signal = hippolefts.vertices(:,1) + normrnd(0,100,2338,1);
figure; subplot(1,2,1); figure_trimesh(hippoleft,signal); 
axis on; colormap('jet')
view([140 10]); camlight

smoothed = lb_smooth(signal,hippoleft, 1, 500, V, D);
figure; subplot(1,2,2); figure_trimesh(hippolefts,smoothed);
axis on; colormap('jet')
view([140 10]); camlight



