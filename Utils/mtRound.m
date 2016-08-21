function out = mtRound(in, precision)

if nargin < 2
    precision = 1;
end
out = round(in./precision).*precision;