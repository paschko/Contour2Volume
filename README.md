# Countour2Volume
A MATLAB app to manually select contours (i.e. ROIs) in slices of Thorlabs OCT data and build a 3D volume out of these.


## Requirements
- [Multi ROI/Mask Editor Class](https://de.mathworks.com/matlabcentral/fileexchange/31388-multi-roi-mask-editor-class) in your MATLAB path.
- Has been tested solely on MATLAB R2017b

## How to Use
Call `Contour2Volume` from your MATLAB Command Window or open the `Contour2Volume.mlapp`.
Use `File > Open .oct (3D)...` to load a 3D volume created with a Thorlabs OCT machine. Depending on file size, this can take some time.
By clicking **Rotate Volume** you can switch between planes. Use the slider or spinner to go through the slices.
Add a contour for a slice by clicking **Draw Sample**. When having added >3 contour samples, you can preview the volume by clicking the corresponding button.
**Export to Workspace** will assign a multitude of variables regarding your current sample and volume to your MATLAB workspace.
