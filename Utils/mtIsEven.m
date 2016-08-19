function isEven = mtIsEven(number)
%mtIsEven
% Checks whether a number is even
%
% USAGE: isEven = mtIsEven(number)

mtValidateNumericParameter(number);
remainder = mod(number, 2);
isEven = (remainder == 0);
