function simFigs(l);
%SIMFIGS Generate data and figures for upcoming paper
%	SIMFIGS(L) produces figures with L randomly generated physiological conditions
%
%	SIMFIGS can be used to generate the figures contained in the upcoming paper "Sources 
%	of systematic bias in calibrated BOLD based mapping of baseline oxygen extraction 
%	fraction" by Nicholas P. Blockley et al.
%
%	See also SIMBOLD

close all;
if nargin<1
	l=1000;
end

rng('default'); %reset the random number generator to default 

%-----------------------------------------------------------------------------------------
%define ranges of physiological parameters
%-----------------------------------------------------------------------------------------

%normal variability
E0=[0 1];[0.35 0.55]; %marchall1992 (fig2) 
Hct=[0.37 0.50]; %const value 0.44  
Vi=[0.01 0.1]; %const value 0.05
omegaA=[0.1 0.3];
omegaV=[0.3 0.5]; %const value 0.4
alphav=[0.1 0.3];[0.2 0.2];[0.15 0.25]; %const value 0.2
fhc=[1.4 1.6];
PaO20=[100 120];[110 110];
PaO2=[400 460];[310 310]; %const value 310

%changes in CMRO2 during HC
rhc=0.85;

%changes in CBF during HO
fho=0.95;

%hypoxic hypoxia
PaO20_hypoxia=[45 55];[100 120];
PaO2_hypoxia=[350 410];[310 310]; %const value 310

%anaemic hypoxia
Hct_anaemia=[0.13 0.37]; %const value 0.44  

%-----------------------------------------------------------------------------------------
%generate random physiological conditions
%-----------------------------------------------------------------------------------------

%normal variability
E0r=rand(l,1).*diff(E0)+repmat(E0(1),l,1);
Hctr=rand(l,1).*diff(Hct)+repmat(Hct(1),l,1);
Vir=rand(l,1).*diff(Vi)+repmat(Vi(1),l,1);
omegaAr=rand(l,1).*diff(omegaA)+repmat(omegaA(1),l,1);
omegaVr=rand(l,1).*diff(omegaV)+repmat(omegaV(1),l,1);
alphavr=rand(l,1).*diff(alphav)+repmat(alphav(1),l,1);
fhcr=rand(l,1).*diff(fhc)+repmat(fhc(1),l,1);
PaO20r=rand(l,1).*diff(PaO20)+repmat(PaO20(1),l,1);
PaO2r=rand(l,1).*diff(PaO2)+repmat(PaO2(1),l,1);

%hypoxic hypoxia
PaO20_hypoxiar=rand(l,1).*diff(PaO20_hypoxia)+repmat(PaO20_hypoxia(1),l,1);
PaO2_hypoxiar=rand(l,1).*diff(PaO2_hypoxia)+repmat(PaO2_hypoxia(1),l,1);

%anaemic hypoxia
Hct_anaemiar=rand(l,1).*diff(Hct)+repmat(Hct(1),l,1);

%-----------------------------------------------------------------------------------------
%generate BOLD responses to typical respiratory challenges
%-----------------------------------------------------------------------------------------

fprintf(1,'percent progress:  0');

for j=1:l

	%hypercapnia BOLD responses
	
	%normal variability
	dShc(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',fhcr(j),'PaO20',PaO20r(j),'PaO2',PaO20r(j),'r',1);
	
	%investigating the discontinuity in E0
	dShc_disc100(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1.5,'PaO20',110,'PaO2',110,'r',1,'SO2off',1);
	dShc_disc95(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1.5,'PaO20',110,'PaO2',110,'r',1,'SO2off',0.95);
	dShc_disc90(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1.5,'PaO20',110,'PaO2',110,'r',1,'SO2off',0.9);
	
	%changes in CMRO2 during HC
	dShc_metab(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',fhcr(j),'PaO20',PaO20r(j),'PaO2',PaO20r(j),'r',rhc);
	
	%hypoxic hypoxia
	dShc_hypoxia(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',fhcr(j),'PaO20',PaO20_hypoxiar(j),'PaO2',PaO20_hypoxiar(j),'r',1);
	
	%anaemic hypoxia
	dShc_anaemia(j,:)=simBOLD('E0',E0r(j),'Hct',Hct_anaemiar(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',fhcr(j),'PaO20',PaO20r(j),'PaO2',PaO20r(j),'r',1);

	%hyperoxia BOLD responses
	
	%normal variability
	dSho(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',1,'PaO20',PaO20r(j),'PaO2',PaO2r(j),'r',1);
	
	%investigating the discontinuity in E0
	dSho_disc100(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1,'PaO20',110,'PaO2',420,'r',1,'SO2off',1);
	dSho_disc95(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1,'PaO20',110,'PaO2',420,'r',1,'SO2off',0.95);
	dSho_disc90(j,:)=simBOLD('E0',j/l,'Hct',0.44,'Vi',0.05,'omegaA',0.2,'omegaV',0.4,'alphav',0.2,'f',1,'PaO20',110,'PaO2',420,'r',1,'SO2off',0.9);	
	
	%changes in CBF during HO
	dSho_flow(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',fho,'PaO20',PaO20r(j),'PaO2',PaO2r(j),'r',1);
	
	%hypoxic hypoxia
	dSho_hypoxia(j,:)=simBOLD('E0',E0r(j),'Hct',Hctr(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',1,'PaO20',PaO20_hypoxiar(j),'PaO2',PaO2_hypoxiar(j),'r',1);
	
	%anaemic hypoxia
	dSho_anaemia(j,:)=simBOLD('E0',E0r(j),'Hct',Hct_anaemiar(j),'Vi',Vir(j),'omegaA',omegaAr(j),'omegaV',omegaVr(j),'alphav',alphavr(j),'f',1,'PaO20',PaO20r(j),'PaO2',PaO2r(j),'r',1);
	
	if mod(j,l*0.1)==0
    	fprintf(1,'\b\b%d%',j/(l*0.1)*10); pause(.1);  
    end 
	
end

fprintf('\n')

%-----------------------------------------------------------------------------------------
%calculate useful physiological changes
%-----------------------------------------------------------------------------------------

mod_alpha=0.2;
mod_beta=1.3;

phi=1.34;
epsilon=0.0031;
Hb=100.*Hctr./3;
SaO20=1./((23400./(PaO20r.^3+150.*PaO20r))+1);
SaO2=1./((23400./(PaO2r.^3+150.*PaO2r))+1); 
deltaSaO2=SaO2-SaO20;
deltaPaO2=PaO2r-PaO20r;
deltaCaO2=phi.*Hb.*deltaSaO2+epsilon.*deltaPaO2;
dHb0=Hctr./0.03.*(1-SaO20.*(1-E0r));
CBVv0=Vir.*omegaVr;
CBVv=CBVv0.*fhcr.^alphavr;

%hypoxic hypoxia
SaO20_hypoxia=1./((23400./(PaO20_hypoxiar.^3+150.*PaO20_hypoxiar))+1);
SaO2_hypoxia=1./((23400./(PaO2_hypoxiar.^3+150.*PaO2_hypoxiar))+1); 
deltaSaO2_hypoxia=SaO2_hypoxia-SaO20_hypoxia;
deltaPaO2_hypoxia=PaO2_hypoxiar-PaO20_hypoxiar;
deltaCaO2_hypoxia=phi.*Hb.*deltaSaO2_hypoxia+epsilon.*deltaPaO2_hypoxia;

%figure 2
figure(2);
pos=get(gcf,'position');
pos(3)=pos(3)*3;
set(gcf,'position',pos);
subplot(131)
scatter(dHb0.*CBVv0,dShc.*100,[],E0r,'filled');
title('Hypercapnia BOLD signal')
axis square;
box on;
ylim([-5 20]);
xlim([0 0.8]);
xlabel('V_0 [dHb]_0 (g_{Hb} dl^{-1})');
ylabel('\delta S_{hc} (%)');
colorbar;

subplot(132)
scatter(CBVv0,dSho.*100,[],E0r,'filled');
title('Hyperoxia BOLD signal')
axis square;
box on;
ylim([-2 6]);
xlim([0 0.05]);
xlabel('V_0 ');
ylabel('\delta S_{ho} (%)');
colorbar;

subplot(133)
scatter(dHb0,dShc./dSho,[],E0r,'filled');
title('Ratio of BOLD signals')
axis square;
box on;
ylim([-4 8]);
xlim([0 18]);
xlabel('[dHb]_0 (g_{Hb} dl^{-1})');
ylabel('\delta S_{hc} / \delta S_{ho}');
colorbar;

%figure 3
figure(3);
set(gcf,'position',pos);
subplot(131)
plot((1:l)./l,dShc_disc100./dSho_disc100);
title('S_{off}=1')
axis square;
box on;
ylim([-4 8]);
xlim([0 1]);
xlabel('E_0');
ylabel('\delta S_{hc} / \delta S_{ho}');

subplot(132)
plot((1:l)./l,dShc_disc95./dSho_disc95);
hold on;
plot([0.05 0.05],[-4 8],'--k');
title('S_{off}=0.95')
axis square;
box on;
ylim([-4 8]);
xlim([0 1]);
xlabel('E_0');
ylabel('\delta S_{hc} / \delta S_{ho}');

subplot(133)
plot((1:l)./l,dShc_disc90./dSho_disc90);
hold on;
plot([0.1 0.1],[-4 8],'--k');
title('S_{off}=0.9')
axis square;
box on;
ylim([-4 8]);
xlim([0 1]);
xlabel('E_0');
ylabel('\delta S_{hc} / \delta S_{ho}');

%figure 4
figure(4);
set(gcf,'position',pos);
subplot(131)
scatter(E0r,dShc./dSho./Hb,'filled');
title('Ratio of BOLD responses')
axis square;
box on;
ylim([0 0.3]);
xlim([0 1]);
xlabel('E_0');
ylabel('\delta S_{hc} / (\delta S_{ho} [Hb])');

subplot(132);
scatter(E0r,dShc./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
title('Simple model')
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');

subplot(133);
scatter(E0r,(deltaCaO2./phi)./((1-dSho./dShc.*(fhcr.^(mod_alpha-mod_beta)-1)).^(1./mod_beta)-1)./Hb,'filled');
title('Davis model')
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');

%figure 5
figure(5);
pos(3)=pos(3)/3*2;
pos(4)=pos(4)*2;
set(gcf,'position',pos);
subplot(221);
scatter(E0r,dShc./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
hold on;
scatter(E0r,dShc_metab./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
title('Isometabolism during hypercapnia');
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');

subplot(222);
scatter(E0r,dShc./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
hold on;
scatter(E0r,dShc./dSho_flow.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
title('Constant CBF during hyperoxia');
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');

subplot(223);
scatter(E0r,dShc./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
hold on;
scatter(E0r,dShc_hypoxia./dSho_hypoxia.*deltaCaO2_hypoxia./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
title('Hypoxic hypoxia');
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');

subplot(224);
scatter(E0r,dShc./dSho.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
hold on;
scatter(E0r,dShc_anaemia./dSho_anaemia.*deltaCaO2./phi./(1-fhcr.^(mod_alpha-1))./Hb,'filled');
title('Anaemic hypoxia');
axis square;
box on;
ylim([0 1]);
xlim([0 1]);
xlabel('E_0');
ylabel('Apparent E_0');
