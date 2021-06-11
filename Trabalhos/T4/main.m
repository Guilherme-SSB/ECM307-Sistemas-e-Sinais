%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0 - Projeto de filtro e sintese de voz
%% 
%% a. projetar um filtro digital de fc = 1000Hz e aplicar ao sinal gaita.wav
%%
%%
%%  04 de junho de 2021
%%
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
%%  2 - Sinal: calibração e sinal real
%%
%%  trabalhar com um sinal amostrado
%% 
%%  trabalhar com um sinal real - gaita - hamônica (série temporal, qualquer)

[gk,fs] = audioread ('gaita.wav');      % transformei um arquivo .wav em um vetor x[k]
 
fmax    = fs/2;

Ng      = length(gk);
T       = 1/fs;
tempo   = linspace(0, Ng*T, Ng);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  3 - Análise da resposta em frequência da média móvel
%%
%%  y(k) = (1/3) * [g[k] + g[k-1] + g[k-2]]
%%
%%  Y(z)/G(z) = (1/3) * [1 + z^(-1) + z^(-2)]
%%
%%  z = e^(jwT)
%%
 
%%% Ganho em frequência da média móvel
Hw = @(w, T) (1/3)*(1 + exp(-1i*w*T) + exp(-2*1i*w*T));

%%% Amostragem - T
T  = 1/fs;   

%%% Vetor de frequências
Np = Ng;  
w  = linspace(-pi*fs, pi*fs, Np);

%%% Visualizar
GanhoMediaMovel  = Hw(w, T);

ModuloMediaMovel = abs(GanhoMediaMovel);
FaseMediaMovel   = angle(GanhoMediaMovel);

figure()
subplot(2, 1, 1); plot(w/(2*pi), ModuloMediaMovel);
xlabel('Frequência [Hz]')
title('Módulo da Média Móvel')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2, 1, 2); plot(w/(2*pi), FaseMediaMovel);
xlabel('Frequência [Hz]')
title('Fase da Média Móvel')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);


%%% Conclusões

% 1. Trata-se de um filtro passa-baixas
% 2. Tem dois nulos
% 3. Tem fase linear


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  4 - Aplicando o filtro ao sinal da gaita
%%
%%  

Nd = [1/3 1/3 1/3];
Dd = [1 0 0];

GanhoFiltroMediaMovel = tf(Nd, Dd, T)

yMediaMovel = filter(Nd, Dd, gk);

%%% Visualizando no tempo
figure()
subplot(2, 1, 1); plot(tempo, gk);
xlabel('Tempo [s]')
title('Entrada')

subplot(2, 1, 2); plot(tempo, yMediaMovel);
xlabel('Tempo [s]')
title('Saída')
grid

%%% Visualizando na frequência
GkF = fft(gk);
GkF = fftshift(GkF);

figure()
subplot(2, 1, 1); plot(w/(2*pi), ModuloMediaMovel);
xlabel('Frequência [Hz]')
title('Filtro')
axis([-2000 2000 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2, 1, 2); plot(w/(2*pi), GkF);
xlabel('Frequência [Hz]')
title('Saída')
axis([-2000 2000 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  5 - Criando o sinal artificial
%%
%%  g1[k] = cos(w1*tempo)   e w1 --> zero da transfer function
%%
%%

%%% Determinando os zeros do ganho
zeros       = roots(Nd);
ModuloZeros = abs(zeros);
FaseZeros   = angle(zeros); %+120 e -120 graus



%%% Frequência angular do zero, pela teoria
ws = 2*pi*fs;
w1 = FaseZeros(1)*ws/(2*pi);
f1 = w1/(2*pi);

%%% Gerando o sinal gk1
gk1 = sin(w1*tempo);

%%% Aplicando o filtro
yMM1 = filter(Nd, Dd, gk1);

%%% Visualizando no tempo
figure()
subplot(2, 1, 1); plot(tempo, gk1);
xlabel('Tempo [s]')
title('Entrada')
axis([0 0.001 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2, 1, 2); plot(tempo, yMM1);
xlabel('Tempo [s]')
title('Saída')
axis([0 0.001 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);
grid




