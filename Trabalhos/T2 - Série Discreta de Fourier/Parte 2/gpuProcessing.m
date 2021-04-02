%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Guilherme Samuel de Souza Barbosa
%%  RA: 19.00012-0
%%
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
%%  Ou seja, modelo de ML gera um vetor [1 1 0 0 1]: acertou /a/, /e/ e /u/ e errou /i/ e /o/
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
gk = gpuArray(gk);                                 
                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  3 - Pré - processamento do sinal
%%  
%%  X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N)
%%
disp('3 - Extraindo informações do sinal ...')

N                 = length(gk);                                   % Número de pontos do vetor  
Ts                = 1/fs;                                         % Intervalo de amostragem
Duracao_Sinal     = N*Ts;                                         % Duração do sinal em segundos
tempo             = gpuArray.linspace(0, Duracao_Sinal, N);       % Vetor tempo
fmax              = fs/2;                                         % Frequência máxima, respeitando Teorema da Amostragem
frequencia        = gpuArray.linspace(-fmax, +fmax, N);           % Vetor de frequência de N pontos

fprintf('\nO sinal tem duração de %.3f segundos\n\n', Duracao_Sinal)

figure(1)

plot(tempo, gk)     
xlabel('Tempo em segundos')           
ylabel('Amplitude')                  
title('Sinal g(k) amostrado')    
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  4 - Janelamento
%%
%%
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
disp('4 - Calculando a série de Fourier do sinal por produto matricial ...')

tic;                                                                                 % inicia o contador

wn                 = exp(-1i*2*pi/N);                                                % Definindo wn
Matriz_jotas       = wn*gpuArray(ones(N, N));                                        % Cria a matriz de coeficientes
n                  = gpuArray([0:1:N-1]');
k                  = gpuArray([0:1:N-1]);
Matriz_expoentes   = n*k;                                                            % Matriz dos expoentes          
Wn                 = Matriz_jotas.^Matriz_expoentes;                                 % Matriz de Fourier - constante para N fixo
%Xn  = Wn * gk;                                                                      % Série discreta de Fourier
Xn  = Wn * Janelado;                                                                 % Série discreta de Fourier

toc;                                                                                 % termina o contador


figure(3)

plot(frequencia, fftshift(log10(abs(Xn))), 'k-', 'linewidth', 2)
xlabel('Frequência em Hertz')           
ylabel('Amplitude')                  
title('Espectro de Amplitudes - Entrada')    
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  6 - Filtragem do ruído 
%%
%%
Ganho = @(w, R, C) 1./(1i*w*R*C + 1);
R = 1;
C = 1;

filtrado = Ganho(2*pi*fs, R, C).*Xn;

%figure(4)

%plot(frequencia, fftshift(log10(abs(filtrado))), 'k-', 'linewidth', 2)
%xlabel('Frequência em Hertz')           
%ylabel('Amplitude')                  
%title('Espectro de Amplitudes - Filtrado')    
%grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  7 - Encontrar f0, f1, f2 para cada vogal gravada por mim
%%
%%  fo = 161,4 Hz
%%  f1 = 640,0 Hz
%%  f2 = 958,2 Hz
%%  f3 = 2643,0 Hz


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  8 - Histograma
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  9 - Tratar Outliers
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  10 - Modelo de decisão
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  11 - Verificação do modelo
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  12 -  Visualização
%%
%%







