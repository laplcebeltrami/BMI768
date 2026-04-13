function [Yg, Yc, Yh] = Hodge_decompose_edgeflow(flows, B)
% HODGE_DECOMPOSE_EDGEFLOW  Hodge decomposition with outputs aligned to FLOW ROW ORIENTATION.
%
%   [Yg, Yc, Yh] = Hodge_decompose_edgeflow(flows, B)
%
% Inputs:
%   flows : m x 3 list, rows [u v w] meaning directed edge u->v with weight w (w>0).
%   B     : boundary matrices from PH_boundary(S); B{1} = node–edge (|V| x |E|),
%           optionally B{2} = edge–triangle (|E| x |T|). If B{2} absent, curl=0.
%
% Outputs (each m x 1, ALIGNED TO THE ORIENTATION GIVEN IN 'flows'):
%   Yg : gradient component on each flow row's direction
%   Yc : curl component on each flow row's direction (zeros if no B{2})
%   Yh : harmonic component on each flow row's direction
%
% Notes:
%   1) Internally, the decomposition is performed in the REFERENCE edge orientation
%      encoded by the columns of B{1}. Let the column e have incident vertices i (−1) and j (+1),
%      then its reference arrow is i->j. We first assemble Y_ref (|E|x1) in that reference
%      orientation, compute Yg_ref, Yc_ref, Yh_ref, and finally map them back to the
%      orientation of each input flow row [u v w] by a sign flip if needed.
%
% (C) 2025 Moo K. Chung
% University of Wisconsin-Madison
% mkchung@wisc.edu
%
% The code is downloaded from
% https://github.com/laplcebeltrami/hodge
% If you are using the code, refernce one of Hodge papers listed in GitHub.
%
% Update history: November 7, 2025



    B1 = B{1};                 % |V| x |E|
    d0 = sparse(B1');          % |E| x |V|
    E  = size(B1,2);           % number of edges (reference ordering)
    Vn = size(B1,1);

    % Recover reference edge list Eref(e,:) = [i j] with i->j as reference dir
    Eref = zeros(E,2);
    for e = 1:E
        ri = find(B1(:,e)~=0);
        si = B1(ri,e);
        i  = ri(si<0);         % tail (−1)
        j  = ri(si>0);         % head (+1)
        Eref(e,1) = i; Eref(e,2) = j;
    end

    % Assemble Y_ref (|E|x1) from directed flows [u v w]
    Y_ref = zeros(E,1);
    U = flows(:,1); V = flows(:,2); W = flows(:,3);
    iu = min(U,V); ju = max(U,V);
    key_flw = sub2ind([Vn Vn], iu, ju);
    iu_ref = min(Eref(:,1), Eref(:,2));
    ju_ref = max(Eref(:,1), Eref(:,2));
    key_ref = sub2ind([Vn Vn], iu_ref, ju_ref);

    for r = 1:numel(W)
        kf = key_flw(r);
        e  = find(key_ref == kf, 1);
        if isempty(e)
            % edge in flows not present in B{1}; skip (treated as 0)
            continue
        end
        if U(r)==Eref(e,1) && V(r)==Eref(e,2)
            Y_ref(e) = Y_ref(e) + W(r);
        else
            Y_ref(e) = Y_ref(e) - W(r);
        end
    end

    % Gradient component in reference orientation
    L0  = (d0')*d0;
    rhs = d0' * Y_ref;                 % L0 s = d0' * Y_ref
    s   = mylsqr(L0, rhs);
    Yg_ref = d0 * s;

    % Curl component in reference orientation (if B{2} provided)
    if numel(B) >= 2 && ~isempty(B{2})
        d1 = sparse(B{2}');            % |T| x |E|
        L1 = d1*d1';
        curl = d1 * Y_ref;
        z   = mylsqr(L1, curl);
        Yc_ref = d1' * z;
    else
        Yc_ref = zeros(E,1);
    end

    % Harmonic in reference orientation
    Yh_ref = Y_ref - Yg_ref - Yc_ref;

    % Map back to the ORIENTATION OF EACH FLOW ROW [u v w]
    m = size(flows,1);
    Yg = zeros(m,1); Yc = zeros(m,1); Yh = zeros(m,1);
    for r = 1:m
        kf = key_flw(r);
        e  = find(key_ref == kf, 1);
        if isempty(e)
            % no matching reference edge; leave zeros
            continue
        end
        if U(r)==Eref(e,1) && V(r)==Eref(e,2)
            sgn = +1;
        else
            sgn = -1;
        end
        Yg(r) = sgn * Yg_ref(e);
        Yc(r) = sgn * Yc_ref(e);
        Yh(r) = sgn * Yh_ref(e);
    end
end


%----------
function x = mylsqr(A, b)
% function x = mylsqr(A, b)
% Minimal wrapper around LSQR without display output.
% It solves A*x ≈ b using the same algorithm but suppresses text output.

tol = 1e-12;       % tolerance
maxit = 1000;      % maximum iterations
x0 = [];           % no initial guess

% Run LSQR with output suppression
[xx, ~, ~, ~] = lsqr(A, b, tol, maxit, [], [], x0);
x = xx;
end