function PlottingResults(pOpt)
global WhichGenotype tx

alpha = pOpt(1);
a = pOpt(2);
kA = pOpt(3);
e_T= pOpt(4);
e_R= pOpt(5);
g= pOpt(6);
b_T= pOpt(7);
b_R= pOpt(8);
epsilon = pOpt(9);
mu = pOpt(10);
beta = pOpt(11);
c = pOpt(12);
kB = pOpt(13);
j = pOpt(14);
z = pOpt(15);
n = pOpt(16);
d = pOpt(17);


ModelData = SimulateGrowth(pOpt);
ModelData = array2table(ModelData);

ModelData.Properties.VariableNames = {'NaiveCT' 'ActivCT' 'TregCT' ...
    'ThyDerivedNaive' 'ActivNaive' 'ThyDerivedTregs' 'NaiveDerivedTregs' ...
    'ProlNaive' 'ProlActiv' 'ProlTregs' ...
    'Il2' 'ThyWeight'};

%1 = WildType, 2 = Genotype
if WhichGenotype == 1
    CellData = readtable('../RawData/ActivatedWTSpleen.csv');
    ProlData = readtable('../RawData/WTProl.csv');
elseif WhichGenotype == 2
    CellData = readtable('../RawData/ActivatedKOSpleen.csv');
    ProlData = readtable('../RawData/KOProl.csv');
end

CellData = CellData(:,{'NaiveCT', 'ActivatedCD4CT', 'X4TregCT', ...
    'ThymicNaive', 'ActivatedNaiveCT', ...
    'ThymicDerivedTregsCT', 'NaiveDerivedTregsCT' ... 
    'hours'});

ProlData = ProlData(:,{ 'NaiveProlCT', 'ActivatedProlCT', 'X4TregProlCT', ...
    'hours'});



PLT = figure(1);
%Naive CT
subplot(3,4,1)
scatter(CellData.hours, CellData.NaiveCT)
hold on 
plot(tx, ModelData.NaiveCT)
title('Naive T Cells')
hold off
%Naive Prol
subplot(3,4,2)
scatter(ProlData.hours, ProlData.NaiveProlCT)
hold on 
plot(tx, ModelData.ProlNaive)
title('Proliferating Naive')
hold off
%Naive Thymic
subplot(3,4,3)
scatter(CellData.hours, CellData.ThymicNaive)
hold on 
plot(tx, ModelData.ThyDerivedNaive)
title('Thymic Naive')
hold off

%Calculating Treg Frequency
TregFreq = ModelData.TregCT ./(ModelData.NaiveCT+ModelData.ActivCT);
%TregFreq (TregFreq > 0.1) = NaN;
subplot(3,4,4)
plot(tx, TregFreq)
title('Treg frequency')

%Activated CT
subplot(3,4,5)
scatter(CellData.hours, CellData.ActivatedCD4CT)
hold on 
plot(tx, ModelData.ActivCT)
title('Activated Counts')
hold off
%Activated Prol
subplot(3,4,6)
scatter(ProlData.hours, ProlData.ActivatedProlCT)
hold on 
plot(tx, ModelData.ProlActiv)
title('Activated Prol')
hold off
%Activated Naive derived
subplot(3,4,7)
scatter(CellData.hours, CellData.ActivatedNaiveCT)
hold on 
plot(tx, ModelData.ActivCT)
title('Activated Naive')
hold off
%IL-2
subplot(3,4,8)
plot(tx, ModelData.Il2)
title('IL-2')
hold off
%Treg CT
subplot(3,4,9)
scatter(CellData.hours, CellData.X4TregCT)
hold on 
plot(tx, ModelData.TregCT)
title('Treg CT')
hold off
%Treg Prol
subplot(3,4,10)
scatter(ProlData.hours, ProlData.X4TregProlCT)
hold on 
plot(tx, ModelData.ProlTregs)
title('Treg Prol')
hold off
%Thymic Tregs
subplot(3,4,11)
scatter(CellData.hours, CellData.ThymicDerivedTregsCT)
hold on 
plot(tx, ModelData.ThyDerivedTregs)
title('Thymic Tregs')
hold off
%Naive Derived Tregs
subplot(3,4,12)
scatter(CellData.hours, CellData.NaiveDerivedTregsCT)
hold on 
plot(tx, ModelData.NaiveDerivedTregs)
title('Naive Derived Tregs')
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------Fixed Parameters---------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%d = 1000; %IL-2 production Rate
f = 1.38629; %IL-2 degradation Rate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------Calculating---------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n1 = 1;

%Hill suppression naive
ModelData.HillNaive = (1./(1+(ModelData.TregCT./kA).^n));
%Hill suppression Treg death rate
ModelData.HillTregDeath = (1./(1+(ModelData.Il2./kB).^n1));
%How many Activated T's are being destroyed
ModelData.ActiveDestruction = (j.*ModelData.TregCT.*ModelData.ActivCT);


PLT2 = figure(2);

%Hill suppression naive
subplot(3,3,1)
plot(tx, ModelData.HillNaive)
title('Hill Value')
ylabel('Hill Value')

subplot(3,3,2)
plot(tx, ModelData.HillTregDeath)
title('Treg Death Suppression')
ylabel('Death Rate Suppression')

subplot(3,3,3)
plot(tx, ModelData.ActiveDestruction)
title('Destroyed T Cells')


Changing = {'*mu',       mu,         '   cells*hr−1';...
                    '*z',             z,             'cells-1*hr-1';...
                    '*g',          g,             '   hr−1';...
                    
                    '*alpha',     alpha,     '   cells*hr−1';...
                    '*c',           c,           '   hr−1';...
                    '*epsilon',  epsilon,   '  hr−1';...
                    '*b_R',      b_R,          '   hr−1';...
                    
                    '*beta',      beta,      '   hr−1';...
                    '*a',           a,             '   hr−1';...
                    '*b_T',       b_T,           '   hr−1'};

columnname =   {'Parameters', '     Value          ', '           Units           '};
columnformat = {'char', 'numeric', 'char'}; 
uitable('Units','normalized',...
                 'Position', [0.12 0.2 0.3466 0.4],... % [ Horizontal Location, Verticle location,Right Line, Bottom Line]
                 'Data', Changing,...
                 'ColumnName', columnname,...
                 'ColumnFormat', columnformat,...
                 'RowName',[],...
                 'FontSize', 15,...p
                 'ColumnWidth', {150 200 270});
             
             
Fixed =  {'*e_T',       e_T,         '   cells-1*hr−1';...
                'e_R',       e_R,          '   cells-1*hr−1';...
                
                '*kA',         kA,           '   cells';...
                '*j',                j,             '    cell-2*hour-1';...
                'kB',          kB,           '   cells';...
                
                '*n',           n,           '              -        ';...
                '*d',           d,           '   Molecules*cells-1*hr−1';...
                '*f',            f,           '   hr−1'};
            
columnname =   {'Parameters', '     Value          ', '           Units           '};
columnformat = {'char', 'numeric', 'char'}; 
uitable('Units','normalized',...
                 'Position', [0.57 0.2 0.394 0.4],... % [ Horizontal Location, Verticle location, Right Line, Bottom Line]
                 'Data', Fixed,...
                 'ColumnName', columnname,...
                 'ColumnFormat', columnformat,...
                 'RowName',[],...
                  'FontSize', 15,...
                 'ColumnWidth', {150 200 360});
end