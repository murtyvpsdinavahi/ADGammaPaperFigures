This repository has the functions necessary to generate all the plots in described in the following paper:

Murty, D. V. P. S. et al. Stimulus-induced Gamma rhythms are weaker in human elderly with Mild Cognitive Impairment and Alzheimer’s Disease. medRxiv 2020.06.24.20139113 (2020) doi:10.1101/2020.06.24.20139113.


(you must have access to ADGammaProjectAnalysisDetails_bipolar.mat and ADGammaProjectAnalysisDetails_unipolar.mat for this to work)

Important: there are minor differences between layout in the medRxiv manuscript and the manuscript submitted for review. Hence the format of the codes (example: figure numbers/title) might differ but content remains same.
----------------------------------------------------------------------------------------

How to use:
Clone this repository and set it to path.

For running analysis for gamma rhythms, type in the MATLAB command window:

>>getGammaAnalysisForGoodSubjects

-----------------
Similarly, for SSVEP analysis, type:

>>getSSVEPAnalaysisForGoodSubjects

-----------------
For creating figures, type:

>>help createFigure