%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Guilherme Samuel de Souza Barbosa
%%  RA: 19.00012-0
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  0 - Projeto de filtro e sintese de voz
%% 
%%  a. projetar um filtro digital de fc = 1000Hz e aplicar ao sinal gaita.wav mesmo gráfico.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  2 - Sinal: calibração e sinal real
%%
%%  trabalhar com um sinal amostrado
%% 
%%  trabalhar com um sinal real - gaita - hamônica

[gk,fs] = audioread ('gaita.wav');      % transformei um arquivo .wav em um vetor g(k)
 
fmax    = fs/2;
Ng      = length(gk);
T       = 1/fs;
 
tempo   = linspace(0,Ng*T,Ng);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  3 - Filtro média móvel para N = 5
%%
%%  y(k)      = [g[k] + g[k-1] + g[k-2] + g[k-3] + g[k-4]] * (1/5)
%%  y(z)      = (G(z) + G(z)z^(-1) + G(z)z^(-2) + G(z)z^(-3) + G(z)z^(-4)) * (1/5)
%%  y(z)      = G(z)/5 * (z^0 + z^(-1) + z^(-2) + z^(-3) + z^(-4))
%%  y(z)/G(z) = G(z)/5 * ((z^4 + z^3 + z^2 + z^1 + z^0) / (z^4))
%%  H(z)      = 1/5 * ((z^4 + z^3 + z^2 + z^1 + z^0) / (z^4))
%%  
%%  z = e^(jwT)

%%% Ganho em frequência da média móvel
Hw = @(w, T) (1/5)*(1 + exp(-1i*w*T) + exp(-2*1i*w*T) + exp(-3*1i*w*T) + exp(-4*1i*w*T));

%%% Amostragem
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

Nd = [1/5 1/5 1/5 1/5 1/5];
Dd = [1 0 0 0 0];

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
%%  X - Automatizando H(z)
%%
%%  Para N = 3: H(z) = 1/3 * [z^(0) + z^(-1) + z^(-2)]
%%
%%  Para N = 5: H(z) = 1/5 * [z^(0) + z^(-1) + z^(-2) + z^(-3) + z^(-4)]
%%
%%  Ou seja, dado um valor de N, temos:
%%  
%%  H(z) = 1/N * ( sum_{i=0}^{N-1} z^i / z^{N-1} )
%%
%%  Como, z = e^(jwT):      
%%
%%      H(w) = 1/N * sum_{i=0}^{N-1} (e^(-j*w*T))^i
%%
%%  

%%% Escolha um valor de N: 
N = 5;

%%% Ganho em frequência da média móvel




 
 