% author: Gabriel Ratschiller

% input     image to be filtered
% result    convoluted output image 
function [result] = sobel_conv(input)

input_double = double(input);

% 3x3 Sobel filter kernel
kern_x = [-1,  0,  1;   -2, 0, 2;   -1, 0, 1];
kern_y = [-1, -2, -1;    0, 0, 0;    1, 2, 1];

