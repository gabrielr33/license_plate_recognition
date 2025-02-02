% Author: Gabriel Ratschiller

% Identifies the bounding box of the license plate and crops the input
% image to the bounding box area.

%input...Image to be processed
%connected_components...Image with the connected components
%result...Image cropped to the size of the plate bounding box

function [result] = bounding_box_plate(input, connected_components)
    
    % get bounding box of objects
    objectProperties = regionprops(connected_components, 'BoundingBox');
    % Get number of of regions
    numObjects = size(objectProperties, 1);

    % remove objects that are not suitable plates (ratio, color)
    input = im2double(input);
    maxNumWhitePixels = 0;
    bestFit = 0;

    % if only one object is found take it
    if numObjects == 1
        bestFit = objectProperties(1);
    else
        for i = 1:numObjects
            boundedImage = imcrop(input, objectProperties(i).BoundingBox);
            [height, width] = size(boundedImage);
            aspectRatio = width / height;
            
            % if the aspect ratio does not correspond to that of a licence plate, discard the object
            if aspectRatio < 2 || aspectRatio > 7
                continue
            end

            % convert image to CIE L*a*b* color space
            boundedImage = rgb2lab(boundedImage);
            labWhite = [98 0 0];
            labBlue = [27 14 -50];
            L = boundedImage(:, :, 1);
            a = boundedImage(:, :, 2);
            b = boundedImage(:, :, 3);
            
            % get the pixels that are approximately white
            whitePixelIndices = sqrt((L - labWhite(1)).^2 + (a - labWhite(2)).^2 + (b - labWhite(3)).^2) <= 2.3;
            whitePixels = boundedImage(whitePixelIndices);
            numWhitePixels = size(whitePixels,1);

            % get the pixels that are approximately 'EU' blue
            bluePixelIndices = sqrt((L - labBlue(1)).^2 + (a - labBlue(2)).^2 + (b - labBlue(3)).^2) <= 10;
            bluePixels = boundedImage(bluePixelIndices);            
            numBluePixels = size(bluePixels,1);
            
            % check if the number of white pixels is higher than the
            % current best fit and if there are some blue pixels present
            if (numWhitePixels > maxNumWhitePixels) && numBluePixels > 0
                maxNumWhitePixels  = numWhitePixels;
                bestFit = objectProperties(i);
            end
        end
    end

    if(~isstruct(bestFit))
        result = [];
    else
        result = imcrop(input, bestFit.BoundingBox);
    end
end
