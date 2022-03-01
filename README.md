# BrainageRRegional
Core brainageR scripts lightly edited to make predictions based on regional GM, WM, and CSF. Also edited so that if SPM preprocessing files already exist, the script does not re-run SPM. These edited scripts may help you if you would like to make brain age predictions using the brainageR classifier, but also to force it to use only information within some region.

To use: 
1) Please download brainageR first and follow installation instructions at: https://github.com/james-cole/brainageR

2) Replace the files brainageR and predict_new_data_gm_wm_csf.R in the ./brainageR/software directory with the files in this repository. 

The new brainageR file will behave like stock brainageR unless you pass along an optional input argument, "-m", followed by a filepath to a mask (see usage/help). If you pass along a mask, your new participant will be projected into "group" pca space using only relationships between voxels in the mask. 

What does this mean? Well, the brainageR pipeline initially took an n x p matrix of n subjects and p voxels and compressed it into an n x c matrix with c principal components. The gaussian process model was then trained on the n x c matrix to make age predictions for each participant and then tested on some additional external data. For any new participants (i.e., external data), the p x c matrix of rotated coefficients (from training) is used to project new participants into component space, creating a 1 x c vector that is passed onto the regression model. The coefficients contain information that tells us the "importance" of each voxel to each component, so they contain information about which brain areas organize the  orthogonal dimensions that embed participants based on the "similarity" (or relationship, covariance, etc) of their structural data. If you pass along a mask to brainageR, we constrain the input data and the projection matrix only to those voxels in the mask. The interpretation of orthogonal dimensions remains the same, but the extent to which a new participant "scores" on each of the dimensions is constrained to a certain portion of the brain. Since the regression model has effectively learned how the scores on these orthogonal dimensions map onto brain age, using a mask is a way of understanding how brain areas contribute to components and their importance to whole-brain age predictions.

Alex Teghipco
alex.teghipco@sc.edu
