clc
clear all
close all

Dados = readtable('Dados.xlsx','PreserveVariableNames',true);  
% Espera-se que 'Dados.xlsx' tenha colunas:  f0, f1, f2, Vogal ,Voz, Nome, RA      

sum(ismissing(Dados))   % Verifica se há dados faltantes

Dados = Dados(:, 1:5);  % Exclui as colunas 'Nome' e 'RA'

vogal = Dados.Vogal;
f0    = Dados.f0;
f1    = Dados.f1;
f2    = Dados.f2;
voz   = Dados.Voz;

a = strings;
e = strings;
i = strings;
o = strings;
u = strings;


for k=1:length(vogal)
    if ismember(vogal(k), 'a')
        a(k) = cell2mat(vogal(k));
    elseif ismember(vogal(k), 'e')
        e(k) = cell2mat(vogal(k));      
    elseif ismember(vogal(k), 'i')
        i(k) = cell2mat(vogal(k));
    elseif ismember(vogal(k), 'o')
        o(k) = cell2mat(vogal(k));        
    elseif ismember(vogal(k), 'u')
        u(k) = cell2mat(vogal(k));        
    else disp('\nVogal Inválida')
    end
end
Na = length(a);
a = double.empty;
a = Dados(1:Na, 1:3);

Ne = length(e);
e = double.empty;
e = Dados(Na+1:Ne, 1:3);

Ni = length(i);
i = double.empty;
i = Dados(Ne+1:Ni, 1:3);

No = length(o);
o = double.empty;
o = Dados(Ni+1:No, 1:3);

Nu = length(u);
u = double.empty;
u = Dados(No+1:Nu, 1:3);

%% Escolha da vogal de análise
ANALISE_A = true;
ANALISE_E = false;
ANALISE_I = false;
ANALISE_O = false;
ANALISE_U = false;

%% Gráfico de dispersão dos valores originais
f1_A = table2array(a(:,2));
f2_A = table2array(a(:,3));

f1_E = table2array(e(:,2));
f2_E = table2array(e(:,3));

f1_I = table2array(i(:,2));
f2_I = table2array(i(:,3));

f1_O = table2array(o(:,2));
f2_O = table2array(o(:,3));

f1_U = table2array(u(:,2));
f2_U = table2array(u(:,3));

figure(1)
scatter(f1_A, f2_A)
hold on
scatter(f1_E, f2_E)
hold on
scatter(f1_I, f2_I)
hold on
scatter(f1_O, f2_O)
hold on
scatter(f1_U, f2_U)
hold on
title('Dispersão de f1 e f2 para cada vogal')
legend('Vogal /a/', 'Vogal /e/', 'Vogal /i/', 'Vogal /o/', 'Vogal /u/')


%%  Histograma da vogal de análise
%%% f1
figure(2)
if (ANALISE_A == 1)
    histogram(f1_A, round(sqrt(length(f1_A))))
elseif (ANALISE_E == 1)
    histogram(f1_E, round(sqrt(length(f1_E))))
elseif (ANALISE_I == 1)
    histogram(f1_I, round(sqrt(length(f1_I))))
elseif (ANALISE_O == 1)
    histogram(f1_O, round(sqrt(length(f1_O))))
else (ANALISE_U);
    histogram(f1_U, round(sqrt(length(f1_U))))
end
xlabel('Eixo x')
ylabel('Eixo y')
title('Histograma de f1 da vogal escolhida')
grid

%%% f2
figure(3)
if (ANALISE_A == 1)
    histogram(f2_A, round(sqrt(length(f2_A))))
elseif (ANALISE_E == 1)
    histogram(f2_E, round(sqrt(length(f2_E))))
elseif (ANALISE_I == 1)
    histogram(f2_I, round(sqrt(length(f2_I))))
elseif (ANALISE_O == 1)
    histogram(f2_O, round(sqrt(length(f2_O))))
else (ANALISE_U);
    histogram(f2_U, round(sqrt(length(f2_U))))
end
xlabel('Eixo x')
ylabel('Eixo y')
title('Histograma de f2 da vogal escolhida')
grid


%%  Plotando o box plot de análise
if (ANALISE_A == 1)
   A = [f1_A; f2_A];
   g = [ones(size(f1_A)); 2*ones(size(f2_A))];
elseif (ANALISE_E == 1)
   A = [f1_E; f2_E];
   g = [ones(size(f1_E)); 2*ones(size(f2_E))];
elseif (ANALISE_I == 1)
   A = [f1_I; f2_I];
   g = [ones(size(f1_I)); 2*ones(size(f2_I))];
elseif (ANALISE_O == 1)
   A = [f1_O; f2_O]; 
   g = [ones(size(f1_O)); 2*ones(size(f2_O))];
else (ANALISE_O);
   A = [f1_U; f2_U];
   g = [ones(size(f1_U)); 2*ones(size(f2_U))];
end

figure(4)
boxplot(A, g);
set(gca,'XTickLabel',{'f1','f2'})
title('Box Plot da vogal escolhida')
grid


%%  Determinando média e desvio padrão de cada frequência de cada vogal
%%mean()
%%std()

%%  Removendo os Outliers observados no box plot


%%  Reconhendo os padrões de f1 e f2

%%% Feature Scalling → Standardisation: resultado entre -3 e +3

Dados_freq = table2array(Dados(:, 1:3));

Dados_freq(:,1) = (Dados_freq(:,1)-mean(Dados_freq(:,1))/std(Dados_freq(:,1)));
Dados_freq(:,2) = (Dados_freq(:,2)-mean(Dados_freq(:,2))/std(Dados_freq(:,2)));
Dados_freq(:,3) = (Dados_freq(:,3)-mean(Dados_freq(:,3))/std(Dados_freq(:,3)));


%%% Plotando os clusters que o knn identificou

idx = kmeans(Dados_freq, 5);

figure(5)
gscatter(Dados_freq(:,2), Dados_freq(:,3), idx)
legend('Vogal /a/', 'Vogal /e/', 'Vogal /i/', 'Vogal /o/', 'Vogal /u/')
grid

%%% Treinando o modelo

modelformed = fitcknn(Dados, 'Vogal~f1+f2');
modelformed.NumNeighbors=10;

predict(modelformed, [1403.5,3811.9])

