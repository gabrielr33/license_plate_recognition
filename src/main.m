% main pipeline with all the other functions
function [] = main(input_image)
    
    detectLicensePlate(input_image);
end

function detectLicensePlate(input_image)
    app = app_GUI();

    %% =========================================
    %%      Step 1: License plate detection
    %% =========================================

    % reset all outputs
    cla(app.processed_image_axes);
    app.processed_image_axes.reset();
    cla(app.detected_plate_axes);
    app.output_step_text.Text = '';

    license_plate = license_plate_detection(input_image, app);    
    app.open_image_button.Enable = true;

    %% =========================================
    %%      Step 2: Character Segmentation
    %% =========================================

    

end
