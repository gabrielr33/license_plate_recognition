% main pipeline with all the other functions
function [] = main(input_image)
    
    detectLicensePlate(input_image);
end

function detectLicensePlate(input_image)
    app = app_GUI();

    % reset all outputs
    cla(app.processed_image_axes);
    app.processed_image_axes.reset();
    cla(app.detected_plate_axes);
    app.output_step_text.Text = '';

    %% =========================================
    %%      Step 1: License plate detection
    %% =========================================

    license_plate = license_plate_detection(input_image, app);

    if (isempty(license_plate))
        return;
    end

    %% =========================================
    %%      Step 2: Character Segmentation
    %% =========================================

    resultText = character_segmentation(license_plate, app);

    % write characters to output text
    app.output_step_text.Text = resultText;
    app.open_image_button.Enable = true;
end
