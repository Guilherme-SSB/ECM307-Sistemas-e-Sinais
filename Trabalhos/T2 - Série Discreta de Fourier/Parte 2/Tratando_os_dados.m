clc
clear all
close all


dataset = readmatrix('dataset_vogais.xlsx');

a = dataset(1:15, (1:3));
e = dataset(16:27, (1:3));
i = dataset(28:39, (1:3));
o = dataset(40:54, (1:3));
u = dataset(55:end, (1:3));

%% Escolha da vogal de análise
ANALISE_A = false;
ANALISE_E = false;
ANALISE_I = true;
ANALISE_O = false;
ANALISE_U = false;


%% Gráfico de dispersão dos valores originais
f1_A = a(:,2);
f2_A = a(:,3);

f1_E = e(:,2);
f2_E = e(:,3);

f1_I = i(:,2);
f2_I = i(:,3);

f1_O = o(:,2);
f2_O = o(:,3);

f1_U = u(:,2);
f2_U = u(:,3);

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


%%  Removendo os Outliers observados no box plot
a_tratada = rmoutliers(a, 'quartiles');
e_tratada = rmoutliers(e, 'quartiles');
i_tratada = rmoutliers(i, 'quartiles');
o_tratada = rmoutliers(o, 'quartiles');
u_tratada = rmoutliers(u, 'quartiles');

%%%TODO: média e desvio padrão de f0, f1 e f2 de cada vogal



%% Reconhendo os padrões de f1 e f2
%%% Utilizaremos o algoritmo k-means clustering
%%% https://www.mathworks.com/help/stats/kmeans.html






