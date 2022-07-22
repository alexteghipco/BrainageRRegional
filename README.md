# BrainageRRegional
Core brainageR scripts lightly edited to make predictions based on regional GM, WM, and CSF. Also edited so that if SPM preprocessing files already exist, the script does not re-run SPM--now you have more time to science! Additional edits include checking for compressed and expanded versions of the input file in the case that it does not exist, as well as automatic expansion of compressed .nii.gz files. These edited scripts may help you if you would like to make brain age predictions using the brainageR model, but also to force it to use only information within some brain region. For caveats see last paragraph.

## Installation:  
1) Please download brainageR first and follow installation instructions at: https://github.com/james-cole/brainageR

2) Replace the files brainageR and predict_new_data_gm_wm_csf.R in the ./brainageR/software directory with the files in this repository. 

3) Edit hard coded paths in the brainageR file based on your system: 
      brainageR_dir=/Users/alex/brainageR
      
      spm_dir=/Users/alex/Downloads/spm12/
      
      matlab_path=/Applications/MATLAB_R2021a.app/bin/matlab
      
      FSLDIR=/usr/local/fsl/
  
Misc. installation note: If you are having trouble installing brainageR and the error looks something like this "[[: not found", change code around if statements from "[[" to "[" and "==" to "=". For example, "if [[ "$OSTYPE" == "darwin"* ]]; then" becomes "if [ "$OSTYPE" = "darwin"* ]; then".

## To use:
The new brainageR file will behave like stock brainageR unless you pass along an optional input argument, "-m", followed by a filepath to a mask (see usage/help). If you pass along a mask, your new participant will be projected into "group" pca space on which the brainageR gaussian process regression model was trained, but using only relationships between voxels in the mask. 

## What does brainAgeR do and how to we accomplish making regional predictions?
What does this all mean?!

Well, the brainageR pipeline initially took an n x p matrix of n subjects and p voxels and compressed it into an n x c matrix of scores with c components using PCA. In other words, the component space was defined by looking at the covariance between participants' structural data, with each component representing an orthogonal whole brain pattern of gm, wm, and csf that each participant gets "scored" on. A guassian process model was then trained to look at the position of a subject in this c dimensional component space and make a prediction about their age, effectively exploting how subjects are "clustered" on these dimensions. The model was then tested on some external data. To predict the age of a new participant, the p x c matrix of rotated coefficients (from the PCA of training data) is used to project the participant into component space, creating a 1 x c vector of scores that is then passed onto the model to make the final age prediction. The coefficients contain information that tells us the "importance" of each voxel to each component, so they contain information about how brain areas organize the orthogonal dimensions that embed participants in component space. 

Here is a schematic of this pipeline. A new participant (1) is porojected into component space using coefficients or whole brain structural connectivity patterns defined in the group (2). The scores are like coordinates that group together participants. For example, some groups of participants score very highly on a certain whole brain structural pattern while others don't, reflecting the fact that this pattern is absent in some of them. The GPR model is trained to see where a participant is in this space to make a prediction about their age--e.g., if the particpant scores highly on pattern in PC1 but poorly on pattern in PC2, may be they are older?

<p align="center">
  <kbd><img width="640" height="360" src="https://i.imgur.com/v9jBkws.png"/></kbd>
</p>

If you pass along a mask to brainageRRegional, we constrain the input data and the projection matrix (i.e., coefficients) to only those voxels that are inside the mask. In other words, we position the new participant in component space (which is represented by whole brain structural patterns) using information only within some portion of the brain. We then pass the participants' position in this space to the gaussian process model, just as before, to get our brain age prediction. 

This would amount to altering our schematic from above like this (e.g., if we are interested in making a brain age prediction based on visual cortex). To make sure the figs display correctly in github, make sure you have clicked into the readme page and are not on the main page of the repository.

<p align="center">
  <kbd><img width="640" height="360" src="https://i.imgur.com/xqbQuTz.png"/></kbd>
</p>

Constraining the projection matrix allows us to interrogate which brain areas are important for predicting age with one important caveat--we are scoring participants on whole brain structural patterns using only some region of the brain. This is a bit like saying, "what would this participants' age prediction be if their whole-brain structral patterns looked like the patterns we see in this region?" As such, a fruitful approach may be to test the importance of a brain region by using the entire brain except that region to make an age predictions. Ideally, however, we would make regional predictions of age by defining the component space over the region we are interested in, and re-training our model on that space (or maybe training a model on the region without pca). 

Using the regional prediction approach (not whole brain minus region as suggested above), it seems that the right hemisphere is relatively more important for predicting age

<p align="center">
  <kbd><img width="1200" height="300" src="https://i.imgur.com/SvZ9e3z.png"/></kbd>
</p>

But most important appears to be left premotor/motor cortex and SFG

<p align="center">
  <kbd><img width="900" height="420" src="https://i.imgur.com/HfbSIj6.png"/></kbd>
</p>

Send me comments/questions at:
alex.teghipco@sc.edu
