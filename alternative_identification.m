%////////////////////////////////////////////////////////////////%
%//////- Structural-VAR (Assessment Idetificatiojn) -     ///////%
%////////////////////////////////////////////////////////////////%

clc;
clear;

%--- 
z1=xlsread('Data_oil_1.xlsx');
time=(1973+1/12:1/12:2019)';  
RAC   = [z1(:,1)]; % US Refiner Acquisition Cost of Crude Oil
WTI   = [z1(:,2)]; % West Texas Intermediate Oil Price
Oil_p = [z1(:,3)]; % Global Oil production 
Oil_i = [z1(:,4)]; % OECD oil invetories
Kil_i = [z1(:,5)]; % A proxy of Global economic activity 
Ham_i = [z1(:,6)]; % 2 years growth in global industry production 

%Montly Percentage change in global crude oil production
[T,~]=size(Oil_p);
   for i =1: size(Oil_p,2)
       for ii=2 : size(Oil_p,1)
        goil_p(ii-1,i)=((Oil_p(ii,i)-Oil_p(ii-1,i)))*100;
       end
   end
    
%Montly Percentage change in OECD oil inventories
[T,~]=size(Oil_i);
   for i =1: size(Oil_i,2)
       for ii=2 : size(Oil_i,1)
        goil_i(ii-1,i)=((Oil_i(ii,i)-Oil_i(ii-1,i)))*100;
       end
   end    
   
% Anual Percentage change in global crude oil production
gaoil_p=100*((Oil_p(13:T,1)./Oil_p(1:T-12,1))-1);  
  
%% VAR Estimation     
%The model is estimating using seasonal dummies and 24 autoregressive lags
% Information assemble. The sample goes from 1973m2 to  2006m12
 %z2= [goil_p Kil_i(2:T,:) RAC(2:T,:) goil_i ];
 z3= [goil_p Kil_i(2:T,:) RAC(2:T,:) ];
   
mmm=size(z3,2);
pp=24;
Horiz=18;
no_ofIRF=535;
NO_MAX_TRIALS=100000;

which_Shock_plot=3;
which_Shock_plot_1=2;
which_Shock_plot_2=1;

[AR_3d,Chol_Var] = VAR_OLS(z3,pp,1,[]); 

Ai_mat = dyn_multipliers(mmm,pp,AR_3d,Horiz);

%-----------------------------------------------%
%//// Impulse Responses by sign restriction ////%
%-----------------------------------------------%

[Q] = sing_restriction(Ai_mat,Chol_Var,NO_MAX_TRIALS);

%Oil Production  

 for ii=1:1:no_ofIRF
   [Q] = sing_restriction(Ai_mat,Chol_Var,NO_MAX_TRIALS);
   Store_Q(:,ii)=Q(:);
   Shock_2=zeros(3,1); Shock_2(which_Shock_plot_2,1)=1; 
   IRF3d_2(:,:,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock_2)';    
   for shsh = 1:3
     Shock=zeros(3,1); Shock(shsh,1)=1; 
     IRF4d_2(:,:,shsh,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock)';
   end        
   clear Q
 end

%Econoic Activity  

 for ii=1:1:no_ofIRF
   [Q] = sing_restriction(Ai_mat,Chol_Var,NO_MAX_TRIALS);
   Store_Q(:,ii)=Q(:);    
   Shock_1=zeros(3,1); Shock_1(which_Shock_plot_1,1)=1; 
   IRF3d_1(:,:,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock_1)';
   for shsh = 1:3
     Shock=zeros(3,1); Shock(shsh,1)=1; 
     IRF4d_1(:,:,shsh,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock)';
   end        
   clear Q
 end 

%Real Price of Oil 

 for ii=1:1:no_ofIRF
   [Q] = sing_restriction(Ai_mat,Chol_Var,NO_MAX_TRIALS);
   Store_Q(:,ii)=Q(:);    
   Shock=zeros(3,1); Shock(which_Shock_plot,1)=1; 
   IRF3d(:,:,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock)';    
   for shsh = 1:3
    Shock=zeros(3,1); Shock(shsh,1)=1; 
    IRF4d(:,:,shsh,ii)=Sirf(mmm,Horiz,Ai_mat,Chol_Var*Q,Shock)';
   end        
   clear Q
 end       
 
 
%%
%---------------------------------------------%
%----------------- Ploting--------------------%
%---------------------------------------------%
 
 
 TITLES=['Oil Supply Shock(-)         ';...
         'Oil Supply Shock(-)         ';...
         'Oil Supply Shock (+)        ';...   
         'Aggregate Demand Shock(+)   ';...
         'Aggregate Demand Shock(+)   ';...
         'Aggregate Demand Shock(+)   ';...
         'Oil-Specific Demand Shock(+)';...
         'Oil-Specific Demand Shock(-)';...
         'Oil-Specific Demand Shock(+)';];

  labels=['Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';...
          'Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';...
          'Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';];  
  
for variab=1:1:mmm
    figure(1)
    subplot(1,3,variab);
    PLOT_IRF=[];
    for ii=1:1:no_ofIRF
        PLOT_IRF=[PLOT_IRF IRF3d_2(:,variab,ii)];
    end
    plot([0:1:Horiz]',[PLOT_IRF],'linewidth',.1,'color','b');
    xlim([0 Horiz])
    title(TITLES(3*(which_Shock_plot_2-1)+variab,:),'FontSize',11);
    ylabel(labels(3*(which_Shock_plot_2-1)+variab,:),'FontSize',11);
    sgtitle('Graph: Impulse Responses (Identification by sign-restrictions)' )
end      
      
for variab=1:1:mmm
    figure(2)
    subplot(1,3,variab);
    PLOT_IRF=[];
    for ii=1:1:no_ofIRF
      PLOT_IRF=[PLOT_IRF IRF3d_1(:,variab,ii)];
    end
    plot([0:1:Horiz]',[PLOT_IRF],'linewidth',.1,'color','b');
    xlim([0 Horiz])
    title(TITLES(3*(which_Shock_plot_1-1)+variab,:),'FontSize',11);
    ylabel(labels(3*(which_Shock_plot_1-1)+variab,:),'FontSize',11);
    sgtitle('Graph: Impulse Responses (Identification by sign-restrictions)' )
end 
    
 
  for variab=1:1:mmm
    figure(3)
    subplot(1,3,variab);
    PLOT_IRF=[];
     for ii=1:1:no_ofIRF
       PLOT_IRF=[PLOT_IRF IRF3d(:,variab,ii)];
     end
    plot([0:1:Horiz]',[PLOT_IRF],'linewidth',.1,'color','b');
    xlim([0 Horiz])
    title(TITLES(3*(which_Shock_plot-1)+variab,:),'FontSize',11);
    ylabel(labels(3*(which_Shock_plot-1)+variab,:),'FontSize',11);
    sgtitle('Graph: Impulse Responses (Identification by sign-restrictions)' )
  end
  
%%
%-------------------------------------------%
%--------- Median Impulse Responses---------%
%-------------------------------------------%

low_quant = .16; 
up_quant = .84; 
        
 for d1 = 1:size(IRF4d,1)
  for d2 = 1:size(IRF4d,2)
    for shsh = 1:size(IRF4d,3)
        IRF3d_MED(d1,d2,shsh)=median(squeeze(IRF4d(d1,d2,shsh,:)));
        IRF3d_UP(d1,d2,shsh)=quantile(squeeze(IRF4d(d1,d2,shsh,:)),up_quant); 
        IRF3d_DOWN(d1,d2,shsh)=quantile(squeeze(IRF4d(d1,d2,shsh,:)),low_quant);   
     end
    end
  end

    zirf_med_1=IRF3d_MED(:,1,1);% Oil Supply to Oil production
    zirf_med_2=IRF3d_MED(:,2,1);%Aggregate demand to Oil produciton
    zirf_med_3=IRF3d_MED(:,3,1);%Specific-demand to Oil production
    zirf_med_4=IRF3d_MED(:,1,2);%Oil supply to real activity 
    zirf_med_5=IRF3d_MED(:,2,2);%Aggregate demand to real activity 
    zirf_med_6=IRF3d_MED(:,3,2);%Specific-demand to Oil production
    zirf_med_7=IRF3d_MED(:,1,3);%Oil supply to real price of oil
    zirf_med_8=IRF3d_MED(:,2,3);% Aggregate demand to real price
    zirf_med_9=IRF3d_MED(:,3,3);%Oil-specific demand to real price of oil 
        
    
 %--------------------------------------
 TITLES=['Oil Supply Shock(-)         ';...
         'Oil Supply Shock(-)         ';...
         'Oil Supply Shock(+)         ';...   
         'Aggregate Demand Shock(+)   ';...
         'Aggregate Demand Shock(+)   ';...
         'Aggregate Demand Shock(+)   ';...
         'Oil-Specific Demand Shock(+)';...
         'Oil-Specific Demand Shock(-)';...
         'Oil-Specific Demand Shock(+)';];

  labels=['Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';...
          'Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';...
          'Oil Production   ';...
          'Real Activity    ';...
          'Real Price of Oil';];  
 
 % Ploting
    
for ii=1:1:3;
  for variab=1:1:mmm
    figure(4)
    subplot(3,3,3*(ii-1)+variab);
    plot([0:1:Horiz]',[IRF3d_MED(:,variab,ii)'],'linewidth',2);
    hold
    plot([0:1:Horiz]',[IRF3d_DOWN(:,variab,ii) IRF3d_UP(:,variab,ii)],'linewidth',1,'LineStyle','--','color','k');
    title(TITLES(3*(ii-1)+variab,:),'FontSize',11);
    ylabel(labels(3*(ii-1)+variab,:),'FontSize',11);
    xlim([0 Horiz])
    sgtitle('Graph: Impulse Responses (Identification by sign-restrictions)' )
  end
end

%% Choleski vs Sign Restriction Identification
%First, SVAR estimation by Choleski decomposition
[T, N] = size(z3);
Horiz_1=24;
[A_2,SIGMA_2, Uhat_2, V_2]=lsvarcsa(z3,Horiz_1); 
mm_2=size(z3,2);     
B0inv_2=chol(SIGMA_2(1:N,1:N))';   
J_1=[eye(N,N) zeros(N,N*(Horiz_1-1))]; 
IRF_storage_2=reshape(J_1*A_2^0*J_1'*B0inv_2,N^2,1);
 for i=1:T-Horiz_1-1
  IRF_storage_2=([IRF_storage_2 reshape(J_1*A_2^i*J_1'*B0inv_2,N^2,1)]);
 end;
IRF_storage_2_w=IRF_storage_2  
IRF_storage_2=IRF_storage_2(:,1:19)'

%--Ploting the impulses responses with and with-out inventories  

   hh = 18;
    figure(5); 
     subplot(3,3,1); 
      plot([0:hh]',[zirf_med_1],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,1) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sign-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,4); 
      plot([0:hh]',[zirf_med_2],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,2) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sign-Restriction' , 'Rescursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,7); 
      plot([0:hh]',[zirf_med_3],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,3) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;   
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     subplot(3,3,2); 
      plot([0:hh]',[zirf_med_4],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,4) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,5); 
      plot([0:hh]',[zirf_med_5],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,5) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restrcition' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,8); 
      plot([0:hh]',[zirf_med_6],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,6) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off; 
     
 %%%%%%%%%%%%%%%%%%%%%%%    
    subplot(3,3,3); 
      plot([0:hh]',[zirf_med_7],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,7) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,6); 
      plot([0:hh]',[zirf_med_8],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,8) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restrcition' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,9); 
      plot([0:hh]',[zirf_med_9],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,9) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;     
      sgtitle('Graph: Structural Impulse Responses' )
      
 %////////////////////////////////////////////////////////////////////////////////////////
 %////////////////////////////////////////////////////////////////////////////////////////
 
 figure(6); 
     subplot(3,3,1); 
      plot([0:hh]',[zirf_med_1],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) -cumsum(squeeze(IRF_storage_2(:,1))) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sign-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,4); 
      plot([0:hh]',[zirf_med_2],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,2) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sign-Restriction' , 'Rescursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,7); 
      plot([0:hh]',[zirf_med_3],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,3) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Oil production','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;   
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     subplot(3,3,2); 
      plot([0:hh]',[zirf_med_4],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) cumsum(IRF_storage_2(:,4)) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,5); 
      plot([0:hh]',[zirf_med_5],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,5) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restrcition' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,8); 
      plot([0:hh]',[zirf_med_6],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,6) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real Activity','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off; 
     
 %%%%%%%%%%%%%%%%%%%%%%%    
    subplot(3,3,3); 
      plot([0:hh]',[zirf_med_7],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) cumsum(IRF_storage_2(:,7)) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Oil supply shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,6); 
      plot([0:hh]',[zirf_med_8],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,8) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restrcition' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Aggregate demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;
     subplot(3,3,9); 
      plot([0:hh]',[zirf_med_9],'linewidth',2)
      hold on; 
      plot([0:hh]',[zeros(hh+1,1) IRF_storage_2(:,9) ],'linewidth',1,'LineStyle','-','color','k'); 
      xlim([0 hh])
      legend([], 'Sing-Restriction' , 'Recursive Restriction', 'Location', 'best')
      ylabel('Real oil price','fontsize',11)
      title('Oil-specific demand shock','fontsize',11)
      set(gcf, 'color',  'w')
      legend('boxoff');
      hold off;     
      sgtitle('Graph: Structural Impulse Responses' )
      
 %////////////////////////////////////////////////////////////////////////////////
 %///////////////////////////////////////////////////////////////////////////////

 
 
 

        
        
    
  
  
    
    