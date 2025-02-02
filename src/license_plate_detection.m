% Author: Gabriel Ratschiller

% STEP 1 of the license plate processing pipeline. Detects the license plate 
% in the given image and returns the cropped image of the license plate.

%input_image...Image to be processed
%app...Instance of the app that holds all GUI elements
%result...Image cropped to the size of the plate bounding box

function [result] = license_plate_detection(input_image, app)
    
    %% convert RGB-image to grayscale image
    gray_image = rgb2gray(input_image);
    plot_image(gray_image, app.processed_image_axes, 'converting to gray scale..', app);
    
    %% median filter to remove noise
    % set filter parameters
    sigma = [3 3];                % filter standard deviations
    filtered_image = medfilt2(gray_image, sigma);
    plot_image(filtered_image, app.processed_image_axes, 'median filtering..', app);
    
    %% adaptive histogram equalization to enhance contrast
    contr_image = adapthisteq(filtered_image);
    plot_image(contr_image, app.processed_image_axes, 'contrast enhancing..', app);
    
    %% image subtraction to enhance edges
    se = strel('disk', round(size(input_image, 2) * app.threshold_edit_field.Value));
    opened_image = imopen(contr_image, se);
    plot_image(opened_image, app.processed_image_axes, 'opening..', app);
    
    subt_image = imsubtract(contr_image, opened_image);
    plot_image(subt_image, app.processed_image_axes, 'subtracting..', app);
    
    %% filter edges with the sobel filter
    edge_image = edge(subt_image);
    plot_image(edge_image, app.processed_image_axes, 'edge filtering..', app);
    
    %% remove all edges that have fewer than 8 pixels
    rem_image = bwareaopen(edge_image, 8);
    plot_image(rem_image, app.processed_image_axes, 'removing small edges..', app);
    
    %% apply math. morphologies (dilate and erode) to fill spaces
    % dilation: create a structuring element
    se = strel('diamond', 3);
    dil_image = imdilate(edge_image, se);
    plot_image(dil_image, app.processed_image_axes, 'dilating..', app);
    
    %% fill holes
    fill_image = imfill(dil_image, 4, "holes");
    plot_image(fill_image, app.processed_image_axes, 'filling holes..', app);
    
    %% remove all objects touching the border
    clear_image = imclearborder(fill_image);
    plot_image(clear_image, app.processed_image_axes, 'removing objects touching the border..', app);
    
    %% erode image with a diamond- and line-structuring-element
    se = strel('diamond', 5);
    erode_image_2 = imerode(clear_image, se);
    plot_image(erode_image_2, app.processed_image_axes, 'eroding..', app);
    
    se = strel('line', 5, 5);
    erode_image_3 = imerode(erode_image_2, se);
    plot_image(erode_image_3, app.processed_image_axes, 'eroding..', app);
    
    %% remove all objects touching the border
    clear_image_2 = imclearborder(erode_image_3);
    plot_image(clear_image_2, app.processed_image_axes, 'removing objects touching the border..', app);
    
    %% get the image size to approximate the minimum and maximum area of the plate
    imageArea = size(input_image, 1) * size(input_image, 2);
    minPlateArea = int32(imageArea * 0.01);    % minimum area of plate is 0.2% of picture
    maxPlateArea = int32(imageArea * 0.3);     % maximum area of plate is 30% of picture
    rangePlateArea = [minPlateArea, maxPlateArea];
    
    %% remove small objects from the image
    small_rem_image = bwareaopen(clear_image_2, 50);
    small_rem_image = imclearborder(small_rem_image);
    small_rem_image = bwareaopen(small_rem_image, double(rangePlateArea(1)));
    plot_image(small_rem_image, app.processed_image_axes, 'removing small objects..', app);
    
    %% connected-components labeling
    cc_image = CCL(small_rem_image, rangePlateArea);
    
    %% remove large objects from the image
    plate_image = cc_image - bwareaopen(cc_image, 500000);
    plot_image(plate_image, app.processed_image_axes, 'removing large objects..', app);
    
    %% get the final image cropped to the size of the bounding box of the detected license plate
    plate = bounding_box_plate(input_image, plate_image);
    
    if (isempty(plate))
        app.output_step_text.Text = 'plate could not be found!';
        app.open_image_button.Enable = true;
        result = [];
        return;
    end
    
    plot_image(plate, app.detected_plate_axes, '', app);
    result = plate;
end
