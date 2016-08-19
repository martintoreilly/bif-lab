function mtValidateNumericParameter(param)
%mtValidateNumericParameter
% Validates that a parameter is a number and throws an error if it is not.
%
% USAGE: mtValidateNumericParameter(param)

paramName = inputname(1);
if(isempty(param))
    error('mtValidateNumericParameter:IsEmpty',[paramName,' is empty']);
end
if(~isnumeric(param))
    error('mtValidateNumericParameter:NotNumeric',...
      [paramName,' is not a number']);
end
