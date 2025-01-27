% main pipeline with all the other functions
function [] = main(input_image)
    
    detectLicensePlate(input_image);

    %imageList = readInImages();
    %for i = 1:length(imageList)
    %    detectLicensePlate(imageList{i});
    %end
end

function detectLicensePlate(input_image)
    app = app_GUI();

    %% 1. convert RGB-image to grayscale image
    % check if the input is a valid RGB image (3 channels)
    if size(input_image, 3) ~= 3
        error('Input image must be RGB (3 channels).');
    end

    gray_image = rgb2gray(input_image);
    plotImage(gray_image, app.axes_2);
    title("Gray scaled image");

    %% 2. median filter to remove noise
    % set filter parameters
    sigma = [3 3];                % filter standard deviations
    filtered_image = medfilt2(gray_image, sigma);
    plotImage(filtered_image, app.axes_3);
    title("Median filtered image");
    
    %% 3. adaptive histogram equalization to enhance contrast
    contr_image = adapthisteq(filtered_image);
    plotImage(contr_image, app.axes_4);
    title("Contrast enhanced image");

    %% 4. image binarization
    % binarize the image using a locally adaptive threshold
    % % % bin_image = imbinarize(contr_image, 'adaptive');
    % % % plotImage(bin_image, app.axes_5);

    %% 5. filter edges with the sobel filter
    edge_image = edge(contr_image);
    plotImage(edge_image, app.axes_5);
    title("Edge filtered image");

    %% 6. apply math. morphologies (dilate and erode) to fill spaces
    % dilation: create a structuring element
    se = strel('diamond', 3);
    dil_image = imdilate(edge_image, se);
    plotImage(dil_image, app.axes_5);
    title("Dilated image");

    % erosion: create a structuring element
    se = strel('square', 3);
    erode_image = imerode(dil_image, se);
    plotImage(erode_image, app.axes_5);
    title("Eroded image");

    %% 7. fill holes
    fill_image = imfill(erode_image, 4, "holes");
    plotImage(fill_image, app.axes_5);
    title("Holes filled image");

    %% 8. remove all objects touching the border
    clear_image = imclearborder(fill_image);
    plotImage(clear_image, app.axes_5);
    title("Objects touchingthe border removed image");

    %% 9. erode image with a diamond- and line-structuring-element
    %se = strel('square', 12);
    %open_image = imopen(clear_image, se);
    % % % plotImage(open_image, app.axes_5);
    % % % title("Opened image");

    se = strel('diamond', 5);
    erode_image_2 = imerode(clear_image, se);
    plotImage(erode_image_2, app.axes_5);
    title("Eroded image 2");

    se = strel('line', 5, 5);
    erode_image_3 = imerode(erode_image_2, se);
    plotImage(erode_image_3, app.axes_5);
    title("Eroded image 3");

    %% 10. remove small objects from the image
    plate_image = bwareaopen(erode_image_3, 50);
    plate_image = imclearborder(plate_image);
    plate_image = bwareaopen(plate_image, 200);
    plotImage(plate_image, app.axes_5);

    %% 11. get the image size to approximate the minimum and maximum area of the plate
    imageArea = size(input_image, 1) * size(input_image, 2);
    minPlateArea = int32(imageArea * 0.002);    %minimum area of plate is 0.2% of picture
    maxPlateArea = int32(imageArea * 0.3);      %maximum area of plate is 30% of picture

    %% 12. connected-components labeling
    % extract objects between 2% and 50% of image size
    range = [minPlateArea, maxPlateArea];
    [labelMatrix, numberOfConnectedObjects] = bwlabel(plate_image);
    cc_image = labelMatrix;

    % go through all objects
    for n = 1:numberOfConnectedObjects  
        % get area of object
        areaOfObject = length(find(labelMatrix == n));
        
        % if the area is too small or too big set pixel value to 0
        if areaOfObject < range(1) ||  areaOfObject > range(2)
            cc_image(cc_image == n) = 0;
        end   
    end

    % Convert image to [0,1] by setting every value >=1 to 1
    cc_image = logical(cc_image);
    plotImage(cc_image, app.axes_5);
    title("Component image");

    %% 13. get bounding box of objects
    objectProperties = regionprops(cc_image, 'BoundingBox');
    % Get number of of regions
    numberOfObjects = size(objectProperties, 1);

    % remove objects that are not suitable plates (ratio, color)
    input_image = im2double(input_image);
    maxNumberOfWhitePixels  = 0;
    optimalObject = 0;

    % if only one object is found take it
    if numberOfObjects == 1
        optimalObject = objectProperties(1);
    else
        for i = 1:numberOfObjects
            boundedImage = imcrop(input_image, objectProperties(i).BoundingBox);
            height = size(boundedImage,1);
            width = size(boundedImage,2);
            aspectRatio = width / height;
            
            % if aspect ratio is not good, don't consider the object anymore
            if aspectRatio < 2 || aspectRatio > 7
                continue
            end

            boundedImage = rgb2lab(boundedImage);
            labWhite = [98 0 0];
            labBlue = [27 14 -50];
            L = boundedImage(:, :, 1);
            a = boundedImage(:, :, 2);
            b = boundedImage(:, :, 3);
            whiteIndices = sqrt((L - labWhite(1)).^2 + (a - labWhite(2)).^2 + (b - labWhite(3)).^2) <= 2.3;
            
            % pixels that are aprox. white
            whitePixels = boundedImage(whiteIndices);
            blueIndices = sqrt((L - labBlue(1)).^2 + (a - labBlue(2)).^2 + (b - labBlue(3)).^2) <= 10;
            
            % pixels that are aprox. EU blue
            bluePixels = boundedImage(blueIndices);
            numberOfWhitePixels = size(whitePixels,1);
            numberOfBluePixels = size(bluePixels,1);
            
            % if number of pixels higher with this object, take it as optimalObject
            if (numberOfWhitePixels > maxNumberOfWhitePixels) && numberOfBluePixels > 0
                maxNumberOfWhitePixels  = numberOfWhitePixels;
                optimalObject = objectProperties(i);
            end
        end
    end

    if(~isstruct(optimalObject))
        % TODO not detected
        return
    end

    plate = imcrop(input_image, optimalObject.BoundingBox);
    plotImage(plate, app.axes_5);
    title("Detected plate area");
end

function plotImage(img, axes)
    figure;
    imshow(img);
    %imshow(img, 'InitialMagnification', 'fit', 'Parent', axes);
    axis image;
    axis tight;
end

function imageList = readInImages()
    folderPath = 'C:\Users\Gabriel\Desktop\Projects\MATLAB\plate_recognition\license_plate_recognition\dataset\6MP';
    imageFiles = dir(fullfile(folderPath, '*.jpg'));
    numImages = length(imageFiles);

    imageList = cell(1, numImages);
    for i = 1:numImages
        fullFilePath = fullfile(folderPath, imageFiles(i).name);
        imageList{i} = imread(fullFilePath);
    end
end
