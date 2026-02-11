function A = flows2matrix(v, p)
% FLOWS2MATRIX  Convert edge-flow vector(s) (i<j ordering) 
% to antisymmetric matrix/matrices.
%
% INPUT:
%   v  - edge-flow values with i<j ordering. Allowed shapes:
%        (m x 1), (m x T), or (m x T x S), where m = p*(p-1)/2.
%   p  - number of nodes.
%
% OUTPUT:
%   A  - antisymmetric matrices with matching extra dims:
%        If v is (m x 1)       -> A is (p x p)
%        If v is (m x T)       -> A is (p x p x T)
%        If v is (m x T x S)   -> A is (p x p x T x S)
%
% Convention:
%   For each unordered pair (i<j), A(i,j) = v_k and A(j,i) = -v_k.
%
% (C) 2026 Moo K. Chung
% University of Wisconsin–Madison

    % ---- sanity check on m ----
    m_expected = p*(p-1)/2;
    szv = size(v);
    m = szv(1);
  

    % Normalize dimensions to (m x T x S)
    switch ndims(v)
        case 2
            % (m x 1) or (m x T)
            if szv(2) == 1
                T = 1; S = 1;
            else
                T = szv(2); S = 1;
            end
            v = reshape(v, [m, T, S]);
        case 3
            T = szv(2); S = szv(3);
        otherwise
            error('flow_to_matrix:badDims', ...
                  'v must be (m x 1), (m x T), or (m x T x S).');
    end

    % Precompute upper-triangular mask (i<j)
    UTmask = triu(true(p),1);

    % Allocate output
    if T==1 && S==1
        A = zeros(p,p);
        A(UTmask) = v(:,1,1);
        A = A - A.';                     % enforce antisymmetry
    else
        A = zeros(p,p,T,S);
        % fill per time & subject
        for s = 1:S
            for t = 1:T
                M = zeros(p,p);
                M(UTmask) = v(:,t,s);    % assign upper triangle (i<j)
                A(:,:,t,s) = M - M.';    % antisymmetrize
            end
        end
    end
end