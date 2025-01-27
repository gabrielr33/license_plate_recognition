% main pipeline with all the other functions
function [] = main(input_image)
    
    app = app_GUI();

    %% 1. convert RGB-image to grayscale image
    % check if the input is a valid RGB image (3 channels)
    if size(input_image, 3) ~= 3
        error('Input image must be RGB (3 channels).');
    end

    gray_image = rgb2gray(input_image);
    plotImage(gray_image, app.axes_2);

    %% 2. median filter to remove noise
    % set filter parameters
    sigma = [3 3];                % filter standard deviations
    filtered_image = medfilt2(gray_image, sigma);
    plotImage(filtered_image, app.axes_3);
    
    %% 3. adaptive histogram equalization to enhance contrast
    contrasted_image = adapthisteq(filtered_image);
    plotImage(contrasted_image, app.axes_4);

end



function plotImage(img, axes)
    figure;
    imshow(img);
    %imshow(img, 'InitialMagnification', 'fit', 'Parent', axes);
    axis image;
    axis tight;
end