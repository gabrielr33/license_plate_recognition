% Author: Gabriel Ratschiller

% Plots the specified image on the specified axes and writes the specified 
% text in the output line.

%image...Image to be processed
%axes...Axes for plotting the image
%step_text...Text that should be displayed in the out put line
%app...Instance of the app that holds all GUI elements

function plot_image(image, axes, step_text, app)
    pause(0.5);
    imshow(image, 'InitialMagnification', 'fit', 'Parent', axes);
    app.output_step_text.Text = step_text;
    axis image;
    axis tight;
end
