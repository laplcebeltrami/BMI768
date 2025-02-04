function output=lb_smooth(input,surf,sigma, k, V, D)
%output=lb_smooth(input,surf,sigma, k, V, D)
%
% The function performs heat kernel smoothing 
% (equivalen to diffusion) using the eigenfunctions 
% of the Laplace-Beltrami operator on a triangle mesh. 
% 
% 
% input       : Signal to smooth.
% surf        : Structured array consisting of surf.vertices and surf.faces.
%               The default MATLAB data strcture for isosurface algorithm
%               is needed
% sigma       : bandwidth. The bandwidth corresponds to diffuion time in a heat equation [3]. 
% k           : number of basis used
% V           : eigenfunctions of the Laplace-Beltrami operator
% D           : diag(D) gives the eigenvalues of the Laplece-Beltrami
%               operator in increasing order.
%
%
% Example:
%     hippolefts = lb_smooth([],hippoleft, 0.2, 500, V, D);
%     It smooths surface mesh hippolef with sigma = 0.2 and 500 
%     eigenfunctions. See [3] for detail.    
%
% References:
% [1] Chung, M.K. 2001. Statistical Morphometry in Neuroanatomy, 
%     PhD Thesis, McGill University.
%     http://www.stat.wisc.edu/~mchung/papers/thesis.pdf
%
% [2] Chung, M.K., Taylor, J. 2004. Diffusion Smoothing on Brain Surface via Finite 
%     Element Method,  IEEE International Symposium on Biomedical Imaging (ISBI). 562.
%     http://www.stat.wisc.edu/~mchung/papers/BMI2004/diffusion_biomed04.pdf
%
% [3] Seo, S., Chung, M.K., Vorperian, H. K. 2010. Heat kernel smoothing 
%     using Laplace-Beltrami eigenfunctions,
%     Medical Image Computing and Computer-Assisted Intervention (MICCAI) 
%     2010, Lecture Notes in Computer Science (LNCS). 6363:505-512.
%     http://www.stat.wisc.edu/~mchung/papers/miccai.2010.seo.pdf
%
% The details on the mathematical basis of of the algorithm can 
% be found in [3]. Computation for the eigenfunctions of the 
% Laplace-Beltrami is based on FEM discretization given in [1] 
% and [2].
%
%
% The code was downloaed from
% http://brainimaging.waisman.wisc.edu/~chung/lb
%
%
% (C) 2010- Moo K. Chung
%
%  email://mkchung@wisc.edu
%
%  Department of Biostatisics and Medical Informatics
%  University of Wisconsin, Madison
%
% Update history: 2010, April 23
%                 2011, July 16
%                 2019, May 6  Additinal comments 


%--------------
% If input is [], 
if isempty(input)
    p=surf.vertices;
else
    p=input;
end;

%------------------
% k should be smaller than the size of V.
eigen=abs(diag(D));
if eigen(1) < eigen(end)
    eigen=eigen(1:k);
    Psi=V(:,1:k);
else
    % there is a chance eigenvalues are sorted in the reverse order.
    eigen=eigen(end-k+1:end);
    Psi=V(:,end-k+1:end);
end

%-------------------
% exponential weights
% when sigma=0, we have the usual Fourier expansion on manifolds

W= exp(-1*eigen*sigma);
W= repmat(W', size(Psi,1), 1);

%----------------
% least squares estimation of beta. we are solving
%p = Psi * beta
%
% there is a better estimation technique based on 
% FEM discretization but it will be implemented later.


beta= inv(Psi'*Psi)*Psi'*p;

phat=(W.*Psi)*beta;

% If the input is [], we are smoothing surface
if isempty(input)
    output.vertices=phat;
    output.faces = surf.faces;
else
    output=phat;
end;

%figure;figure_patch(surfhat1,[0.74 0.71 0.61],0.5)



% OLD WORKING CODE
% if isempty(input)
%     p=surf.vertices;
% else
%     p=input;
% end;
% 
% Psi=V(:,1:k); %p = Psi * beta
% eigen=diag(D);
% W= exp(-1*eigen(1:k)*sigma);
% 
% %W= repmat(W', size(Psi,1), 1);
% W= repmat(W', size(Psi,1), 1);
% 
% % We will also assume sigma=0, in which case we have eigenfunction
% % expansion.
% beta= inv(Psi'*Psi)*Psi'*p;
% 
% phat=(W.*Psi)*beta;
% 
% if isempty(input)
%     output.vertices=phat;
%     output.faces = surf.faces;
% else
%     output=phat;
% end;
%figure;figure_patch(surfhat1,[0.74 0.71 0.61],0.5)

