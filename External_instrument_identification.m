%////////////////////////////////////////////////////////////////%
%//////- Structural-VAR (Assessment Idetificatiojn) -     ///////%
%////////////////////////////////////////////////////////////////%

clc;
clear;
direct = pwd;

%--- 1.- Shock identification with oil prices, oil production and an index of global economic activity
z1=xlsread('Data_oil_1.xlsx');
 time=(1973+1/12:1/12:2019)';  
RAC   = [z1(:,1)]; % US Refiner Acquisition Cost of Crude Oil
WTI   = [z1(:,2)]; % West Texas Intermediate Oil Price
Oil_p = [z1(:,3)]; % Global Oil production 
Oil_i = [z1(:,4)]; % OECD oil invetories
Kil_i = [z1(:,5)]; % A proxy of Global economic activity 
Ham_i = [z1(:,6)]; % 2 years growth in global industry production 
Proxy = xlsread('Data_oil_1.xlsx','Proxies');
z_one = Proxy(:,1);% 1-month futures (1975m2-2017m12)
z_three = Proxy(:,2);% 3-month futures (1975m2-2017m12)
z_six = Proxy(:,3);% 6-month futures (1975m2-2017m12)
years = xlsread('time');
years = years(25:539,:)
%Montly Percentage change in global crude oil production
  [T,~]=size(Oil_p);
    for i =1: size(Oil_p,2)
        for ii=2 : size(Oil_p,1)
        goil_p(ii-1,i)=((Oil_p(ii,i)-Oil_p(ii-1,i)))*100;
        end
    end
% Anual Percentage change in global crude oil production
   gaoil_p=100*((Oil_p(13:T,1)./Oil_p(1:T-12,1))-1);  
  
% Information assemble. The sample goes from 1975m2 to  2017m12
   z2= [goil_p(26:540,:) Kil_i(26:540,:) RAC(26:540,:) ];
   
   labels={'Oil_p' 'Economic_A' 'Refiner Cost' 'One' 'Three' 'Six'};
   dataset_name = 'OilData'; %The name of the dataset used for generating the figures (used in the output label)

%% Instrumental VAR EStimation For One Month Future 

application_1 = 'Oil';  % Name of this empirical application. This name will be used for creating and accessing folders

p           = 24;     %Number of lags in the VAR model
 
confidence  = .95;    %Confidence Level for the standard and weak-IV robust confidence set

% Define the variables in the SVAR
columnnames = [{'Percent Change in Global Crude Oil Production'}, ...
               {'Index of real economic activity'}, ...
               {'Real Price of Oil'}];

time        = 'Month';  % Time unit for the dataset (e.g. year, month, etc).

NWlags      = 0;  % Newey-West lags(if it is neccessary to account for time series autocorrelation)
                  % (set it to 0 to compute heteroskedasticity robust std errors)

norm        = 1; % Variable used for normalization

scale       = 1; % Scale of the shock

horizons    = 18; %Number of horizons for the Impulse Response Functions(IRFs)
                 %(does not include the impact or horizon 0)
                 
IRFselect   = [];

cumselect = []; 

savdir = strcat(direct,'/SVARIV/');

addpath(strcat(direct,'/functions/MasterFunction')); 

addpath(strcat(direct,'/functions/Inference'));

%For one month
[Plugin, InferenceMSW, Chol, RForm, figureorder, ARxlim, ARylim] = SVARIV(p, confidence, z2, z_one, NWlags, norm, scale, horizons, savdir, columnnames, IRFselect, cumselect, time, dataset_name);

%For three-month
[Plugin_3, InferenceMSW_3, Chol_3, RForm_3, figureorder_3, ARxlim_3, ARylim_3] = SVARIV(p, confidence, z2, z_three, NWlags, norm, scale, horizons, savdir, columnnames, IRFselect, cumselect, time, dataset_name);

%For Six-month
[Plugin_6, InferenceMSW_6, Chol_6, RForm_6, figureorder_6, ARxlim_6, ARylim_6] = SVARIV(p, confidence, z2, z_six, NWlags, norm, scale, horizons, savdir, columnnames, IRFselect, cumselect, time, dataset_name);

%% Ploting Results 

zirfone = Plugin.IRF(:,1:18)';
zirfthree = Plugin_3.IRF(:,1:18)';
zirfsix = Plugin_6.IRF(:,1:18)';
caux            = norminv(1-((1-confidence)/2),0,1);
n= size(z2,2)

for iplot=1: n
    upper(iplot,:)  =  Plugin.IRF(iplot,:) + (caux*Plugin.IRFstderror(iplot,:)); % blue dotter upper line. Delta CI
    lower(iplot,:)  =  Plugin.IRF(iplot,:) - (caux*Plugin.IRFstderror(iplot,:)); % blue dotted lower line. Delta CI
end

upper=upper(:,1:18)'
lower=lower(:,1:18)'

for iplot=1: n
    upper_3(iplot,:)  =  Plugin_3.IRF(iplot,:) + (caux*Plugin_3.IRFstderror(iplot,:)); % blue dotter upper line. Delta CI
    lower_3(iplot,:)  =  Plugin_3.IRF(iplot,:) - (caux*Plugin_3.IRFstderror(iplot,:)); % blue dotted lower line. Delta CI
end

upper_3=upper_3(:,1:18)'
lower_3=lower_3(:,1:18)'

for iplot=1: n
    upper_6(iplot,:)  =  Plugin_6.IRF(iplot,:) + (caux*Plugin_6.IRFstderror(iplot,:)); % blue dotter upper line. Delta CI
    lower_6(iplot,:)  =  Plugin_6.IRF(iplot,:) - (caux*Plugin_6.IRFstderror(iplot,:)); % blue dotted lower line. Delta CI
end

upper_6=upper_6(:,1:18)'
lower_6=lower_6(:,1:18)'


hh = 17;
 figure(4) 
     subplot(3,1,1); 
      h1=plot([0:hh]',[zirfone(:,1)],'linewidth',1)
      hold on; 
      h2=plot([0:hh]',[zirfthree(:,1) ],'linewidth',1,'LineStyle','-','color','k'); 
      
      h3=plot([0:hh]',[zirfsix(:,1) ],'linewidth',1,'LineStyle','-','color','r'); 
      xlim([0 hh])
      legend([], '1-Month Futures', '3-Month Future', '6-Month Futures' , 'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Oil Production','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,2); 
      h1=plot([0:hh]',[zirfone(:,2)],'linewidth',2)
      hold on; 
      h2=plot([0:hh]',[zirfthree(:,2) ],'linewidth',1,'LineStyle','-','color','k'); 
      h3=plot([0:hh]',[zirfsix(:,2) ],'linewidth',1,'LineStyle','-','color','r'); 
      xlim([0 hh])
      legend([], '1-Month Futures', '3-Month Future', '6-Month Futures' , 'Location', 'best')
      %ylim([-25  5]);
      %ylabel('Oil production','fontsize',11)
      title('Economic Activity','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,3); 
      h1=plot([0:hh]',[zirfone(:,3)],'linewidth',2)
      hold on; 
      h2=plot([0:hh]',[zirfthree(:,3) ],'linewidth',1,'LineStyle','-','color','k'); 
      h3=plot([0:hh]',[zirfsix(:,3) ],'linewidth',1,'LineStyle','-','color','r'); 
      xlim([0 hh])
      legend([], '1-Month Futures', '3-Month Future', '6-Month Futures' , 'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Real Price of Oil','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     sgtitle('Graph:Impulse Responses to Oil supply new shocks ' )

   
%% Contsruction 2 more instruments: i)level proxy and Slope proxy  

level_p = (z_one+z_three+z_six)/n; % Level proxy
slope_p = (z_six-z_one);  % Slope proxy

%For Level proxy
[Plugin_l, InferenceMSW_l, Chol_l, RForm_l, figureorder_, ARxlim_, ARylim_] = SVARIV(p, confidence, z2, level_p, NWlags, norm, scale, horizons, savdir, columnnames, IRFselect, cumselect, time, dataset_name);

%For Slope proxy
[Plugin_s, InferenceMSW_s, Chol_s, RForm_s, figureorder_s, ARxlim_s, ARylim_s] = SVARIV(p, confidence, z2, slope_p, NWlags, norm, scale, horizons, savdir, columnnames, IRFselect, cumselect, time, dataset_name);

zirflevel = Plugin_l.IRF(:,1:18)';
zirfslope = Plugin_s.IRF(:,1:18)';

figure(5) 
     subplot(3,1,1); 
      h1=plot([0:hh]',[zirflevel(:,1)],'linewidth',2)
      hold on; 
      %h2=plot([0:hh]',[zirfslope(:,1) ],'linewidth',1,'LineStyle','-','color','k');  
      xlim([0 hh])
      legend([], 'Level Proxy', 'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Oil Production','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,2); 
      plot([0:hh]',[zirflevel(:,2)],'linewidth',2)
      hold on; 
      %h2=plot([0:hh]',[zirfslope(:,2) ],'linewidth',1,'LineStyle','-','color','k'); 
     
      xlim([0 hh])
      legend([], 'Level Proxy', 'Location', 'best')
      %ylim([-25  5]);
      %ylabel('Oil production','fontsize',11)
      title('Economic Activity','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,3); 
      h1=plot([0:hh]',[zirflevel(:,3)],'linewidth',2)
      hold on; 
      %h2=plot([0:hh]',[zirfslope(:,3) ],'linewidth',1,'LineStyle','-','color','k'); 
     
      xlim([0 hh])
      legend([], 'Level Proxy',  'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Real Price of Oil','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     sgtitle('Graph:Impulse Responses to Oil supply new shocks ' )

   

     figure(6) 
     subplot(3,1,1); 
      %plot([0:hh]',[zirflevel(:,1)],'linewidth',1)
      
      plot([0:hh]',[zirfslope(:,1) ],'linewidth',2);  
       hold on;
      xlim([0 hh])
      legend([],'Slope Proxy', 'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Oil Production','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,2); 
      %h1=plot([0:hh]',[zirflevel(:,2)],'linewidth',2)
    
      plot([0:hh]',[zirfslope(:,2) ],'linewidth',2); 
        hold on; 
      xlim([0 hh])
      legend([],  'Slope Proxy', 'Location', 'best')
      %ylim([-25  5]);
      %ylabel('Oil production','fontsize',11)
      title('Economic Activity','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
subplot(3,1,3); 
      %h1=plot([0:hh]',[zirflevel(:,3)],'linewidth',2)
    
      plot([0:hh]',[zirfslope(:,3) ],'linewidth',2); 
        hold on; 
      xlim([0 hh])
      legend([], 'Slope Proxy',  'Location', 'best')
      %ylim([-1  1.5]);
      %ylabel('Oil production','fontsize',11)
      title('Real Price of Oil','fontsize',11)
      %annotation('textbox',dim,'String',ann_3,'EdgeColor', 'none' );
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     sgtitle('Graph:Impulse Responses to Oil supply new shocks ' )
   
   