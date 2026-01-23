function Sprf = cellcomplex_flow(Spr)
% CELLCOMPLEX_FLOW
% Introduce a flow field (scalar data) on edges of a cell complex.
%
% Convention:
%   - Scalar data on edges is stored in Sprf.flows
%   - Default flow is simply the current edge orientation
%   - Positive value means along stored edge direction Spr.edges(k,1) -> Spr.edges(k,2)
%
% INPUT
%   Spr : cell complex with fields
%       Spr.nodes : [K x 2]
%       Spr.edges : [E x 2] directed edges
%
% OUTPUT
%   Sprf : same as Spr, with added field
%       Sprf.flows : [E x 1] default edge flows
%
% (C) 2026 Moo K. Chung

Sprf = Spr;

E = size(Spr.edges,1);

Sprf.flows = ones(E,1);       

end