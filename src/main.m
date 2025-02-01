% main pipeline with all the other functions
function [] = main(input_image)
    
    detectLicensePlate(input_image);
end

function detectLicensePlate(input_image)
    app = app_GUI();

    %% reset all outputs
    cla(app.processed_image_axes);
    app.processed_image_axes.reset();
    cla(app.detected_plate_axes);
    app.output_step_text.Text = '';

    %% convert RGB-image to grayscale image
    gray_image = rgb2gray(input_image);
    plotImage(gray_image, app.processed_image_axes, 'converting to gray scale..', app);

    %% median filter to remove noise
    % set filter parameters
    sigma = [3 3];                % filter standard deviations
    filtered_image = medfilt2(gray_image, sigma);
    plotImage(filtered_image, app.processed_image_axes, 'median filtering..', app);
    
    %% adaptive histogram equalization to enhance contrast
    contr_image = adapthisteq(filtered_image);
    plotImage(contr_image, app.processed_image_axes, 'contrast enhancing..', app);

    %% image subtraction to enhance edges
    se = strel('disk', round(size(input_image, 2) * 0.025));
    opened_image = imopen(contr_image, se);
    plotImage(opened_image, app.processed_image_axes, 'opening..', app);

    subt_image = imsubtract(contr_image, opened_image);
    plotImage(subt_image, app.processed_image_axes, 'subtracting..', app);

    %% filter edges with the sobel filter
    edge_image = edge(subt_image);
    plotImage(edge_image, app.processed_image_axes, 'edge filtering..', app);

    %% remove all edges that have fewer than 8 pixels
    rem_image = bwareaopen(edge_image, 8);
    plotImage(rem_image, app.processed_image_axes, 'removing small edges..', app);

    %% apply math. morphologies (dilate and erode) to fill spaces
    % dilation: create a structuring element
    se = strel('diamond', 3);
    dil_image = imdilate(edge_image, se);
    plotImage(dil_image, app.processed_image_axes, 'dilating..', app);

    %% fill holes
    fill_image = imfill(dil_image, 4, "holes");
    plotImage(fill_image, app.processed_image_axes, 'filling holes..', app);

    %% remove all objects touching the border
    clear_image = imclearborder(fill_image);
    plotImage(clear_image, app.processed_image_axes, 'removing objects touching the border..', app);

    %% erode image with a diamond- and line-structuring-element
    se = strel('diamond', 5);
    erode_image_2 = imerode(clear_image, se);
    plotImage(erode_image_2, app.processed_image_axes, 'eroding..', app);

    se = strel('line', 5, 5);
    erode_image_3 = imerode(erode_image_2, se);
    plotImage(erode_image_3, app.processed_image_axes, 'eroding..', app);

    %% remove all objects touching the border
    clear_image_2 = imclearborder(erode_image_3);
    plotImage(clear_image_2, app.processed_image_axes, 'removing objects touching the border..', app);

    %% get the image size to approximate the minimum and maximum area of the plate
    imageArea = size(input_image, 1) * size(input_image, 2);
    minPlateArea = int32(imageArea * 0.01);    % minimum area of plate is 0.2% of picture
    maxPlateArea = int32(imageArea * 0.3);     % maximum area of plate is 30% of picture
    rangePlateArea = [minPlateArea, maxPlateArea];

    %% remove small objects from the image
    small_rem_image = bwareaopen(clear_image_2, 50);
    small_rem_image = imclearborder(small_rem_image);
    small_rem_image = bwareaopen(small_rem_image, double(rangePlateArea(1)));
    plotImage(small_rem_image, app.processed_image_axes, 'removing small objects..', app);

    %% connected-components labeling
    cc_image = CCL(small_rem_image, rangePlateArea);

    %% remove large objects from the image
    plate_image = cc_image - bwareaopen(cc_image, 500000);
    plotImage(plate_image, app.processed_image_axes, 'removing large objects..', app);

    plate = BoundingBoxPlate(input_image, plate_image);
    plotImage(plate, app.detected_plate_axes, '', app);
    app.open_image_button.Enable = true;
end

function plotImage(img, axes, step_text, app)
    pause(0.5);
    imshow(img, 'InitialMagnification', 'fit', 'Parent', axes);
    app.output_step_text.Text = step_text;
    axis image;
    axis tight;
end
