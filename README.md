# License Plate Recognition

Computer vision application that detects and recognizes license plate numbers in RGB car images.

## Table of contents

* [General Info](#general-info)
* [Image Processing Pipeline](#image-processing-pipeline)
* [User Interface](#user-interface)
* [Results](#results)
* [Setup](#setup)
* [Sources](#sources)

## General Info

This repository contains a MATLAB implementation for automatic license plate recognition. It utilizes image processing techniques to locate, segment, and recognize characters from license plates in RGB images.
The application takes an RGB image of a car as input and outputs the recognised letters of the license plate as well as the federal state if it is an Austrian license plate.

## Image Processing Pipeline
* **License Plate Detection**
	- **Median Filtering** (to remove noise)
	- **Adaptive Histogram** Equalization** (to enhance contrast)
	- **Image Subtraction** (to enhance edges)
	- **Sobel filtering** (to detect edges)
	- **Mathematical Morphologies** (Dilate and Erode, to close gaps in lines)
	- **Floodfill** (to fill holes)
	- **Connected Component Labeling** (to determine the final position of the license plate)
	
* **Character Segmentation**
    - **Image Pyramid Reduction** (to reduce the size of the image)
	- **Template Matching** (to match the characters to the tempalates using a correlation coefficient)
	
## User Interface

<p float = "left">
    <img src = "gui.png">	
</p>

- Open Image: loads the image from the dataset folder
- Threshold: how aggresive the image is opened to detect edges (range = [0.001, 0.1], default = 0.025)
- Run detection: start the license plate recognition pipeline

- Input Image: shows the loaded input image
- Processed Image: shows the current step of the processing pipeline
- Detected plate: image of the detected plate

## Results

todo

## Setup

todo

## Sources

* Kaur, S., & Kaur, S. (2014). An efficient approach for number plate extraction from vehicles image under image processing. International Journal of Computer Science and Information Technologies.
* Kukreja, A., Bhandari, S., Bhatkar, S., Chavda, J., & Lad, S. (2017). Indian vehicle number plate detection using image processing. Int Res J Eng Technol (IRJET).
* Bhat, R., & Mehandia, B. (2014). Recognition of vehicle number plate using matlab. International journal of innovative research in electrical, electronics, instrumentation and control engineering.
