% main pipeline with all the other functions
function [] = main(input_image)
    
    % 1. Convert RGB-image to grayscale image
    image_grey(:, :, 1) = 0.114 .* input_image(:, :, 1) + 0.587 .* input_image(:, :, 2) + 0.299 .* input_image(:, :, 3);
    imshow(image_grey, 'Parent', axes);

end