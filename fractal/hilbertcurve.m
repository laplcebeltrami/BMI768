function [x,y] = hilbertcurve(n)
%HILBERTCURVE Hilbert curve coordinates.
%
% [x,y] = hilbertcurve(n) returns the coordinates of the n-th order
% Hilbert curve.
%
% Example:
%   [x,y] = hilbertcurve(5);
%   figure;
%   plot(x,y,'-');
%   axis equal
%
%   Copyright (c) by Federico Forte
%   Date: 2000/10/06 
%   Modification and comments by Moo K. Chung

if n<=0
    x=0;
    y=0;
else
    % Recursive call to the same function
    [xo,yo]=hilbertcurve(n-1);

    % Construct four rotated/reflected/scaled copies
    x=.5*[-.5+yo  -.5+xo   .5+xo   .5-yo];
    y=.5*[-.5+xo   .5+yo   .5+yo  -.5-xo];
end
end
