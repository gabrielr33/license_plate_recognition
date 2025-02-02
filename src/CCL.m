% Author: Gabriel Ratschiller

% Identifies the connected components in an image and assigns each one a
% unique label. Checks the area of each label and returns only the
% components that are inside the range.

%input...Image to be processed
%rangePlateArea...Range of minimum to maximum plate area
%result...Image with the components that fall within the range of the plate area

function [result] = CCL(input, rangePlateArea)

    % extract objects between 1% and 30% of image size
    [labelMatrix, numConnObjects] = bwlabel(input);
    result = labelMatrix;
    
    % go through all objects
    for n = 1:numConnObjects

        % get area of object n
        areaOfObject = length(find(labelMatrix == n));
        
        % if the area is too big or too small set value to 0
        if areaOfObject > rangePlateArea(2) || areaOfObject < rangePlateArea(1)
            result(result == n) = 0;
        end   
    end
    
    % convert image to [0,1] by setting every value >=1 to 1
    result = logical(result);
end
