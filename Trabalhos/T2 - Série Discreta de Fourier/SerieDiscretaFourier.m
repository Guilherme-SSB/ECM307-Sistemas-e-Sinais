%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0 - Proposta de trabalho
%% 
%% a. Analisar as 5 vogais: Xa, Xe, Xi, Xo, Xu (Fourier de cada vogal, Figura 3)
%% b. Os tempos de execução de cada vogal
%% c. O que você observa de diferente em cada Série de Fourier? Qualitativamente
%% d. Você conseguiria analisar no tempo? (Mesma conclusão sem Fourier?)
%% e. Como você transformaria o for em um produto matricial como feito na teoria? (Assunto da proxima aula)
%%
%% Entrega: 23/03 até 23:59 - individual


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1 - Preparação do código 
%% 
%% Boas práticas: limpeza de variáveis; variáveis globais
%% Constantes; carregar bibliotecas;...
%%
%%% Limpeza

clc;          % limpa visual da tela de comandos
close all;    % limpa as figuras
clear all;    % limpa as variáveis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2 - Problema
%%
%% Sinal g[k] - sinal amostrado
%%

%%% Sinal de referência - artificial (eu sei a resposta, util para calibrar
%%% a analise)
%%% Trabalhar com senóides

fs = 10;                                         % Frequencia de amostragem, f0 < 5
fo = 1;                                          % Frequencia da senoide
%%% Frequencia de amostragem é 10 vezes maior
To = 1/fo;                                       % Período da senoide
wo = 2*pi*fo;                                    % Frequência angular
Np = 10;                                         % Número de períodos

tempo = linspace(0, Np*To, Np*fs);               % Tempo de síntese

gk = 1 + cos(2*pi*tempo);      % Senoide artificial
% Somando 1, temos um cosseno mais um nivel medio

%%% Visualizacao
figure(1)

stem(tempo, gk,'k-','linewidth', 2)              % configura plot(x,y, cor azul e linha cheia)
xlabel('Tempo em segundos')                      % tempo em segundos
ylabel('Amplitude')                              % amplitude em volts
title('Sinal g(k) sintetizado')                  % título
grid


%%% Sinal a ser trabalhado - gk
% [gk, fs] = audioread('a.wav');   % Leitura de um sinal real - vogal /a/.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  3 - Pré - processamento do sinal
%%  
%%  X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N)
%%

N             = length(gk);                     % Número de pontos do g(k)
Ts            = 1/fs;                           % Taxa de amostragem
Duracao_Sinal = N*Ts;                           % Duração do sinal g(k)
ws            = 2*pi*fs;                        % Frequência angular
tempo         = linspace(0, Duracao_Sinal, N);  % Vetor tempo computacional
fmax          = fs/2;                           % Frequência máxima
frequencia    = linspace(-fmax, +fmax, N);      % Frequências de interesse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4 -  Cálculo do X[n]
%%
%% X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N) -> Série de Fourier
%%
%%

%%% Primeira forma: utilizando estrutura for

tic;                                                 % Inicia um contador de tempo

for n = 0: N-1                                       % N pontos
    
    aux_k = 0;                                       % Valor inicial de aux_k
    
    for k = 0: N-1                                   % Lendo N pontos      
        aux_k = aux_k + gk(k+1)*exp(-1i*n*k*2*pi/N);
    end
    
% 1 : N --> matlab
% +1 --> transformo a variável matemática em indíce

    Xn(n+1) = aux_k;
end
    
toc;                                                 % Determina o tempo decorrido

%%% Segunda forma: utilizando algebra linear (mais eficiente!!!)

tic;                                                 % Inicia um contador de tempo



toc;                                                 % Determina o tempo decorrido


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  6 -  Visualização
%%
%%

figure(2)

plot(tempo, gk,'k-','linewidth', 2)         % configura plot(x,y, cor azul e linha cheia)
xlabel('Tempo em segundos')                 % tempo em segundos
ylabel('Amplitude')                         % amplitude em volts
title('Sinal g(k) amostrado')               % título
grid

figure(3)

%%% fftshift rotaciona o vetor: 0 --> 2*pi ; -pi --> + pi
stem(frequencia, fftshift(abs(Xn)),'b-','linewidth', 1)           % configura plot(x,y, cor azul e linha cheia)
xlabel('Frequência em Hz')                  % tempo em segundos
ylabel('Amplitude')                         % amplitude em volts
title('Espectro de amplitude')              % título
grid


