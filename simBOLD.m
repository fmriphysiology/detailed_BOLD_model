function dS=simBOLD(input1,varargin)
%SIMBOLD Generate simulated BOLD response based on input physiological baseline/changes
%	DS=SIMBOLD('PhysiologicalVar',PhysiologicalValue) returns the BOLD signal change
%	for a given physiological state given values for the specified physiological variables
%
%	SIMBOLD is based on the detailed BOLD signal model as used in (Griffeth and Buxton, 2011)
%	Please quote this reference if you use this simulation code (see References below)
%
%	See also SIMFIGS

if nargin<2
	input1='E0';
	varargin={0.4};
end

%-----------------------------------------------------------------------------------------
%physical and physiological parameters and their default values
%-----------------------------------------------------------------------------------------

p=inputParser;

%haemodynamic parameters
p.addParamValue('alphav',0.2,@isnumeric); %exponent relating blood flow to venous blood volume  (Chen and Pike, 2010)
p.addParamValue('alphaa',0.84,@isnumeric); %exponent relating blood flow to arterial blood volume (Lee et al., 2001)

p.addParamValue('f',1,@isnumeric); %normalised change in blood flow
p.addParamValue('r',1,@isnumeric); %normalised change in oxygen metabolism

p.addParamValue('Vi',0.05,@isnumeric); %resting total blood volume (Roland et al., 1987) 
p.addParamValue('omegaA',0.2,@isnumeric); %arterial blood volume fraction (Weber et al., 2008)
p.addParamValue('omegaV',0.4,@isnumeric); %venous blood volume fraction (Weber et al., 2008)

%blood oxygenation parameters
p.addParamValue('E0',0.4,@isnumeric); %resting oxygen extraction fraction (Marchal et al., 1992)
p.addParamValue('Hct',0.44,@isnumeric); %systemic haematocrit (McPhee and Hammer, 2009)

p.addParamValue('PaO20',110,@isnumeric); %resting arterial partial pressure of oxygen
p.addParamValue('PaO2',110,@isnumeric); %active arterial partial pressure of oxygen

p.addParamValue('SO2off',0.95,@isnumeric); %saturation of blood for equal tissue-blood susceptibility (Spees et al., 2001)

p.addParamValue('w',0.4,@isnumeric); %fraction of capillary blood considered to be “arterial” (Tsai et al., 2003)

%experimental parameters
p.addParamValue('TE',35e-3,@isnumeric); %echo time
p.addParamValue('R2sE',25.1,@isnumeric); %tissue R2* value (Perthen et al., 2008)

%physical parameters
p.addParamValue('Si0',1.15,@isnumeric); %intravascular to extravascular spin density ratio determined experimentally (Griffeth and Buxton, 2011)

%model simplification - value of 1 is default, all signal included
p.addParamValue('Ia',1,@isnumeric); 
p.addParamValue('Ic',1,@isnumeric); 
p.addParamValue('Iv',1,@isnumeric);
p.addParamValue('Ea',1,@isnumeric); 
p.addParamValue('Ec',1,@isnumeric); 
p.addParamValue('Ev',1,@isnumeric);  

%parse inputs
p.parse(input1,varargin{:});

r=p.Results;

%additional constants
gamma=2*pi*42.6*1e6; %gyromagnetic ratio
B0=3; %main magnetic field
deltaChi=0.264e-6; %susceptibility of blood with fully deoxygenated blood (Spees et al., 2001)

%-----------------------------------------------------------------------------------------
%calculations of dependent parameters
%-----------------------------------------------------------------------------------------

%haemodynamic parameters
omegaC=1-r.omegaA-r.omegaV; %capillary blood volume fraction
alphac=r.alphav/2; %exponent relating CBF to capillary blood volume (Stefanovic et al., 2008)

Va0 = r.Vi*r.omegaA; %resting arterial blood volume
Vc0 = r.Vi*omegaC; %resting capillary blood volume
Vv0 = r.Vi*r.omegaV; %resting venous blood volume

Va=Va0.*r.f.^r.alphaa; %active arterial blood volume
Vv=Vv0.*r.f.^r.alphav; %active capillary blood volume
Vc=Vc0.*r.f.^alphac; %active venous blood volume

%blood oxygenation parameters
HctC = r.Hct*0.759; %capillary haematocrit (Sakai et al., 1985)

SaO20=1/((23400/(r.PaO20^3+150*r.PaO20))+1); %resting arterial oxygen saturation
SaO2=1/((23400/(r.PaO2^3+150*r.PaO2))+1); %active arterial oxygen saturation

phi=1.34;
epsilon=0.0031;
Hb=100*r.Hct/3;

CaO20=phi*Hb*SaO20+r.PaO20*epsilon; %resting arterial oxygen content
CaO2=phi*Hb*SaO2+r.PaO2*epsilon; %active arterial oxygen content

CmetO20=CaO20*r.E0; %resting metabolised oxygen content
CmetO2=CaO20*r.E0*r.r/r.f; %active metabolised oxygen content

PvO20=calcPvO2(CaO20-CmetO20,Hb); %resting venous partial pressure of oxygen
PvO2=calcPvO2(CaO2-CmetO2,Hb); %active venous partial pressure of oxygen

SvO20=1/((23400/(PvO20^3+150*PvO20))+1); %resting venous oxygen saturation
SvO2=1/((23400/(PvO2^3+150*PvO2))+1); %active venous oxygen saturation

ScO20=r.w*SaO20+(1-r.w)*SvO2; %resting capillary oxygen saturation
ScO2=r.w*SaO2+(1-r.w)*SvO2; %active capillary oxygen saturation

%physical parameters

%empirical large vessel intravascular R2* model (Zhao et al., 2007)
As=14.87*r.Hct+14.686;
Cs=302.06*r.Hct+41.83;

%empirical capillary intravascular R2* model (Zhao et al., 2007)
AsC=14.87*HctC+14.686;
CsC=302.06*HctC+41.83;

%-----------------------------------------------------------------------------------------
%detailed BOLD signal model
%-----------------------------------------------------------------------------------------

%intravascular components c.f. (Zhao et al., 2007)
deltaR2sA=Cs*((1-SaO2).^2-(1-SaO20).^2); %arterial intravascular R2* change 
deltaR2sC=CsC*((1-ScO2).^2-(1-ScO20).^2); %capillary intravascular R2* change
deltaR2sV=Cs*((1-SvO2).^1-(1-SvO20).^1); %venous intravascular R2* change

%extravascular R2* c.f. (Ogawa et al., 1993)
deltaR2sEA=4.3*(deltaChi*r.Hct*gamma*B0)*(Va.*abs(r.SO2off-SaO2)-Va0.*abs(r.SO2off-SaO20)); %arterial extravascular R2* change
deltaR2sEC=0.04*(deltaChi*HctC*gamma*B0)^2*((r.SO2off-ScO2).^2.*Vc-(r.SO2off-ScO20).^2.*Vc0); %capillary extravascular R2* change
deltaR2sEV=4.3*(deltaChi*r.Hct*gamma*B0)*(Vv.*abs(r.SO2off-SvO2)-Vv0.*abs(r.SO2off-SvO20)); %venous extravascular R2* change

deltaR2sE=r.Ea.*deltaR2sEA+r.Ec.*deltaR2sEC+r.Ev.*deltaR2sEV; %total extravascular R2* change

%calculations of resting intravascular R2* (Zhao et al., 2007)
R2sA=As+Cs*(1-SaO20).^2; %arterial intravascular resting R2* 
R2sC=AsC+CsC*(1-ScO20).^2; %capillary intravascular resting R2*
R2sV=As+Cs*(1-SvO20).^2; %venous intravascular resting R2*

%determining the intrinsic intravascular/extravascular signal ratio (Griffeth and Buxton, 2011)
Epsa=(r.Si0*exp(-r.TE*R2sA))/exp(-r.TE*r.R2sE); % ratio of intrinsic arterial signal to extracellular signal
Epsc=(r.Si0*exp(-r.TE*R2sC))/exp(-r.TE*r.R2sE); % ratio of intrinsic capillary signal to extracellular signal
Epsv=(r.Si0*exp(-r.TE*R2sV))/exp(-r.TE*r.R2sE); % ratio of intrinsic venous signal to extracellular signal

%-----------------------------------------------------------------------------------------
%BOLD output (Griffeth and Buxton, 2011)
%-----------------------------------------------------------------------------------------
Hs = 1./((1-r.Ea.*Va0-r.Ea.*Vc0-r.Ea.*Vv0)+r.Ia.*Epsa.*Va0+r.Ic.*Epsc.*Vc0+r.Iv.*Epsv.*Vv0);
dS = Hs.*((1-r.Ea.*Va-r.Ea.*Vc-r.Ea.*Vv).*exp(-r.TE*deltaR2sE)+...
    r.Ia.*Epsa.*Va.*exp(-r.TE*deltaR2sA)+r.Ic.*Epsc.*Vc.*exp(-r.TE*deltaR2sC)+...
    r.Iv.*Epsv.*Vv.*exp(-r.TE*deltaR2sV))-1;

%-----------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------

function PvO2=calcPvO2(CvO2,Hb)
%return venous partial pressure of oxygen (PvO2) based on input of venous oxygen content
%and haemoglobin concentration

if CvO2==0
	PvO2=0;
	return;
end

phi=1.34;
epsilon=0.0031;

a=phi*Hb;
b=epsilon;
A=b;
CvO2temp=CvO2;
B=a-CvO2temp;
C=150*b;
D=150*a+23400*b-150*CvO2temp;
E=-23400*CvO2temp;

rts=roots([A B C D E]);
PvO2=rts((rts>0) & (imag(rts)==0));

if isempty(PvO2)
	PvO2=0;
end

return


%{
References 

Chen, J.J., Pike, G.B., 2010. MRI measurement of the BOLD-specific flow–volume relationship during hypercapnia and hypocapnia in humans. Neuroimage 53, 383–391. doi:10.1016/j.neuroimage.2010.07.003
Griffeth, V.E.M., Buxton, R.B., 2011. A theoretical framework for estimating cerebral oxygen metabolism changes using the calibrated-BOLD method: Modeling the effects of blood volume distribution, hematocrit, oxygen extraction fraction, and tissue signal properties on the BOLD signal. Neuroimage 58, 198–212. doi:10.1016/j.neuroimage.2011.05.077
Lee, S.P., Duong, T.Q., Yang, G., Iadecola, C., Kim, S.-G., 2001. Relative changes of cerebral arterial and venous blood volumes during increased cerebral blood flow: implications for BOLD fMRI. Magn. Reson. Med. 45, 791–800.
Marchal, G., Rioux, P., Petit-Taboué, M.C., Sette, G., Travère, J.M., Le Poec, C., Courtheoux, P., Derlon, J.M., Baron, J.C., 1992. Regional cerebral oxygen consumption, blood flow, and blood volume in healthy human aging. Arch. Neurol. 49, 1013–1020.
McPhee, S.J., Hammer, G.D., 2009. Pathophysiology of Disease An Introduction to Clinical Medicine, Sixth Edition (Lange Medical Books), 6 ed. McGraw-Hill Medical.
Ogawa, S., Menon, R.S., Tank, D.W., Kim, S.-G., Merkle, H., Ellermann, J.M., Ugurbil, K., 1993. Functional brain mapping by blood oxygenation level-dependent contrast magnetic resonance imaging. A comparison of signal characteristics with a biophysical model. Biophys. J. 64, 803–812. doi:10.1016/S0006-3495(93)81441-3
Perthen, J.E., Lansing, A.E., Liau, J., Liu, T.T., Buxton, R.B., 2008. Caffeine-induced uncoupling of cerebral blood flow and oxygen metabolism: a calibrated BOLD fMRI study. Neuroimage 40, 237–247. doi:10.1016/j.neuroimage.2007.10.049
Roland, P.E., Eriksson, L., Stone-Elander, S., Widen, L., 1987. Does mental activity change the oxidative metabolism of the brain? J. Neurosci. 7, 2373–2389.
Sakai, F., Nakazawa, K., Tazaki, Y., Ishii, K., Hino, H., Igarashi, H., Kanda, T., 1985. Regional cerebral blood volume and hematocrit measured in normal human volunteers by single-photon emission computed tomography. Journal of Cerebral Blood Flow & Metabolism 5, 207–213. doi:10.1038/jcbfm.1985.27
Spees, W.M., Yablonskiy, D.A., Oswood, M.C., Ackerman, J.J., 2001. Water proton MR properties of human blood at 1.5 Tesla: magnetic susceptibility, T1, T2, T2*, and non-Lorentzian signal behavior. Magn. Reson. Med. 45, 533–542.
Stefanovic, B., Hutchinson, E., Yakovleva, V., Schram, V., Russell, J.T., Belluscio, L., Koretsky, A.P., Silva, A.C., 2008. Functional reactivity of cerebral capillaries. Journal of Cerebral Blood Flow & Metabolism 28, 961–972. doi:10.1038/sj.jcbfm.9600590
Tsai, A.G., Johnson, P.C., Intaglietta, M., 2003. Oxygen gradients in the microcirculation. Physiol. Rev. 83, 933–963. doi:10.1152/physrev.00034.2002
Weber, B., Keller, A.L., Reichold, J., Logothetis, N.K., 2008. The microvascular system of the striate and extrastriate visual cortex of the macaque. Cerebral Cortex 18, 2318–2330. doi:10.1093/cercor/bhm259
Zhao, J.M., Clingman, C.S., Närväinen, M.J., Kauppinen, R.A., van Zijl, P.C.M., 2007. Oxygenation and hematocrit dependence of transverse relaxation rates of blood at 3T. Magn. Reson. Med. 58, 592–597. doi:10.1002/mrm.21342

%}