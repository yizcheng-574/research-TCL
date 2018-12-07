% function [power_loss,pt,Umin]=cal_powerloss(load,bus_inj,wind)
function [power_loss,pt]=cal_powerloss(load,bus_inj,wind)

%system MVA base
baseMVA = 2;

% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
bus = [  %% (Pd and Qd are specified in kW & kVAr here, converted to MW & MVAr below)
    1	3	0	0	0	0	1	1	0	12.66	1	1	1;%node 1Ϊ��ѹ�����ڴ�ĸ�ߣ� �ʲ�������
    2	1	100	60	0	0	1	1	0	12.66	1	1.1	0.9;
    3	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    4	1	120	80	0	0	1	1	0	12.66	1	1.1	0.9;
    5	1	60	30	0	0	1	1	0	12.66	1	1.1	0.9;
    6	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    7	1	200	100	0	0	1	1	0	12.66	1	1.1	0.9;
    8	1	200	100	0	0	1	1	0	12.66	1	1.1	0.9;
    9	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    10	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    11	1	45	30	0	0	1	1	0	12.66	1	1.1	0.9;
    12	1	60	35	0	0	1	1	0	12.66	1	1.1	0.9;
    13	1	60	35	0	0	1	1	0	12.66	1	1.1	0.9;
    14	1	120	80	0	0	1	1	0	12.66	1	1.1	0.9;
    15	1	60	10	0	0	1	1	0	12.66	1	1.1	0.9;
    16	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    17	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    18	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    19	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    20	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    21	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    22	1	90	40	0	0	1	1	0	12.66	1	1.1	0.9;
    23	1	90	50	0	0	1	1	0	12.66	1	1.1	0.9;
    24	1	42	20	0	0	1	1	0	12.66	1	1.1	0.9;
    25	1	42	20	0	0	1	1	0	12.66	1	1.1	0.9;
    26	1	60	25	0	0	1	1	0	12.66	1	1.1	0.9;
    27	1	60	25	0	0	1	1	0	12.66	1	1.1	0.9;
    28	1	60	20	0	0	1	1	0	12.66	1	1.1	0.9;
    29	1	120	70	0	0	1	1	0	12.66	1	1.1	0.9;
    30	1	200	600	0	0	1	1	0	12.66	1	1.1	0.9;
    31	1	150	70	0	0	1	1	0	12.66	1	1.1	0.9;
    32	1	210	100	0	0	1	1	0	12.66	1	1.1	0.9;
    33	1	60	40	0	0	1	1	0	12.66	1	1.1	0.9;
    ];

% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
gen = [
    1	0	0	10	-10	1	100	1	10	0	0	0	0	0	0	0	0	0	0	0	0;
    ];

%branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
branch = [  %% (r and x specified in ohms here, converted to p.u. below)
    1	2	0.0922	0.0470	0	0	0	0	0	0	1	-360	360;
    2	3	0.4930	0.2511	0	0	0	0	0	0	1	-360	360;
    3	4	0.3660	0.1864	0	0	0	0	0	0	1	-360	360;
    4	5	0.3811	0.1941	0	0	0	0	0	0	1	-360	360;
    5	6	0.8190	0.7070	0	0	0	0	0	0	1	-360	360;
    6	7	0.1872	0.6188	0	0	0	0	0	0	1	-360	360;
    7	8	0.7114	0.2351	0	0	0	0	0	0	1	-360	360;
    8	9	1.0300	0.7400	0	0	0	0	0	0	1	-360	360;
    9	10	1.0440	0.7400	0	0	0	0	0	0	1	-360	360;
    10	11	0.1966	0.0650	0	0	0	0	0	0	1	-360	360;
    11	12	0.3744	0.1238	0	0	0	0	0	0	1	-360	360;
    12	13	1.4680	1.1550	0	0	0	0	0	0	1	-360	360;
    13	14	0.5416	0.7129	0	0	0	0	0	0	1	-360	360;
    14	15	0.5910	0.5260	0	0	0	0	0	0	1	-360	360;
    15	16	0.7463	0.5450	0	0	0	0	0	0	1	-360	360;
    16	17	1.2890	1.7210	0	0	0	0	0	0	1	-360	360;
    17	18	0.7320	0.5740	0	0	0	0	0	0	1	-360	360;
    2	19	0.1640	0.1565	0	0	0	0	0	0	1	-360	360;
    19	20	1.5042	1.3554	0	0	0	0	0	0	1	-360	360;
    20	21	0.4095	0.4784	0	0	0	0	0	0	1	-360	360;
    21	22	0.7089	0.9373	0	0	0	0	0	0	1	-360	360;
    3	23	0.4512	0.3083	0	0	0	0	0	0	1	-360	360;
    23	24	0.8980	0.7091	0	0	0	0	0	0	1	-360	360;
    24	25	0.8960	0.7011	0	0	0	0	0	0	1	-360	360;
    6	26	0.2030	0.1034	0	0	0	0	0	0	1	-360	360;
    26	27	0.2842	0.1447	0	0	0	0	0	0	1	-360	360;
    27	28	1.0590	0.9337	0	0	0	0	0	0	1	-360	360;
    28	29	0.8042	0.7006	0	0	0	0	0	0	1	-360	360;
    29	30	0.5075	0.2585	0	0	0	0	0	0	1	-360	360;
    30	31	0.9744	0.9630	0	0	0	0	0	0	1	-360	360;
    31	32	0.3105	0.3619	0	0	0	0	0	0	1	-360	360;
    32	33	0.3410	0.5302	0	0	0	0	0	0	1	-360	360;
%     21	8	2.0000	2.0000	0	0	0	0	0	0	0	-360	360;
%     9	15	2.0000	2.0000	0	0	0	0	0	0	0	-360	360;
%     12	22	2.0000	2.0000	0	0	0	0	0	0	0	-360	360;
%     18	33	0.5000	0.5000	0	0	0	0	0	0	0	-360	360;
%     25	29	0.5000	0.5000	0	0	0	0	0	0	0	-360	360;
    ];

%z��һ�д�֧·�ţ��ڶ��д��׽ڵ�ţ������д�β�ڵ�ţ������д�֧·���迹,�����д�β�ڵ��������
bus(:,3)=bus(:,3)/sum(bus(:,3))*load;
bus(8,3)=bus(6,3)-wind/3;
bus(20,3)=bus(20,3)-wind/3;
bus(30,3)=bus(30,3)-wind/3;
bus(:,4)=bus(:,3)*tan(acos(0.9872));%�ο�cost-benefit analysis of V2G implementation in distribution networks considering PEVs battery degradation :power factor 0.9872
[n o]=size(bus);
b=n-1;
Sb=baseMVA;
% Ub=bus(1,10);
Ub=10;
Zb=Ub^2/Sb;
Ib=Sb*1000/(sqrt(3)*Ub);
Z=zeros(b,5);
feeder=[0.63,0.368;1.94,0.44];
feeder_type=[1;1;1;1;1;2*ones(1,27)'];%node 1~5�����ϴ�Ϊ1�����ߣ�����Ϊ2������
distance=1.5*[1;0.5;0.5;0.5;0.5;0.3*ones(1,27)'];
for p=1:b
    branch1(p,:)=distance(p)*feeder(feeder_type(p),:);
end
dis_branch=branch(1:b,:);
Z(:,2:3)=dis_branch(:,1:2)-1;
Z(:,1)=1:b;
Z(:,5)=(bus_inj(2:end)'+bus(2:n,3))/Sb/1000+i*bus(2:n,4)/Sb/1000;% Z(:,5)=bus(2:n,3)/Sb/1000+i*bus(2:n,4)/Sb/1000;
% Z(:,4)=dis_branch(:,3)/Zb+i*dis_branch(:,4)/Zb;
Z(:,4)=branch1(:,1)/Zb+i*branch1(:,2)/Zb;
k=0;
V=ones(n,1);
t=0;
%������ʼ��
while t<b &k<10
    %��ڵ�ע�����
    x1=Z(b,3);x=x1-n;
    for l=1:b
        j=Z(l,3);
        ua=V(j+1,1);
        I(j,1)=conj(Z(j,5)/ua);
    end
    %������֧·����
   
    J=zeros(b,1);
    l=b;
    J(l)=J(l)+I(l);
    for jj=1:b-1
        l=l-1;
        for m=l+1:b
            if Z(m,2)==Z(l,3)
                J(l)=J(l)+J(m);
            end
        end
        J(l)=J(l)+I(l);
    end
    %ǰ����ڵ��ѹ
    for l=1:b
        j=Z(l,3)+1;
        ii=Z(l,2)+1;
        V(j,1)=V(ii,1)-Z(l,4)*J(l,1);
    end
    %�����ж�
    t=0;
    for j=2:n
        SS=V(j,1)*conj(I(j-1,1));
        dp=real(SS-Z(j-1,5));
        dq=imag(SS-Z(j-1,5));
        S(j-1,1)=SS;
        ddp=abs(dp);
        ddq=abs(dq);
        L1=(ddp<0.0001)&(ddq<0.0001);
        F(j-1,1)=L1;
        if L1==1
            t=t+1;
        end
    end
    k=k+1;
end
%F:��ʾ�����ڵ����,"1"��ʾ������"0"��ʾ������';
% disp('��ʾ�����ڵ����,"1"��ʾ������"0"��ʾ������');
% disp(F);
%  for j=1:b
%      if F(j,1)==0
%          disp('��ʾ�������ڵ�š����㹦��');
% disp(j);disp(S(j,1));
%      end
%  end
 
for j=1:n
    Vm(j,1)=abs(V(j,1));Va(j,1)=angle(V(j,1));
end
pt=conj(J(1))*Sb*1000;
power_loss=conj(J(1))*Sb*1000-sum(bus(:,3))-sum(bus(:,4))*i-sum(bus_inj(2:end));
Umin=min(Vm);
% power_loss=conj(J(1))*Sb*1000-sum(bus(:,3))-sum(bus(:,4))*i;

end