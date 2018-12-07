%  set(gcf,'unit','normalized','position',[0.1,0.1,0.7,0.25]);
RGB=[colorScheme('FF7474');colorScheme('FFC474');colorScheme('69a6d5');colorScheme('6ae76a')];
RGB1=[colorScheme('FF933a');colorScheme('ffbd3a');colorScheme('ff3a3a');colorScheme('a65513');colorScheme('37b6ce')];

if type==8  %图11   
    st=25.5;en=st;ev=10;
    x1=(st-1)*24:T:(en)*24-T;
    p1=priceRecord((st-1)*I+1:(en)*I);
    y1=powerRecord(ev,(st-1)*I+1:(en)*I);
    y2=avgPowerRecord(ev,(st-1)*I+1:(en)*I);
    y3=minPowerRecord(ev,(st-1)*I+1:(en)*I);
    y4=maxPowerRecord(ev,(st-1)*I+1:(en)*I);
    p3=grid_priceRecord((st-1)*I+1:(en)*I);
    
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    [AX,H1,H2]=plotyy([x1',x1'],[p1',p3'],[x1',x1',x1',x1'],[y1',y2',y3',y4']);hold on;
    set(H2(1),'color','r','LineWidth',1.5);
    set(H2(2),'color','k','LineWidth',1.5);
    set(H2(3),'color','g','linestyle','--','LineWidth',1);
    set(H2(4),'color','g','linestyle','--','LineWidth',1);
    set(H1(1),'color',RGB(3,:),'LineWidth',1.5);
    set(H1(2),'color','b','LineWidth',1.5);
    % 设置坐标轴的范围和刻度
    set(AX,'Xlim',[(st-1)*24 en*24-T])
    set(AX(1),'Ylim',[min(p1),max(p1)])

    %设置坐标轴
    % set(get(AX(2),'Ylabel'),'string',{'P';'Pavg';'Pmin';'Pmax'});
    set(get(AX(2),'Ylabel'),'string','功率/kW');
    set(get(AX(1),'Ylabel'),'string','价格');
    legend([H1(1),H1(2),H2(1),H2(2)],'方案1出清价格','主网价格','出清功率','最优功率')
    
    figure;set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    H(i)=fill([x1,fliplr(x1)],[p3,fliplr(p1)],RGB(3,:));
    set(H(i),{'LineStyle'},{'none'});
    set(gca,'Xlim',[(st-1)*24 en*24-T])
    set(gca,'Ylim',[min(p1),max(p1)])
    figure;set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    H(i)=fill([x1,fliplr(x1)],[p2,fliplr(p3)],RGB(3,:));
    set(H(i),{'LineStyle'},{'none'});
    set(gca,'Xlim',[(st-1)*24 en*24-T])
    set(gca,'Ylim',[min(p4),max(p4)])
    z0=0.*x1;
    z=abs(tielineRecord((st-1)*I+1:(en)*I));
    figure;set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    plot(x1,Z);
    set(gca,'Xlim',[(st-1)*24 en*24-T])
    set(gca,'Ylim',[800,max(z3)])
    
    figure;set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    H0=fill([x1,fliplr(x1)],[z0,fliplr(z1)],RGB(2,:));hold on;
   % H1=fill([x1,fliplr(x1)],[z1,fliplr(z2)],RGB(1,:));
    set(H0,{'LineStyle'},{'none'}) %设置颜色和线宽
    set(H1,{'LineStyle'},{'none'}) %设置颜色和线宽
    alpha(0.6)
    set(gca,'Xlim',[(st-1)*24 en*24-T])
    set(gca,'Ylim',[800,max(z3)])
    figure;set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
%     H0=fill([x1,fliplr(x1)],[z0,fliplr(z1)],RGB(2,:));hold on;
    H1=fill([x1,fliplr(x1)],[z1,fliplr(z3)],RGB(3,:));
    set(H0,{'LineStyle'},{'none'}) %设置颜色和线宽
    set(H1,{'LineStyle'},{'none'}) %设置颜色和线宽
        alpha(0.6)

    set(gca,'Xlim',[(st-1)*24 en*24-T])
    set(gca,'Ylim',[800,max(z3)])  
    
    
elseif type==10
    figure
    st=380;en=399;T=1/4;ev=1;I=24/T;
    x1=(st-1)*24:T:(en)*24-T;
    y1=powerRecord(ev,(st-1)*I+1:(en)*I);
    y2=avgPowerRecord(ev,(st-1)*I+1:(en)*I);
    y3=minPowerRecord(ev,(st-1)*I+1:(en)*I);
    y4=maxPowerRecord(ev,(st-1)*I+1:(en)*I);
    y5=powerRecord1(ev,(st-1)*I+1:(en)*I);
    y6=avgPowerRecord1(ev,(st-1)*I+1:(en)*I);
    y7=minPowerRecord1(ev,(st-1)*I+1:(en)*I);
    y8=maxPowerRecord1(ev,(st-1)*I+1:(en)*I);
    y9=priceRecord((st-1)*I+1:(en)*I);
    y10=priceRecord1((st-1)*I+1:(en)*I);
    [AX,H1,H2]=plotyy([x1',x1'],[y9',y10'],[x1',x1',x1',x1',x1',x1',x1',x1'],[y1',y2',y3',y4',y5',y6',y7',y8']);hold on;
    set(H2(5),'color',RGB1(3,:),'LineWidth',3);
    set(H2(1),'color',RGB1(3,:),'linestyle','-.','LineWidth',1.5);
    set(H2(6),'color',RGB1(2,:),'LineWidth',3);
    set(H2(2),'color',RGB1(2,:),'linestyle','-.','LineWidth',1.5);
    set(H2(7),'color',RGB1(1,:),'LineWidth',3);
    set(H2(3),'color',RGB1(1,:),'linestyle','-.','LineWidth',1.5);
    set(H2(8),'color',RGB1(4,:),'LineWidth',3);
    set(H2(4),'color',RGB1(4,:),'linestyle','-.','LineWidth',1.5);
    
    set(H1(2),'color',RGB1(5,:),'LineWidth',2)
    set(H1(1),'color',RGB1(5,:),'linestyle','-.','LineWidth',2)
    % 设置坐标轴的范围和刻度
    set(AX,'Xlim',[(st-1)*24 en*24-T])
    %设置坐标轴
    % set(get(AX(2),'Ylabel'),'string',{'P';'Pavg';'Pmin';'Pmax'});
    set(get(AX(2),'Ylabel'),'string','功率/kW');
    set(get(AX(1),'Ylabel'),'string','出清价格');
    legend([H1(1),H2(1),H2(2),H2(3),H2(4)],'出清价格','充电功率','Pavg','Pmin','Pmax')
    
    
elseif type==11
    [EV,DAY]=size(avgPowerRecord);DAY_ST=1;I=96;T=1/4;
    DAY=DAY/I;
    day=DAY;
    st=2;en=DAY-2;
    C=linspecer(4);
    tielineRecord_noEVmean=zeros(1,96);
    priceRecordmean=zeros(1,96);
    tielineRecordmean=zeros(1,96);
    tielineRecord_noEVmean=zeros(1,96);
    grid_priceRecordmean=zeros(1,96);
    loadpowermean=zeros(1,96);
    prePriceRecord1_day=zeros(en-st,96);
%     prePriceRecord3_day=zeros(en-st,96);
    prePriceRecord1=preRecord11(2:end).*grid_priceRecord;
  
    for i=st:en-1
        tielineRecord_noEVmean=tielineRecord_noEVmean+tielineRecord_noEV((i-1)*96+1:96*i);
        grid_priceRecordmean=grid_priceRecordmean+grid_priceRecord((i-1)*96+1:96*i);
        loadpowermean=loadpowermean+lr((i-1)*96+1:96*i);
        prePriceRecord1_day(i-st+1,:)=prePriceRecord1((i-1)*96+1:96*i);
%         prePriceRecord3_day(i-st+1,:)=prePriceRecord3((i-1)*96+1:96*i);
        
    end
    tielineRecord_noEVmean=tielineRecord_noEVmean/(en-st);
    grid_priceRecordmean=grid_priceRecordmean/(en-st);
    loadpowermean=loadpowermean/(en-st);loadratiomean=zeros(1,simtype);
    for k=[1:2]
        priceRecordmean=zeros(1,96);
        conIndexmean=zeros(1,96);
        priceRecord_day=zeros(en-st,96);
        grid_priceRecord_day=zeros(en-st,96);
        eval(['priceRecordtmp=priceRecord',num2str(k),';']);
        conIndex=priceRecordtmp./grid_priceRecord;

        for i=st:en-1
            conIndexmean=conIndexmean+conIndex((i-1)*96+1:96*i);
            priceRecordmean=priceRecordmean+priceRecordtmp((i-1)*96+1:96*i);
            priceRecord_day(i-st+1,:)=priceRecordtmp((i-1)*96+1:96*i);
            grid_priceRecord_day(i-st+1,:)=grid_priceRecord((i-1)*96+1:96*i);
        end
         eval(['conIndexmean',num2str(k),'=conIndexmean/(en-st);']);
        eval(['priceRecordmean',num2str(k),'=priceRecordmean/(en-st);']);
        eval(['max(priceRecord',num2str(k),'./grid_priceRecord)']);
        eval(['priceRecord_day',num2str(k),'=priceRecord_day;']);
        
    end
    x=zeros(1,length(tielineRecord1));
    y=zeros(1,length(tielineRecord1));
    
    for i=1:length(tielineRecord1)
        y(i)=mod(i,96); %时段
        if y(i)==0
            y(i)=96;
        end
        x(i)=(i-y(i))/96;
    end
    loadratio=zeros(simtype,en-st);
    maxLoad=zeros(simtype,en-st);
    minLoad=zeros(simtype,en-st);
    for k=1:simtype
        powerRecordmean=zeros(1,96);
        tielineRecordmean=zeros(1,96);
        tielineRecord_day=zeros(en-st,96);
        eval(['powerRecordtmp=powerRecord',num2str(k),';']);
        eval(['tielineRecordtmp=tielineRecord',num2str(k),';']);
        eval(['tielineNoloss=sum(powerRecord',num2str(k),')-wr+lr;']);
        tmp=sprintf('%d总loss',k,sum(abs(tielineRecordtmp-tielineNoloss))/sum(abs(tielineNoloss)));
        for i=st:en-1
            powerRecordmean=powerRecordmean+sum(powerRecordtmp(:,(i-1)*96+1:96*i));
            tielineRecordmean=tielineRecordmean+tielineRecordtmp((i-1)*96+1:96*i);
            loadratio(k,i-st+1)=mean(abs(tielineRecordtmp((i-1)*96+1:96*i)))/max(abs(tielineRecordtmp((i-1)*96+1:96*i)));
            maxLoad(k,i-st+1)=max(abs(tielineRecordtmp((i-1)*96+1:96*i)));
            minLoad(k,i-st+1)=min(abs(tielineRecordtmp((i-1)*96+1:96*i)));
            tielineRecord_day(i-st+1,:)=tielineRecordtmp((i-1)*96+1:96*i);
            
        end
        eval(['powerRecordmean',num2str(k),'=powerRecordmean/(en-st);']);
        eval(['tielineRecordmean',num2str(k),'=tielineRecordmean/(en-st);']);
        loadratiomean(k)=mean(loadratio(k,:));
        eval(['tielineRecord_day',num2str(k),'=tielineRecord_day;']);
    end
    C=linspecer(3);
    c=['r','k','b','m'];
    %     for k=4:-1:1
    %         tmp=sprintf('方案%d',k);
    %         stairs(1:en-1,maxLoad(k,:),'color',c(k),'LineWidth',1.5,'DisplayName',tmp);hold on;
    %     end
    %     legend('show')
    %      for k=4:-1:1
    %         stairs(1:en-1,minLoad(k,:),'color',c(k),'linestyle',':','LineWidth',1.5);hold on;
    %      end
    
    
    %     C=linspecer(4);
    %     figure
    %     maxLoadSort=zeros(4,en-st);
    %     minLoadSort=zeros(4,en-st);
    %     [maxLoadSort(1,:),a]=sort(maxLoad(1,:)) ;
    
    %     for k=1:4
    %         for day=1:en-st
    %             maxLoadSort(k,day)=maxLoad(k,a(day));
    %             minLoadSort(k,day)=minLoad(k,a(day));
    %         end
    %         scatter(1:en-st,maxLoadSort(k,:),[],C(k,:),'filled','LineWidth',0.5);hold on;
    %         scatter(1:en-st,minLoadSort(k,:),[],C(k,:),'LineWidth',0.5);hold on;
    %     end
    %     figure
    %      for k=1:4
    %         for day=1:en-st
    %             maxLoadSort(k,day)=maxLoad(k,a(day));
    %             minLoadSort(k,day)=minLoad(k,a(day));
    %         end
    %         scatter(1:en-st,maxLoadSort(k,:),[],C(k,:),'filled','LineWidth',0.5);hold on;
    %         scatter(1:en-st,minLoadSort(k,:),[],C(k,:),'LineWidth',0.5);hold on;
    %     end
    %
    %
    %     for k=1:4
    %         scatter(1:en-st,maxLoad(k,:),[],C(k,:),'filled','LineWidth',0.5);hold on;
    %         scatter(1:en-st,minLoad(k,:),[],C(k,:),'LineWidth',0.5);hold on;
    %     end
    x=1/4:1/4:24;
    %     [AX,H1,H2]=plotyy([x',x',x',x'],[priceRecordmean1' priceRecordmean2',priceRecordmean3',priceRecordmean0']...
    %         ,[x',x',x',x',x',x',x',x',x'],[powerRecordmean1',powerRecordmean2',powerRecordmean3',powerRecordmean0',...
    %         abs(tielineRecordmean1)',abs(tielineRecordmean2)',abs(tielineRecordmean3)',abs(tielineRecordmean0)',abs(tielineRecord_noEVmean)']);hold on;
    %     set(get(AX(2),'Ylabel'),'string','功率/kW');
    %     set(get(AX(1),'Ylabel'),'string','出清价格');
    %     set(H1(1),'color',C(2,:),'LineWidth',1.5);
    %     set(H1(2),'color',C(2,:),'LineWidth',1.5,'linestyle','--');
    %     set(H1(3),'color',C(2,:),'LineWidth',1.5,'Marker','^','linestyle',':');
    %     set(H1(4),'color',C(2,:),'LineWidth',1.5,'linestyle',':');
    %     set(H2(1),'color',C(3,:),'LineWidth',1.5);
    %     set(H2(2),'color',C(3,:),'LineWidth',1.5,'linestyle','--');
    %     set(H2(3),'color',C(3,:),'LineWidth',1.5,'Marker','^','linestyle',':');
    %     set(H2(4),'color',C(3,:),'LineWidth',1.5,'linestyle',':');
    %     set(H2(5),'color',C(4,:),'LineWidth',1.5);
    %     set(H2(6),'color',C(4,:),'LineWidth',1.5,'linestyle','--');
    %     set(H2(7),'color',C(4,:),'LineWidth',1.5,'Marker','^','linestyle',':');
    %     set(H2(8),'color',C(4,:),'LineWidth',1.5,'linestyle',':');
    %     set(H2(9),'color',C(1,:),'LineWidth',1.5,'linestyle','-.');
    %
    %     title('方案A-1：采用赫布学习预测阻塞；方案A-2：采用赫布学习预测阻塞;方案B:采用滑动平均预测阻塞；方案C:不对阻塞进行预测')
    %     legend([H1(1),H2(1),H2(5),H2(9)],'出清价格','总充电功率','主变功率','无EV时主变功率')
    %     xlabel('t/h')
    figure%
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    [AX,H1,H2]=plotyy([x'],[abs(tielineRecord_noEVmean)'],x,grid_priceRecordmean);
    set(H2,'color','r','LineWidth',1.5)
    set(H1(1),'color','k','LineWidth',1.5)
    %     set(H1(2),'color','k','LineWidth',1.5,'linestyle',':')
    legend([H1(1),H2(1)],'无EV时主变功率','实时电价')
    set(get(AX(1),'Ylabel'),'string','功率(kW)');
    set(get(AX(2),'Ylabel'),'string','主网电价(元/kWh)');
    xlabel('t/h')
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
    
    figure
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
%     stairs(x,priceRecordmean1./grid_priceRecordmean,'r','LineWidth',1.5,'DisplayName','方案1(SC)');hold on;
%     stairs(x,priceRecordmean2./grid_priceRecordmean,'k','LineWidth',1.5,'DisplayName','方案2(SCnoP)')
    stairs(x,conIndexmean1,'r','LineWidth',1.5,'DisplayName','方案1(SC)');hold on;
    stairs(x,conIndexmean2,'k','LineWidth',1.5,'DisplayName','方案2(SCnoP)')

    %     stairs(x,priceRecordmean3./grid_priceRecordmean,'k','LineWidth',1.5,'linestyle',':','DisplayName','方案3')
%     stairs(x,priceRecordmean4./grid_priceRecordmean,'k','LineWidth',1.5,'linestyle','--','DisplayName','方案4');
    xlabel('t/h')
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
    ylabel('阻塞指数')
    legend('show')
    
    figure
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    a=plot(x,abs(tielineRecord_noEVmean),'color',C(1,:),'LineWidth',1.2,'DisplayName','无EV时');hold on;
    a1=plot(x,abs(tielineRecordmean1),'r','LineWidth',1.5,'DisplayName','方案1(SC)');
    a2=plot(x,abs(tielineRecordmean2),'k','LineWidth',1.5,'DisplayName','方案2(SCnoP)');
    a3=plot(x,abs(tielineRecordmean3),'k','LineWidth',1.5,'linestyle',':','DisplayName','方案3(PC)');
    a4=plot(x,abs(tielineRecordmean4),'k','LineWidth',1.5,'linestyle','--','DisplayName','方案4(DC)');
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
      set(gca,'YTick',500:500:3000);
    set(gca,'YTicklabel',{'0.5','1','1.5','2','2.5','3'})
    %     a5=plot(x,abs(tielineRecordmean5),'b','LineWidth',1.5,'DisplayName','方案5');
    %     a6=plot(x,abs(tielineRecordmean6),'b','LineWidth',1.5,'linestyle',':','DisplayName','方案6');
    % %     a7=plot(x,abs(tielineRecordmean7),'b','LineWidth',1.5,'linestyle','--','DisplayName','方案7');
    xlabel('t/h')
    ylabel('主变功率/kVA')
    legend('show')
    plot([x(1),x(end)],[tielineBuy,tielineBuy],'k','LineWidth',0.5,'linestyle','-.');
    figure;
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    a1=plot(x,powerRecordmean1,'r','LineWidth',1.5,'DisplayName','方案1(SC)');hold on;
    a2=plot(x,powerRecordmean2,'k','LineWidth',1.5,'DisplayName','方案2(SCnoP)');
    a3=plot(x,powerRecordmean3,'k','LineWidth',1.5,'linestyle',':','DisplayName','方案3(PC)');
    a4=plot(x,powerRecordmean4,'k','LineWidth',1.5,'linestyle','--','DisplayName','方案4(DC)');
    %     a5=plot(x,powerRecordmean5,'b','LineWidth',1.5,'DisplayName','方案5');
    %     a6=plot(x,powerRecordmean6,'b','LineWidth',1.5,'linestyle','--','DisplayName','方案6');
    % %     a7=plot(x,powerRecordmean7,'b','LineWidth',1.5,'linestyle',':','DisplayName','方案7');
    hold off;
    xlabel('t/h')
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
  
    ylabel('总充电功率/kW')
    legend('show')
    
    figure;
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    %     subplot(3,1,1);
    %     imagesc(T:T:24,1:DAY,prePriceRecord1_day./grid_priceRecord_day,[1 max(priceRecord2./grid_priceRecord)])
    
    for k=1:2
        subplot(2,1,k);
        
        
        eval(['imagesc(T:T:24,1:DAY,priceRecord_day',num2str(k),'./grid_priceRecord_day,[1 max(priceRecord2./grid_priceRecord)]);']);
        set(gca,'XTick',0:6:2*24);
        set(gca,'XTicklabel',{'0','6','12','18','24'})
        if k==1
            title('阻塞指数：上图-方案1(SC)；下图-方案2(SCnoP)');            
            set(gca,'xtick',[],'xticklabel',[])
        
        end
        ylabel('天')
        colormap('jet')
        
    end
    xlabel('t/h');
    figure
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    imagesc(T:T:24,1:DAY,(prePriceRecord1_day-priceRecord_day1)./grid_priceRecord_day)
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'});
    xlabel('t/h');
    ylabel('天');
%     figure
%     set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
%     modify_day=zeros(en-st,I);
%     modify=preRecord21./preRecord11;
%     for i=st:en-1
%         
%         modify_day(i-st+1,:)=modify((i-1)*96+1:96*i);
%     end
%     imagesc(T:T:24,1:DAY,modify_day,[0.8,2])
%     set(gca,'XTick',0:6:2*24);
%     set(gca,'XTicklabel',{'0','6','12','18','24'})
%     xlabel('t/h');
%     ylabel('天');
%     figure
%     set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    for k=1:simtype
        subplot(2,2,k);
%         eval(['imagesc(T:T:24,1:DAY,abs(tielineRecord_day',num2str(k),'),[0 max(abs(tielineRecord_day4(:)))]);']);
        eval(['imagesc(T:T:24,1:DAY,abs(tielineRecord_day',num2str(k),')/1000,[0 3.4]);']);
         set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
        if k>2
            xlabel('t/h');
        end       
        if k<=2
            set(gca,'xtick',[],'xticklabel',[])
        end
        if k==2||k==4
            set(gca,'ytick',[],'yticklabel',[])
        else
            ylabel('天')
        end
        tmp=sprintf('方案%d',k);
        title(tmp);
        colormap('jet')
    end
   
elseif type==12
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    c=['r  ';'k  ';'b  ';'m  ';'b  ';'b: ';'b--'];
    for k=1:2
        eval(['tmp=priceRecord',num2str(k),';']);
        [f,xi]=ksdensity(tmp);
        if k<1
            b=bar(xi,f);hold on;
            b.FaceColor=C(k,:);
            b.EdgeColor=C(k,:);
        else
            plot(xi,f,c(k,:),'LineWidth',2);hold on;
        end
    end
    
    
    [f,xi]=ksdensity(grid_priceRecord);
    plot(xi,f,'k:','LineWidth',2);hold on;
    legend('方案1(SC)','方案2(SCnoP)','实时电价')
    xlabel('电价')
    ylabel('概率密度')
    
elseif type==13
    DAY_sim=DAY;DAY_ST=1;
    ev=22;
    for k=[1:2]
        eval(['powerRecordtmp=powerRecord',num2str(k),';']);
        eval(['priceRecordtmp=priceRecord',num2str(k),';']);
        eval(['tielineRecordtmp=tielineRecord',num2str(k),';']);
        chengben_perday=zeros(EV,DAY_ST+DAY_sim-1);
        chengben_EV=powerRecordtmp(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)*priceRecordtmp((DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)'*T/DAY;
        
        eval(['chengben_EV',num2str(k),'=chengben_EV;']);
        for day=1:DAY_ST+DAY_sim-1
            chengben_perday(:,day)=powerRecordtmp(:,(day-1)*I+1:day*I)*priceRecordtmp((day-1)*I+1:day*I)'*T;
        end
        eval(['chengben',num2str(k),'_perday=chengben_perday;']);
    end
    chengben_EV3=powerRecord3(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)*grid_priceRecord((DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)'*T/DAY;
    chengben_EV4=powerRecord4(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)*grid_priceRecord((DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)'*T/DAY;
    for k=1:simtype
        eval(['chengben_EV_avg(k)=DAY/T*sum(chengben_EV',num2str(k),')/sum(sum(powerRecord',num2str(k),'(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)));']);
    end
        for k=1:simtype
        eval(['powerRecordtmp=powerRecord',num2str(k),';']);
        eval(['tielineRecordtmp=tielineRecord',num2str(k),';']);
        chengben_perday=zeros(EV,DAY_ST+DAY_sim-1);
        chengben=grid_priceRecord(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)*real(tielineRecordtmp((DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I))'*T/DAY;
        eval(['chengben',num2str(k),'=chengben;']);
    end
%         chengben_noEV=grid_priceRecord(:,(DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I)*real(tielineRecord_noEV((DAY_ST-1)*I+1:(DAY_ST+DAY_sim-1)*I))'*T/DAY;
    
    C=linspecer(4);
    figure;
    
    [chengben_EV3_sort,a]=sort(chengben_EV3) ;
    for k=[1:2 4]
        for ev=1:EV
            eval(['chengben_EV',num2str(k),'_sort(ev)=chengben_EV',num2str(k),'(a(ev));']);hold on;
        end
        
    end
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    
    scatter(1:EV,chengben_EV1_sort,2,C(2,:),'LineWidth',0.5);hold on;
    scatter(1:EV,chengben_EV2_sort,2,C(1,:),'LineWidth',1.5);hold on;
    scatter(1:EV,chengben_EV3_sort,2,C(3,:),'LineWidth',1.5);hold on;
    scatter(1:EV,chengben_EV4_sort,2,C(4,:),'LineWidth',1.5);hold on;
    legend('方案1(SC)','方案2(SCnoP)','方案3(PC)','方案4(DC)')
    xlabel('EV编号')
    ylabel('日平均成本/元')
    plot(1:EV,chengben_EV2_sort/DAY,'color',C(2,:),'LineWidth',1.5);hold on;
    plot(1:EV,chengben_EV3_sort/DAY,'color',C(3,:),'LineWidth',1.5);hold on;
    plot(1:EV,chengben_EV4_sort/DAY,'color',C(4,:),'LineWidth',1.5);hold on;
    plot(1:EV,chengben_EV1_sort/DAY,'color',C(1,:),'LineWidth',0.5);hold on;
    figure;
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    scatter(chengben_EV3,chengben_EV2./chengben_EV3,2.5,C(1,:),'LineWidth',1.5);hold on;
    scatter(chengben_EV3,chengben_EV4./chengben_EV3,2.5,C(4,:),'LineWidth',1.5);hold on;
    scatter(chengben_EV3,chengben_EV1./chengben_EV3,2.5,C(2,:),'LineWidth',1.5);hold on;

    grid on;
    legend('方案2(SCnoP)','方案4(DC)','方案1(SC)')
    xlabel('方案3下日平均费用/元')
    ylabel('各EV日均费用比')
    
    
        figure
         c=['r  ';'k  ';'k: ';'k--';'b  ';'b: ';'b--'];
        for k=[1 3]
            eval(['chengben',num2str(k),'*DAY-sum(chengben_EV',num2str(k),')']);
             eval(['tmp=chengben_EV',num2str(k),';']);
            [f,xi]=ksdensity(tmp);
             plot(xi,f,c(k,:),'LineWidth',1.5);hold on;
        end
    
    
    st=23;en=25;
    x1=(st-1)*24:T:(en)*24-T;
    x1=x1/24;
    x2=(st-1)*24:T:(en+1)*24-T;
    x2=x2/24;
    dispa=1;
    figure
    ev=4;
    eval(['y1=priceRecord',num2str(dispa),'((st-1)*I+1:(en)*I);']);
    y6=grid_priceRecord((st-1)*I+1:(en)*I);
    eval(['y2=avgPowerRecord',num2str(dispa),'(ev,(st-1)*I+1:(en+1)*I);']);
    eval(['y3=minPowerRecord',num2str(dispa),'(ev,(st-1)*I+1:(en+1)*I);']);
    eval(['y4=maxPowerRecord',num2str(dispa),'(ev,(st-1)*I+1:(en+1)*I);']);
    eval(['y5=powerRecord',num2str(dispa),'(ev,(st-1)*I+1:(en+1)*I);']);
    eval(['y7=prePriceRecord',num2str(dispa),'((st-1)*I+1:(en)*I); ']);
%     y7=preRecord21((st-1)*I+1:(en)*I); 

    [AX,H1,H2]=plotyy([x1',x1',x1'],[y1',y6',y7'],[x2',x2',x2',x2'],[y2',y3',y4',y5']);hold on;
    set(H2(1),'color',RGB1(4,:),'LineWidth',2);
    set(H2(4),'color',RGB1(3,:),'LineWidth',1.5)
    set(H2(3),'color',RGB1(2,:),'linestyle','--','LineWidth',1.5)
    set(H2(2),'color',RGB1(1,:),'LineWidth',3)
    set(H1(1),'LineWidth',2)
    set(H1(2),'color',RGB1(5,:),'LineWidth',2)
    %set(H1(3),'color',RGB(1,:),'LineWidth',2)
    set(AX(1),'ylim',[0.8,1.6]);  %左轴的范围
    set(AX(2),'ylim',[0,3.7]);  %右轴的范围
    % 设置坐标轴的范围和刻度
    %     set(AX,'Xlim',[(st-1) en-T/24])
    %设置坐标轴
    % set(get(AX(2),'Ylabel'),'string',{'P';'Pavg';'Pmin';'Pmax'});
    set(get(AX(2),'Ylabel'),'string','功率/kW');
    set(get(AX(1),'Ylabel'),'string','出清价格');
    legend([H1(1),H1(2),H1(3),H2(1),H2(2),H2(3),H2(4)],'出清价格','主网价格','预测价格','Pavg','Pmin','Pmax','充电功率')
    xlabel('t/day')
elseif type==14
    c=['r  ';'k  ';'k: ';'k--';'b  ';'b: ';'b--',];
    st=24.75;en=26;
%     for ev=1:EV
%         if EVdata_alpha(ev)>0.7&&EVdata_beta(ev)<0.6
%             tmp=sprintf('高alpha低beta %d',ev);disp(tmp);
%         elseif EVdata_alpha(ev)>0.9&&EVdata_beta(ev)>2.8
%             tmp=sprintf('高alpha高beta %d',ev);disp(tmp);
%         elseif EVdata_alpha(ev)<0.3&&EVdata_beta(ev)<0.6
%             tmp=sprintf('低alpha低beta %d',ev);disp(tmp);
%         elseif EVdata_alpha(ev)<0.3&&EVdata_beta(ev)>2.5
%             tmp=sprintf('低alpha高beta %d',ev);disp(tmp);
%         end
%     end
    x1=(st-1)*24:T:(en)*24-T;
    x1=x1/24;
    %     x1=x1-floor(min(x1));
    %     x1=x1*24;
    for ev=[10]
    figure
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    priceRecord4=grid_priceRecord;
    priceRecord3=grid_priceRecord;
    c=['r  ';'k  ';'k: ';'k--';'b  ';'b: ';'b--',];
    for k=1:simtype
        eval(['powerRecordtmp=powerRecord',num2str(k),';']);
        eval(['priceRecordtmp=priceRecord',num2str(k),';']);
        eval(['tmpE=E',num2str(k),'(ev,(st-1)*I+1:(en)*I)/EVdata_capacity(ev)*100;']);
        subplot(2,1,2);   
        plot(x1,tmpE,c(k,:),'LineWidth',1.5);hold on;
        sum(powerRecordtmp(ev,(st-1)*I+1:en*I)*priceRecordtmp((st-1)*I+1:en*I)')*T;
    end
    subplot(2,1,1);
    [AX,H1,H2]=plotyy([x1',x1',x1',x1',x1'],[PN*ones(length(x1),1),powerRecord1(ev,(st-1)*I+1:(en)*I)',powerRecord2(ev,(st-1)*I+1:(en)*I)',powerRecord3(ev,(st-1)*I+1:(en)*I)',powerRecord4(ev,(st-1)*I+1:(en)*I)'],x1,grid_priceRecord((st-1)*I+1:(en)*I));
    set(H1(1),'color','b','LineWidth',0.2,'LineStyle',':');
    set(H1(2),'color','r','LineWidth',1.5);
    set(H1(3),'color','k','LineWidth',1.5);
    set(H1(4),'color','k','LineStyle',':','LineWidth',1.5);
    set(H1(5),'color','k','LineStyle','--','LineWidth',1.5);
    set(H2,'color','b','LineWidth',1.5);
    legend([H1(2),H1(3),H1(4),H1(5),H2],'方案1(SC)','方案2(SCnoP)','方案3(PC)','方案4(DC)','主网价格')
    tmp=grid_priceRecord((st-1)*I+1:(en)*I);
    set(AX(2),'ylim',[min(tmp),max(tmp)]);  %右轴的范围
    set(get(AX(1),'Ylabel'),'string','功率/kW');
    set(get(AX(2),'Ylabel'),'string','电价元/kWh');
    legend('show')  
     set(gca,'xtick',[],'xticklabel',[])
    subplot(2,1,2);
    plot(x1,EVdata_mile(ev)/EVdata_capacity(ev)*100*ones(length(x1),1),'k:');
    plot(x1,((1-EVdata_alpha(ev))*EVdata_mile(ev)/EVdata_capacity(ev)+EVdata_alpha(ev))*100*ones(length(x1),1),'k:');
    xlabel('t/day');ylabel('SOC(%)')
    legend('方案1(SC)','方案2(SCnoP)','方案3(PC)','方案4(DC)')
    ylim([0 100])
    end
%     subplot(3,1,3);
%    [AX,H1,H2]=plotyy(x1,wr((st-1)*I+1:(en)*I),x1,lr((st-1)*I+1:(en)*I));
%    set(H1,'color','k','LineWidth',1.5);
%    set(H2,'color','b','LineWidth',1.5);
%     xlabel('t/day');
%     set(get(AX(1),'Ylabel'),'string','风电功率/kW');
%     set(get(AX(2),'Ylabel'),'string','负荷功率/kW');
%    legend([H1,H2],'风电功率','负荷功率')
    
% figure
% plot(E1(ev,:));hold on;
% plot(E2(ev,:));hold on;
% plot(E3(ev,:));hold on;
% plot(E4(ev,:));hold on;
% legend('1','2','3','4');
elseif type==15
    osl=0;osl1=0;osl2=0;
    for itera=I+1:length(priceRecord)
        i=mod(itera,I);
        if i==0
            i=I;
        end
        day_in=(itera-i)/I;
        osl(i,day_in)=priceRecord(itera);
        osl1(i,day_in)=priceRecord1(itera);
        osl2(i,day_in)=priceRecord2(itera);
    end
    a=I;b=I;c=1;d=25;
    C=linspecer(b+d-a-c+2);
    k=1;
    subplot(2,1,1);
    for i=a:b
        %         subplot(4,1,1);
        plot(1:day_in,osl(i,:),'color',C(k,:),'LineWidth',1.5,'LineStyle','-.');hold on;
        %         subplot(4,1,2);
        plot(1:day_in,osl2(i,:),'color',C(k,:),'LineWidth',1.5);hold on;
        %         subplot(4,1,3);
        %         plot(1:day_in,osl2(i,:),'color',C(k,:),'LineWidth',1.5,'linestyle',':');hold on;
        k=k+1;
    end
    for i=c:d
        %         subplot(4,1,1);
        plot(1:day_in,osl(i,:),'color',C(k,:),'LineWidth',1.5,'LineStyle','-.')
        %         subplot(4,1,2);
        plot(1:day_in,osl2(i,:),'color',C(k,:),'LineWidth',1.5);
        %         subplot(4,1,3);
        %         plot(1:day_in,osl2(i,:),'color',C(k,:),'LineWidth',1.5,'linestyle',':');hold on;
        k=k+1;
    end
    title('采用赫布学习预测')
    xlabel('天数')
    ylabel('电价')
    subplot(2,1,2);
    tielineRecord_noEV_mean=0;tielineRecord_noEV1_mean=0;
    for i=1:day_in
        tielineRecord_noEV_mean(i)=mean(tielineRecord_noEV(i*I-I+1:i*I));
    end
    plot(1:day_in,tielineRecord_noEV_mean,'color',RGB(1,:),'LineWidth',2);
    xlabel('天数')
    ylabel('无EV时主变功率/kWh')
elseif type==16
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    x=0:T:(length(grid_priceRecord)-1)*T;
    x=x/24;
    [AX,H1,H2]=plotyy([x',x'],[lr',wr'],x,grid_priceRecord);
    set(H2,'color','r','LineWidth',0.8)
    set(H1(1),'color','k','LineWidth',0.8)
    set(H1(2),'color','b','LineWidth',0.8)
    legend([H1(1),H1(2),H2(1)],'基荷功率','风电出力','实时电价')
    set(get(AX(1),'Ylabel'),'string','功率(MW)');
    set(get(AX(2),'Ylabel'),'string','主网电价(元/kWh)');
    set(gca,'ytick',[0:1000:2000]);set(gca,'YTicklabel',{'0','1','2'})
    xlabel('t/day')
elseif type==17%统计用户满意度  是否完成+完成时间
    C=linspecer(simtype);
    ymin=0;ymax=248;x=linspace(ymin,ymax,20);
    SatisRecord=zeros(simtype,EV);
    for k=[1:4]
        Satis=zeros(1,EV); 
        eval(['E=E',num2str(k),';']);
        for ev=1:EV
            isSatis=0;
            for day=1:DAY-2
                td=ceil((EVdata_week(2,ev)+(day-1)*24)/T);
                tmp=E(ev,td);
                if tmp>=EVdata_mile(ev)
                    isSatis=isSatis+1;
                end
            end
            Satis(ev)=isSatis;
        end
        SatisRecord(k,:)=Satis;
        xi=[1:DAY-2];
        [f]=ksdensity(Satis,xi);
        plot(xi,f,'color',C(k,:),'LineWidth',1.5);hold on;
        %         hisr(k,:)=hist(Satis,x);
        
    end
    %     bar(hisr');
    xlabel('满足充电要求的天数');
    ylabel('概率密度')
    legend('方案1(SC)','方案2(SCnoP)','方案3(PC)','方案4(DC)')
    figure;
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    
    c=['r  ';'k  ';'k: ';'k--';'b  ';'b: ';'b--',];
    Trust=zeros(simtype,2);
    for k=1:simtype
        eval(['tielineRecord=tielineRecord',num2str(k),';']);
        xi=min(abs(tielineRecord)):20:max(abs(tielineRecord2));
        [f]=ksdensity(abs(tielineRecord),xi);
        for tmp=1:length(xi)%90%置信区间
            if sum(f(1:tmp))*20>0.05
                Trust(k,1)=xi(tmp);
                break;
            end
        end
        for tmp=1:length(xi)
            if sum(f(tmp:end))*20<0.05
                Trust(k,2)=xi(tmp);
                break;
            end
        end
        for tmp=1:length(xi)
            if sum(f(tmp:end))*20<0.5
                Trust(k,3)=xi(tmp);
                break;
            end
        end
        plot(xi,f,c(k,:),'LineWidth',1.5);hold on;
    end
    [f]=ksdensity(abs(tielineRecord_noEV),xi);plot(xi,f,'color',C(1,:),'LineWidth',1.5);hold on;
    C=linspecer(4);
    xlabel('功率kVA')
    ylabel('概率密度')
    legend('1','2','3','4','noEV')
elseif type==18
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    
    SatisRecord=zeros(simtype,EV);
    for k=1:simtype
        Satis=zeros(1,EV);
        eval(['E=E',num2str(k),';']);
        for ev=1:EV
            isSatis=zeros(1,DAY-2);
            for day=2:DAY-2
                td=ceil((EVdata_week(2,ev)+(day-1)*24)/T)+1;
                ta=ceil((EVdata_week(1,ev)+(day-1)*24)/T)+1;
                tmp=E(ev,ta:td);
                [x,y]=max(tmp);
                while tmp(y)>=EVdata_mile(ev)&& y>1
                    y=y-1;
                end
                isSatis(day)=(y+1)/(td-ta+1);
            end
            SatisRecord(k,ev)=mean(isSatis);
        end
        xi=[0:0.01:1];
        [f]=ksdensity(SatisRecord(k,:),xi);
        for tmp=1:length(xi)%90%置信区间
            if sum(f(1:tmp))*0.01>0.05
                Trust_charge(k,1)=xi(tmp);
                break;
            end
        end
        for tmp=1:length(xi)
            if sum(f(tmp:end))*0.01<0.05
                Trust_charge(k,2)=xi(tmp);
                break;
            end
        end
        for tmp=1:length(xi)
            if sum(f(tmp:end))*0.01<0.5
                Trust_charge(k,3)=xi(tmp);
                break;
            end
        end
        c=['r  ';'k  ';'k: ';'k--';'b  ';'b: ';'b--',];
        if k==1
            plot(xi,f,c(k,:),'LineWidth',3);hold on;
        else
            plot(xi,f,c(k,:),'LineWidth',1.5);hold on;
        end
        
    end
    %     [SatisRecordSort(6,:),a]=sort(SatisRecord(6,:)) ;
    %     for k=[1 2 3 4 5 7]
    %         for ev=1:EV
    %             SatisRecordSort(k,ev)=SatisRecord(k,a(ev));
    %         end
    %     end
    legend('方案1(SC)','方案2(SCnoP)','方案3(PC)','方案4(DC)')
     xlabel('完成充电时间与总停靠时间的比值')
     ylabel('概率密度')
    figure
    C=linspecer(simtype);
    for k=[1:3]
        scatter(SatisRecord(4,:),SatisRecord(k,:),10,C(k,:),'fiiled');hold on;
    end
    set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    legend('1','2','3')
    plot([0 max(SatisRecord(3,:))],[0 max(SatisRecord(3,:))],'k:')
    xlabel('方案4(DC)下完成充电时间与总停靠时间的比值')
    ylabel('完成充电时间与总停靠时间的比值')
elseif type==19
    %预测准确度
    for k=[1:3]
        eval(['pavgRecord_temporal=pavgRecord_temporal',num2str(k),';']);
        eval(['priceRecord=priceRecord',num2str(k),'./grid_priceRecord;']);
        for day=1:DAY
            for i=1:I
                tmp=(day-1)*I+i;
                maxprice=max(pavgRecord_temporal(:,tmp));
                minprice=min(pavgRecord_temporal(:,tmp));
                if maxprice==1
                    preprice(k,tmp)=minprice/grid_priceRecord(tmp);
                elseif minprice==1
                    preprice(k,tmp)=maxprice/grid_priceRecord(tmp);
                else
                    preprice(k,tmp)=1;
                end
            end
        end
        tmp1=0;error=0;
        for i=1:tmp
            if preprice(k,i)~=1
                error=error+(((preprice(k,i)-priceRecord(i)))/priceRecord(i)).^2;
                tmp1=tmp1+1;
            end
            
        end
        error=sqrt((error/tmp1));
        errorRecord(k)=error;
    end
    plot(preprice(2,:));hold on;
    plot(priceRecord2./grid_priceRecord);
    %     figure
    %      scatter(EVdata_alpha_record(:,1),SatisRecord(:,1));;hold on;
    %
    %          set(gcf,'unit','normalized','position',[0,0,0.2,0.15]);
    %     xlabel('\alpha')
    %     ylabel('方案1完成充电时间占比')
elseif type==20
    C=linspecer(50);
    for ev=1:EV
        beta=EVdata_beta_record(:,ev);
        cost=chengben_EVrecord(:,ev);
        Satis=SatisRecord(:,ev);
        alpha=EVdata_alpha_record(:,ev);
        scatter(EVdata_beta_record(:,ev),chengben_EVrecord(:,ev),[],C(ev,:));
    end
    figure
    for ev=1:EV
        scatter(EVdata_alpha_record(:,ev),SatisRecord(:,ev),[],C(ev,:));
    end
elseif type==21
    powerRecord4mean_EV=zeros(EV,I);
     for i=st:en-1
            powerRecord4mean_EV=powerRecord4mean_EV+powerRecord4(:,(i-1)*96+1:96*i);
     end
     powerRecord4mean_EV=powerRecord4mean_EV/(en-st);
     x=T:T:24;
    plotyy([x',x'],[powerRecord4mean_EV(168,:)',powerRecord4mean_EV(73,:)'],T:T:24,grid_priceRecordmean)
    set(gca,'XTick',0:6:2*24);
    set(gca,'XTicklabel',{'0','6','12','18','24'})
    xlabel('t/h');
    ylabel('day');
elseif type==22
    th=(0:5)*2*pi/5;
    th=th+pi/2;
    cs=cos(th);
    sn=sin(th);
    rmax=100;
    rank=[100-150*(Trust(1,2)/tielineBuy-1) 100 100*sqrt(1-Trust_charge(1,3)) 100/1.06^3  80;...%阻塞缓解 负载率 充电完成时间 成本 稳定性
          100-150*(Trust(2,2)/tielineBuy-1) 80/(loadratiomean(1)-loadratiomean(4))*(loadratiomean(2)-loadratiomean(1))+100 100*sqrt(1-Trust_charge(2,3)) 100/1.15^3  70;...
          100-150*(Trust(3,2)/tielineBuy-1) 80/(loadratiomean(1)-loadratiomean(4))*(loadratiomean(3)-loadratiomean(1))+100 100*sqrt(1-Trust_charge(3,3)) 100 60;...
          100-150*(Trust(4,2)/tielineBuy-1) 20 100*sqrt(1-Trust_charge(4,3)) 100/1.07^3 60];
      rank=[rank(:,5) rank(:,1:4)];%稳定性 阻塞缓解 负载率 充电完成时间 成本 
      rank=[rank rank(:,1)];
    c=linspecer(4);simtype=4;
%      for k=1:simtype
c=[c(2,:);c(1,:);c(3:4,:)];
%    subplot(1,4,k);
    for i=1:length(th)
        line([0 rmax*cs(i)],[0 rmax*sn(i)],'Color','k');hold on;        
    end
    for r=0:25:rmax
       for i=2:length(th)
          line([r*cs(i-1) r*cs(i)],[r*sn(i-1) r*sn(i)],'Color','k');hold on;        
      end
    end
    for k=1:simtype
        scatter(rank(k,:).*cs,rank(k,:).*sn,40,c(k,:),'filled','LineWidth',0.5)
         for i=2:length(th)
           
             line([rank(k,i-1)*cs(i-1) rank(k,i)*cs(i)],[rank(k,i-1)*sn(i-1) rank(k,i)*sn(i)],'Color',c(k,:),'LineWidth',2);hold on;
         end
         axis off;
    end
elseif type==23
    plot(priceRecord1,'r');hold on
    plot(preRecord1(1:end-1).*grid_priceRecord,'k');hold on;
    plot(priceRecord1_noInput,'r:');hold on
    plot(preRecord1_noInput(1:end-1).*grid_priceRecord,'k:');hold on;
end
