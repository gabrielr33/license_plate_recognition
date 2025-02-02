% Author: Gabriel Ratschiller

% STEP 2 of the license plate processing pipeline. Detects the characters
% in the license plate and the federal state and returns the found characters
% and the origin of the license plate as text.

%input_image...Image to be processed
%app...Instance of the app that holds all GUI elements
%result...Characters found in the license plate

function [result] = character_segmentation(input_image, app)
    
    %% get image size and ratio
    [col, row, ~] = size(input_image);
    areaRatio = row / col;

    %% resize image and convert RGB-image to grayscale image
    input_image = imresize(input_image, [500 500 * areaRatio]);
    input_image = rgb2gray(input_image);

    %% erode and dilate plate
    se = strel('square', 5);    
    erode_image = imerode(input_image, se);
    plot_image(erode_image, app.processed_image_axes, 'eroding image..', app);
    
    dil_image = imdilate(erode_image, se);
    plot_image(dil_image, app.processed_image_axes, 'dilating image..', app);

    %% binarize picture and flip bits
    bin_image = ~imbinarize(dil_image);
    plot_image(bin_image, app.processed_image_axes, 'binarizing image..', app);
    
    %% remove small objects from binary image
    bin_image = bwareaopen(bin_image, 50);
    bin_image = imclearborder(bin_image);
    bin_image = bwareaopen(bin_image, 200);
    plot_image(bin_image, app.processed_image_axes, 'removing small objects..', app);

    %% CCL
    [labelMatrix, numConnObjects] = bwlabel(bin_image);

    %% template matching
    plateArea = col * row;    
    foundCharacters = [];
    plateOrigin = 'Nicht Oesterreich';

    % load template matching data
    templatesData = load("templates_data");
    templateMatrix = templatesData.templates_data;

    % minimum area of plate is 1% of image
    minExtractedObjectArea = int32(plateArea * 0.01);

    for n = 1:numConnObjects

        % extract objects from plate
        [row, col] = find(labelMatrix == n);
        extractedObject = bin_image(min(row):max(row), min(col):max(col));

        % do not consider object if it is too small or the ratio is not good
        extractedObjectArea = size(extractedObject, 1) * size(extractedObject, 2);
        extractedObjectRatio = size(extractedObject, 2) / size(extractedObject, 1);

        if extractedObjectArea < minExtractedObjectArea || extractedObjectRatio > 1
            continue;
        end

        % draw rectangles arround objects
        rectangle(app.processed_image_axes, 'Position', [min(col), min(row), size(extractedObject, 2), size(extractedObject, 1)], 'EdgeColor', 'g', 'LineWidth', 2)

        % resize object to the size of the template
        templateSize =400;
        extractedObject = imresize(extractedObject, [templateSize, templateSize * 0.57]);

        % match connected objects with templates
        coefficients = [];
        numTemplates = size(templateMatrix, 2);

        for i = 1:numTemplates

            res_image = imresize(templateMatrix{1, i}, [templateSize, templateSize * 0.57]);
            subMeanImg = res_image - mean2(res_image);
            subMeanTmpl = extractedObject - mean2(extractedObject);
            
            % calculate the correlation coefficients of each template
            correlationCoefficient = (sum(sum(subMeanImg .* subMeanTmpl))) / (sqrt(sum(sum((subMeanImg .^2))) .* sum(sum((subMeanTmpl .^2)))));

            coefficients = [coefficients correlationCoefficient];
        end

        % only consider object if max coefficient > 0.4
        if max(coefficients) > 0.4

            % get char with max coefficient out of template matrix
            indexOfMaxCoefficient = coefficients == max(coefficients);
            foundChar = cell2mat(templateMatrix(2, indexOfMaxCoefficient));
            
            [~, charRow] = size(foundChar);

            % foundChar longer than 1 -> it is the origin and not a letter
            if (charRow > 1)
                plateOrigin = foundChar;
                foundChar = '-';
            end

            foundCharacters = [foundCharacters foundChar];
        end
    end

    result = sprintf('%s %s', foundCharacters, plateOrigin);
end
