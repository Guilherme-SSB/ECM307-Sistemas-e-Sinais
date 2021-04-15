%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Guilherme Samuel de Souza Barbosa
%%  RA: 19.00012-0
%%
%%  Link do Github: encurtador.com.br/axE79
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  0 - Proposta 
%% 
%%  a. Cada aluno determina as frequências f0, f1 e f2 da sua própria gravação (3x) - cada vogal gera 9 valores => 45 valores no total
%%  b. Formar base de conhecimento Número de alunos x 45
%%  c. Histograma de cada vogal - média e o desvio padrão de cada frequência para cada vogal (espera-se distribuição gaussiana)
%%  d. Eliminar valores fora de contexto e verificar diferenças da base - Tratamento dos Outliers
%%  e. Gravar 5 vogais que não serão usadas na base (vogais_teste)
%%  f. 1 - Acertou e 0 - Errou -> a, e, i, o, u
%%      Ou seja, modelo de ML gera um vetor [1 1 0 0 1]: acertou /a/, /e/ e /u/ e errou /i/ e /o/
%%  g. Verificar qualidade do sistema de aprendizado para cada vogal
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  1 - Preparação do código 
%% 
%%  Boas práticas: limpeza de variáveis; variáveis globais
%%  Constantes; carregar bibliotecas;...
%%
%%% Limpeza

clc;          % limpa visual da tela de comandos
close all;    % limpa as figuras
clear all;    % limpa as variáveis

disp('1 - Preparando o código ...')

%%% Omite mensagens de warning
warning('off')   % Não mostra eventos de warning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  2 - Problema
%% 
%%  Sinal g[k] - Sinal amostrado
%%

%%% Importação dos Sinais
disp('2 - Importando os sinais das vogais ...')

[gk, fs] = audioread('a/a1.wav');  
                                 % gk ← vetor do sinal amostrado
                                 % fs ← frequência de amostragem
                                 
gk = reshape(gk, [], 1);         
gk = gk(1:length(gk)/2);         % Separa apenas o lado esquerdo do audio


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  3 - Pré - processamento do sinal
%%  
%%  X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N)
%%
disp('3 - Extraindo informações do sinal ...')

N                 = length(gk);                      % Número de pontos do vetor  
Ts                = 1/fs;                            % Intervalo de amostragem
Duracao_Sinal     = N*Ts;                            % Duração do sinal em segundos
tempo             = linspace(0, Duracao_Sinal, N);   % Vetor tempo
fmax              = fs/2;                            % Frequência máxima, respeitando Teorema da Amostragem
frequencia        = linspace(-fmax, +fmax, N);       % Vetor de frequência de N pontos
To                = tempo(2)-tempo(1);

fprintf('O sinal tem duração de %.3f segundos\n\n', Duracao_Sinal)

figure(1)

plot(tempo, gk)     
xlabel('Tempo em segundos')           
ylabel('Amplitude')                  
title('Sinal g(k) amostrado')    
grid

%%%%%%%%%%%%%%%%
% Item 4 do T2 
%%%%%%%%%%%%%%%%
fprintf('Item 4. Análise Temporal\nSim, como visto na "Figure 1 - Sinal g(k) amostrado", é nítido que há periodicidade do sinal no domínio temporal\n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  4 - Janelamento
%%
%%
disp('4 - Realizando o janelamento do sinal ...')

Janelado = gk.*hanning(N);

figure(2)

plot(tempo, Janelado)
xlabel('Tempo em segundos')           
ylabel('Amplitude')                  
title('Sinal g(k) janelado')    
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  5 - Fourier
%%  
%%  X[n] =  exp(-1i*2*pi/N)*ones(N, N).^([0:1:N-1]'*[0:1:N-1]) -> Produto Matricial
%%
disp('5 - Calculando a série de Fourier do sinal por produto matricial ...')

tic;                                                   % inicia o contador

wn                = exp(-1i*2*pi/N);                   % Definindo wn
Matriz_jotas      = wn*ones(N, N);                     % Cria a matriz de coeficientes
Matriz_expoentes  = [0:1:N-1]'*[0:1:N-1];              % Matriz dos expoentes          
Wn                = Matriz_jotas.^Matriz_expoentes;    % Matriz de Fourier - constante para N fixo
Xn  = Wn * Janelado;                                   % Série discreta de Fourier

toc;                                                   % termina o contador

figure(3)

plot(frequencia, fftshift(log10(abs(Xn))), 'k-', 'linewidth', 2)
xlabel('Frequência em Hertz')           
ylabel('Amplitude')                  
title('Espectro de Amplitudes')    
grid

%%%%%%%%%%%%%%%%
% Item 5 do T2 
%%%%%%%%%%%%%%%%
fprintf('\nItem 5. Análise de Fourier\nSim, a periodicidade do sinal no domínio temporal é justificada pela aparição de harmônicas no domínio da frequência, como mostra a "Figure 3 - Espectro de Amplitudes"\n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  6 - Encontrar f0, f1, f2
%%  
%%  https://octave.sourceforge.io/signal/function/findpeaks.html
%%
disp('6 - Determinando os picos de energia no domínio da frequência ...')

data = fftshift(log10(abs(Xn)));
f    = frequencia(2) - frequencia(1);

[picos, index] = findpeaks(data, frequencia, "MinPeakDistance", f);     % Seleciona todos os picos do sinal

pks_positivos = double.empty;
locs_positivos = double.empty;

% Separa as possíveis formantes => Apenas os valores de frequência positivos
for i=1:length(index)
    if index(i) > 0
        pks_positivos(end+1) = picos(i);
        locs_positivos(end+1) = index(i);
    end  
end

% Seleciona todos os picos do sinal que estão a pelo menos 50 Hz de diferença um do outro.
% Observação. 50 Hz foi determinado pela menor diferença entre f2 e f1 no dataset
[index_formantes, picos_formantes] = findpeaks(pks_positivos, locs_positivos, "MinPeakDistance", 50);    


figure(4)       % Imprime o gráfico que auxiliará na determinação das formantes
findpeaks(pks_positivos, locs_positivos, "MinPeakDistance", 50);
xlabel('Frequência em Hertz')           
ylabel('Amplitude')
title('Picos do Sinal')
grid

%%%%%%%%%%%%%%%%
% Item 6 do T2 
%%%%%%%%%%%%%%%%
fprintf('\nItem 6. Formantes\nOs pontos de pico do sinal podem ser vistos na "Figure 4 - Picos do Sinal"\n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  7 - Trabalhando com os dados gerados
%%
%%
disp('7 - Preparando a base de conhecimento ... ')


%% Importando os dados
Dados = readtable('Dados.xlsx', 'PreserveVariableNames', true);  
% Espera-se que 'Dados.xlsx' tenha colunas:  f0, f1, f2, Vogal ,Voz, Nome, RA


%% Verificando se há valores faltantes
missing_values = sum(ismissing(Dados));
fprintf('\nA base de dados tem %i valores faltantes\n\n', sum(missing_values))


%% Excluindo as colunas 'Nome' e 'RA'
Dados = Dados(:, 1:5);  


%% Separando os dados por vogal
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
    else fprint('Vogal Inválida');
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  8 - Análise Estatística
%%
%%
disp('8 - Realizando a análise estatística dos dados ...')


%% Escolha da vogal de análise
disp('Na linha 237:241 do código, escolha a vogal que deseja ver os gráficos e informações estatísticas')
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

figure(5)
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
xlabel('Formante f1 [Hz]')
ylabel('Formante f2 [Hz]')
title('Dispersão de f1 e f2 para cada vogal')
legend('Vogal /a/', 'Vogal /e/', 'Vogal /i/', 'Vogal /o/', 'Vogal /u/')
grid


%%  Histograma da vogal de análise
%%% f1
figure(6)
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
xlabel('Formante f1 [Hz]')
ylabel('Frequência')
title('Histograma de f1 da vogal escolhida')
grid

%%% f2
figure(7)
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
xlabel('Formante f2 [Hz]')
ylabel('Frequência')
title('Histograma de f2 da vogal escolhida')
grid
 

%%  Box plot de análise
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

figure(8)
boxplot(A, g);
set(gca,'XTickLabel',{'f1','f2'})
ylabel('Heartz')
title('Box Plot da vogal escolhida')
grid


%%  Determinando média e desvio padrão de cada frequência de cada vogal
if (ANALISE_A == 1)
   fprintf('\nInformações da vogal /a/')
   media_f1 = mean(f1_A); 
   std_f1   = std(f1_A);
   media_f2 = mean(f2_A);
   std_f2   = std(f2_A);
   
elseif (ANALISE_E == 1)
   disp('\nInformações da vogal /e/')
   media_f1 = mean(f1_E); 
   std_f1   = std(f1_E);
   media_f2 = mean(f2_E);
   std_f2   = std(f2_E);
   
elseif (ANALISE_I == 1)
   disp('\nInformações da vogal /i/')
   media_f1 = mean(f1_I); 
   std_f1   = std(f1_I);
   media_f2 = mean(f2_I);
   std_f2   = std(f2_I);
   
elseif (ANALISE_O == 1)
   disp('\nInformações da vogal /o/')
   media_f1 = mean(f1_O); 
   std_f1   = std(f1_O);
   media_f2 = mean(f2_O);
   std_f2   = std(f2_O);
   
else (ANALISE_O);
   disp('\nInformações da vogal /u/')
   media_f1 = mean(f1_U); 
   std_f1   = std(f1_U);
   media_f2 = mean(f2_U);
   std_f2   = std(f2_U);
end 

fprintf('\nPara a formante f1, a média é %.2f e o desvio padrão é %.2f', media_f1, std_f1)
fprintf('\nPara a formante f2, a média é %.2f e o desvio padrão é %.2f\n\n', media_f2, std_f2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  9 - Preparando os dados para o modelo de decisão
%%
%%
disp('9 - Preparando os dados que alimentarão os modelos de decisão ...')

%% Enconding categorical data

labels_originais = table2array(Dados(:, 4));    % Possui os labels categoricos

labels_tratados = double.empty;                 % Inicia o vetor com os labels númericos

%%% Preenche o vetor 'labels_tratados' 
for i=1:length(labels_originais)
    if strcmp(labels_originais(i), 'a')
        labels_tratados(i) = 1;
        
    elseif strcmp(labels_originais(i), 'e')  
        labels_tratados(i) = 2;
        
    elseif strcmp(labels_originais(i), 'i')  
        labels_tratados(i) = 3;
    
    elseif strcmp(labels_originais(i), 'o')  
        labels_tratados(i) = 4;        
    
    else 
        labels_tratados(i) = 5;
    end
end
labels_tratados = transpose(labels_tratados);

%% Criação da base de dados para o modelo de decisão

Dados_ML = table2array(Dados(:, 1:3));
Dados_ML(:, 4) = labels_tratados;


%% Removendo os outliers
Dados_ML = rmoutliers(Dados_ML, 'quartiles');

%% Pela própria documentação do MATLAB, o método 'quartiles' define os outliers 
%% como os elementos com mais de 1.5 * intervalos interquartílicos (IQR) acima do 
%% quartil superior ou abaixo que o quartil inferior

%%% Observação. Foi realizado o procedimento de Enconding dos dados
%%% categoricos antes de remover os outliers pois se o método `rmoutliers`
%%% receber uma matriz como parâmetro, ele já faz a remoção da linha
%%% inteira caso algum valor da coluna seja identificado como outlier, o
%%% que evita 'buracos' no dataset.


%% Selecionando a matriz de features e o vetor de labels
Dados_features = Dados_ML(:, 2:3);      % Matriz com colunas `f1` e `f2` 
Dados_labels   = Dados_ML(:, 4);        % Vetor com a implicação da relação entre f1 e f2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  10 - Modelo de decisão
%%  
%%  K-nearest neighbor classifier
%%
disp('10 - Criação do modelo de decisão ...')

%%%%%%%%%%%%%%%%
% Item 8 do T2 
%%%%%%%%%%%%%%%%
fprintf('\nItem 8. Reconhecimento de vogais\nSerão testados dois métodos, K-nearest neighbor classifier e mínima distância euclidiana em relação à média\n\n')

%% Dividindo em clusterings

idx = kmeans(Dados_features, 5);

figure(9)
gscatter(Dados_features(:, 1), Dados_features(:, 2), idx)               % Faz o plot dos clusters identificados pelo kmeans
xlabel('Formante f1 [Hz]')
ylabel('Formante f2 [Hz]')
title('Clusterização das vogais')

%% Treinando o modelo

modelformed = fitcknn(Dados_features, Dados_labels, 'NumNeighbors', 10, 'Standardize', 1);   % Treina o modelo k-nearest neighbor classifier


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  11 - Verificação do modelo K-nearest neighbor
%%
%%
disp('11 - Validação do modelo com os dados de teste ...')
fprintf('Altere o vetor `valor_teste` na linha 470 para testar o modelo com os seus valores!\n')

valor_teste = [1000, 2000];     % O vetor 'valor_teste' é composto pelas formantes [f1, f2] que se deseja testar o modelo

line(valor_teste(1), valor_teste(2), 'marker', 'x', 'color', 'k', 'markersize',10,'linewidth',2);   % Imprime o valor de teste no gráfico dos clusters

Md = KDTreeSearcher(Dados_features);    % Cria uma instância do objeto KDTreeSearcher

[n,d] = knnsearch(Md, valor_teste, 'k', 10);
line(Dados_features(n,1), Dados_features(n,2), 'color',[.5 .5 .5], 'marker', 'o', 'linestyle', 'none', 'markersize', 10)

ctr = valor_teste - d(end);
diameter = 2*d(end);

h = rectangle('position',[ctr,diameter,diameter], 'curvature',[1 1]);   % Desenha um circulo sobre os 10 vizinhos mais próximos
h.LineStyle = ':';

predicao = predict(modelformed, valor_teste);                           % Retorna a previsão do modelo com base no valor_teste


%% Convertando predição (1, 2, ..., 5) para sua respectiva vogal (a, e, ..., u)

if (predicao == 1)
    resposta = 'a';
    
elseif (predicao == 2)
    resposta = 'e';
    
elseif (predicao == 3)
    resposta = 'i';
    
elseif (predicao == 4)
    resposta = 'o';

else
    resposta = 'u';    
end

fprintf('\nCom os valores de teste informado, a predição pelo Knn foi: /%s/ \n', resposta)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  12 - Modelo de previsão por Álgebra Linear
%%
%%  A métrica adotada será a menor distância euclidiana do ponto de teste 
%% em relação a média do ponto [f1; f2] de cada vogal
%%
%% Plotando a média dos valores de f1 e f2 para cada vogal
media_f1 = [mean(f1_A); mean(f1_E); mean(f1_I); mean(f1_O); mean(f1_U)];
media_f2 = [mean(f2_A); mean(f2_E); mean(f2_I); mean(f2_O); mean(f2_U)];
c = [0 1 0; 1 0 0; 0.5 0.5 0.5; 0.6 0 1; 0.4 0.6 1];
idx_al = 1:5;

figure(10)
gscatter(media_f1(:, 1), media_f2(:, 1), idx_al)
xlabel('Formante f1 [Hz]')
ylabel('Formante f2 [Hz]')


%% Plotando o valor de teste
line(valor_teste(1), valor_teste(2), 'marker', 'x', 'color', 'k', 'markersize',10,'linewidth',2);

legend('Vogal /a/', 'Vogal /e/', 'Vogal /i/', 'Vogal /o/', 'Vogal /u/', 'Dado de teste')
title('Modelo preditivo por Álgebra Linear')
grid

%% Tomando a decisão
%%% Testando para /a/
a = dist(valor_teste, [mean(f1_A); mean(f2_A)]);

%%% Testando para /e/
e = dist(valor_teste, [mean(f1_E); mean(f2_E)]);

%%% Testando para /i/
i = dist(valor_teste, [mean(f1_I); mean(f2_I)]);

%%% Testando para /o/
o = dist(valor_teste, [mean(f1_O); mean(f2_O)]);

%%% Testando para /u/
u = dist(valor_teste, [mean(f1_U); mean(f2_U)]);

distancias_euclidianas = [a; e; i; o; u];
[minimo, index_minimo] = min(distancias_euclidianas);


%% Convertando predição (1, 2, ..., 5) para sua respectiva vogal (a, e, ..., u)

if (index_minimo == 1)
    resposta_al = 'a';
    
elseif (index_minimo == 2)
    resposta_al = 'e';
    
elseif (index_minimo == 3)
    resposta_al = 'i';
    
elseif (index_minimo == 4)
    resposta_al = 'o';

else
    resposta_al = 'u';    
end

fprintf('\nCom os valores de teste informado, a predição pela álgebra linear foi: /%s/ \n\n', resposta_al)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  13 - Resultados obtidos
%%
%%  Foi realizado a gravação de cada vogal mais uma vez, a fim de criarmos os dados de teste do modelo
%%  Para cada vogal nova, foi obtido o seguinte resultado:
%%
%%  Vogal /a/:
%%      f1 = 627.9
%%      f2 = 1165.7
%%
%%  Vogal /e/:
%%      f1 = 476.4
%%      f2 = 1882.2
%%
%%  Vogal /i/:
%%      f1 = 1735.9
%%      f2 = 2926.2
%%
%%  Vogal /o/:
%%      f1 = 500.5
%%      f2 = 864.77
%%
%%  Vogal /u/:
%%      f1 = 650.4
%%      f2 = 1875.2
%%
%%
%%  O modelo Knn acertou as vogais: /a/, /e/, /o/, /u/, ou seja, obteve uma precisão de 80%
%%  O modelo por Álgebra Linear acertou todas as vogais, ou seja, obteve uma precisão de 100%
%%  
%%  Portanto, 
%%    Pelo modelo por Álgebra Linear, o vetor gerado é [1 1 1 1 1] => Acertou as vogais /a/, /e/, /i/, /o/ e /u/
%%    Pelo modelo Knn, o vetor é [1 1 0 1 1] => Acertou as vogais /a/, /e/, /o/ e /u/ e errou a vogal /i/
%%



