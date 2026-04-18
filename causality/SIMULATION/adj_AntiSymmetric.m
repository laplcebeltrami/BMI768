function TLout = adj_AntiSymmetric(TL)
% ADJ_ANTISYMMETRIC  Convert directional adjacency matrices to antisymmetric form.
%
% This function takes a stack of directed (possibly asymmetric) matrices and
% converts each into an antisymmetric matrix by retaining only the dominant
% direction for every unordered node pair. For each pair (i,j), the entry
% with larger magnitude is kept as positive, and the opposite direction is
% assigned the negative value, enforcing antisymmetry.
%
% INPUT:
%   TL    : [R x R x N] array of directional matrices
%          R = number of nodes (regions, variables)
%          N = number of matrices (e.g., time windows, trials, subjects)
%
% OUTPUT:
%   TLout : [R x R x N] antisymmetric matrices such that
%           TLout(i,j,w) = -TLout(j,i,w)  and  TLout(i,i,w) = 0
%
% METHOD:
%   For each slice w = 1,...,N:
%     Compare A(i,j) and A(j,i).
%     The larger entry determines the direction of interaction.
%     The weaker direction is discarded and replaced by its negative.
%
% NOTES:
%   • Diagonal entries are set to zero to remove self-loops.
%   • If A(i,j) == A(j,i), the (i,j) entry is kept positive by convention.
%
% (C) 2025 Moo K. Chung
% University of Wisconsin–Madison
%
% Update history:
%   2024-08-12  Created
%   2024-08-24  Diagonal entries set to zero

[R, ~, N] = size(TL);           % R: number of nodes, N: number of matrices
TLout = zeros(R, R, N);

for w = 1:N
    A = TL(:, :, w);            % Current R x R directional matrix
    A_T = A.';                  % Transpose for pairwise comparison

    % keepIJ(i,j) = true if A(i,j) >= A(j,i)
    keepIJ = A >= A_T;

    B = zeros(R);

    % Assign dominant direction
    B(keepIJ)  = A(keepIJ);

    % Assign opposite direction with negative sign
    B(~keepIJ) = -A_T(~keepIJ);

    % Remove self-loops
    B(1:R+1:end) = 0;

    TLout(:, :, w) = B;
end

end



% function TLout = adj_AntiSymmetric(TL)
% % adj_AntiSymmetric - Converts [R x R x N] directional matrices into antisymmetric form
% % by retaining the dominant direction in each pairwise entry.
% %
% % INPUT:
% %   TL     - [R x R x N] array of directional matrices
% %
% % OUTPUT:
% %   TLout  - [R x R x N] antisymmetric matrices with TLout(i,j,w) = -TLout(j,i,w)
% %
% %
% % (C) 2025 Moo K. Chung, 
% %     University of Wisconsin-Madison
% %
% % Update histroy: 2024 August 12 created 
% %                 2024 August 24 diagonal made into zero
% 
% 
% 
% [R, ~, N] = size(TL);
% TLout = zeros(R, R, N);
% 
% for w = 1:N
%     A = TL(:, :, w);           % Current matrix
%     A_T = A';                  % Transpose for use in indexing
%     keepIJ = A >= A_T;         % Logical mask for keeping A(i,j)
% 
%     B = zeros(R);
%     B(keepIJ) = A(keepIJ);             % Assign dominant direction
%     B(~keepIJ) = -A_T(~keepIJ);        % Assign opposite with negative sign
% 
%     %B(1:R+1:end) = diag(A);            % Preserve diagonal entries
%     B(1:R+1:end) = 0; %make diagonal zero
% 
%     TLout(:, :, w) = B;
% end
% 
% end


% function TLout = adj_AntiSymmetric(TL)
% % adj_AntiSymmetric - Converts a sequence of [R x R x N] directional matrices
% % into antisymmetric form by preserving the dominant edge
% %
% % INPUT:
% %   TL  - [R x R x N] array of asymmetric matrices
% %         TL(i,j,w) is the directional measure from i to j at window w
% %
% % OUTPUT:
% %   TLout - [R x R x N] array of antisymmetric matrices
% %           TLout(i,j,w) = -TLout(j,i,w); diagonal preserved
% %
% % (C) 2025 Moo K. Chung, University of Wisconsin-Madison
% 
% [R, ~, N] = size(TL);
% TLout = zeros(R, R, N);
% 
% for w = 1:N
%     A = TL(:, :, w);
%     B = A;
% 
%     for i = 1:R
%         for j = i+1:R
%             if A(i,j) >= A(j,i)
%                 B(j,i) = -A(i,j);
%             else
%                 B(i,j) = -A(j,i);
%             end
%         end
%     end
% 
%     TLout(:,:,w) = B;
% end
% end