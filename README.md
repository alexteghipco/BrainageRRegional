# BrainageRRegional
Core brainageR scripts lightly edited to make predictions based on regional GM, WM, and CSF. Also edited so that if SPM preprocessing files already exist, the script does not re-run SPM--now you have more time to science! Additional edits include checking for compressed and expanded versions of the input file in the case that it does not exist, as well as automatic expansion of compressed .nii.gz files. These edited scripts may help you if you would like to make brain age predictions using the brainageR model, but also to force it to use only information within some brain region. For caveats see last paragraph.

To use: 
1) Please download brainageR first and follow installation instructions at: https://github.com/james-cole/brainageR

2) Replace the files brainageR and predict_new_data_gm_wm_csf.R in the ./brainageR/software directory with the files in this repository. 

3) Edit hard coded paths in the brainageR file based on your system: 
      brainageR_dir=/Users/alex/brainageR
      
      spm_dir=/Users/alex/Downloads/spm12/
      
      matlab_path=/Applications/MATLAB_R2021a.app/bin/matlab
      
      FSLDIR=/usr/local/fsl/
  
Misc. installation note: If you are having trouble installing brainageR and the error looks something like this "[[: not found", change code around if statements from "[[" to "[" and "==" to "=". For example, "if [[ "$OSTYPE" == "darwin"* ]]; then" becomes "if [ "$OSTYPE" = "darwin"* ]; then".

The new brainageR file will behave like stock brainageR unless you pass along an optional input argument, "-m", followed by a filepath to a mask (see usage/help). If you pass along a mask, your new participant will be projected into "group" pca space on which the brainageR gaussian process regression model was trained, but using only relationships between voxels in the mask. 

What does this all mean? Well, the brainageR pipeline initially took an n x p matrix of n subjects and p voxels and compressed it into an n x c matrix of  scores with c components using PCA. In other words, the component space was defined by looking at the covariance between participants' structural data, with each component representing an orthogonal whole brain pattern of gm, wm, and csf that each participant gets "scored" on. A guassian process model was then trained to look at the position of a subject in this c dimensional component space and make a prediction about their age, effectively exploting how subjects are "clustered" on these dimensions. The model was then tested on some external data. To predict the age of a new participant, the p x c matrix of rotated coefficients (from the PCA of training data) is used to project the participant into component space, creating a 1 x c vector of scores that is then passed onto the model to make the final age prediction. The coefficients contain information that tells us the "importance" of each voxel to each component, so they contain information about how brain areas organize the orthogonal dimensions that embed participants in component space. If you pass along a mask to brainageRRegional, we constrain the input data and the projection matrix (i.e., coefficients) to only those voxels that are inside the mask. In other words, we position the new participant in component space (which is represented by whole brain structural patterns) using information only within some portion of the brain. We then pass the participants' position in this space to the gaussian process model,just as before, to get our brain age prediction. Constraining the projection matrix allows us to interrogate which brain areas are important for predicting age with one important caveat--we are scoring participants on whole brain structural patterns using only some region of the brain. This is a bit like saying, "what would this participants' age prediction be if their whole-brain structral patterns looked like the patterns we see in this region?" As such, a fruitful approach may be to test the importance of a brain region to brain age predictions by using the entire brain except that region to make predictions. Ideally, we would make regional predictions of age by defining the component space over the region we are interested in, and re-training our model on that space (or get rid of dimensionality reduction/pca entirely and use feature selection instead). 

Send me comments/questions at:
alex.teghipco@sc.edu
