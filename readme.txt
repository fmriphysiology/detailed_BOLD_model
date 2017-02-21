A tool for investigating systematic bias in BOLD based MRI methods: 
An implementation of the detailed BOLD signal model

The following code was developed using MATLAB R2014b during 2014 in order to investigate 
sources of systematic bias in calibrated BOLD functional MRI (fMRI) based mapping of the 
oxygen extraction fraction. However, this tool may be useful for improving our 
understanding of other BOLD based fMRI methods.

SIMBOLD - An implementation of the detailed BOLD signal model (Griffeth and Buxton, 2011)
SIMFIGS - Generate the figures contained in the upcoming paper "Sources of systematic bias
in calibrated BOLD based mapping of baseline oxygen extraction fraction" by Nicholas P. 
Blockley et al.

SIMBOLD takes parameter-value pairs for 22 physical or physiological parameters. The
detailed BOLD signal model, on which it is based, has the following main features;
	- consists of a volume weighted sum of 4 compartments
	- compartments are 1 extravascular and 3 intravascular (arterial, capillary, venous)
	- intravascular signals are modelled using the results of blood relaxometry
	- extravascular signals are modelled using the results of numerical simulations
The detailed BOLD signal model was modified in the following ways;
	- arterial CBV was given its own "Grubb constant" rather than being the remainder of
	  total CBV change once the capillary and venous CBV change is removed
	- venous oxygen saturation was modelled using a unified model for changes in CBF,
	  CMRO2, and PaO2, rather than as individual non-combinable components

SIMFIGS has only one argument, which is the number of physiological states to generate.
In the paper this value is set to 1000. SIMFIGS also gives useful examples of the syntax 
for using SIMBOLD.

References

Griffeth, V.E.M., Buxton, R.B., 2011. A theoretical framework for estimating cerebral 
oxygen metabolism changes using the calibrated-BOLD method: Modeling the effects of blood 
volume distribution, hematocrit, oxygen extraction fraction, and tissue signal properties 
on the BOLD signal. Neuroimage 58, 198–212. doi:10.1016/j.neuroimage.2011.05.077
