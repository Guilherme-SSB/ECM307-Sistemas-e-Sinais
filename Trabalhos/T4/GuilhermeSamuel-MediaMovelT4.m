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
%%  3 - Automatizando H(z) - Lei de Formação
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

%% Análise da resposta em frequência da média móvel
%%%% Escolha um valor de N %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = input("Digite o valor de N: ");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Observação. 
%%% Para N = 5, foi observado mais harmônicos, o que implica em um 
%%% aumento dos pontos nulos

%%% Vetor linear auxiliar, com N-1 pontos
n = [0:1:N-1];

%%% Vetor de frequências
Np = Ng;
w = linspace(-pi*fs,pi*fs,Np);


%% Ganho em frequência da média móvel
%%% Realizando a somatória: H(w) = H(w) + e^(-j*w*T)^i
somatoria = 0;
for k=1:N
    somatoria = somatoria + exp(-1i*w*T).^n(k);
end

%%% Realizando o produto: H(w) = H(w) * 1/N
Hw = somatoria * (1/N);

%%% Visualizar
% GanhoMediaMovel  = Hw(w, T);
GanhoMediaMovel = Hw;
ModuloMediaMovel = abs(GanhoMediaMovel);
FaseMediaMovel   = angle(GanhoMediaMovel);

figure()
subplot(2,1,1); plot(w/(2*pi), ModuloMediaMovel);
xlabel('Frequencia em Hz') 
ylabel('Modulo')
title('Módulo e Fase do Filtro Média Móvel')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2,1,2); plot(w/(2*pi), FaseMediaMovel);
xlabel('Frequencia em Hz') 
ylabel('Fase')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

%%% Conclusões

% 1. Trata-se de um filtro passa-baixas
% 2. Tem dois nulos
% 3. Tem fase linear


%% Aplicando filtro ao sinal da gaita
%%% Função de transferência
Nd = [];
for i=1:N
    Nd(end+1) = 1/N;
end

Dd = [1];
for i=1:N-1
    Dd(end+1) = 0;
end

GanhoFiltro = tf(Nd, Dd, T);

yMediaMovel = filter(Nd, Dd, gk);

%%% Visualizando no tempo
figure()
subplot(2, 1, 1); plot(tempo, gk);
xlabel('Tempo [s]')
ylabel('Entrada')
title('Sinal original x Sinal filtrado')

subplot(2, 1, 2); plot(tempo, yMediaMovel);
xlabel('Tempo [s]')
ylabel('Saída')
grid


%%% Visualizando na frequência
gkF = fft(gk);
gkF = fftshift(gkF);

figure()
subplot(2, 1, 1); plot(w/(2*pi), ModuloMediaMovel);
xlabel('Frequência [Hz]')
title('Filtro')
axis([-2000 2000 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2, 1, 2); plot(w/(2*pi), real(gkF));
xlabel('Frequência [Hz]')
title('Sinal de saída')
axis([-2000 2000 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);


%% Criando sinal artificial
%   gkArtificial[k] = cos(w1*tempo) e w1 --> zero da Transfer Function

%%% Determinando os zeros do ganho
zeros       = roots(Nd);

ModuloZeros = abs(zeros);
FaseZeros   = angle(zeros);

%%% Frequência angula do zero, pela teoria
ws = 2*pi*fs;
w1 = FaseZeros(1)*ws/(2*pi);

f1 = w1/(2*pi);

%%% Gerando o sinal artifical gkArtificial
gkArtificial = sin(w1*tempo);

%%% Aplicando o filtro
YMediaMovelArtificial = filter(Nd, Dd, gkArtificial);

%%% Visualizando no tempo
figure()
subplot(2, 1, 1); plot(tempo, gkArtificial);
xlabel('Tempo [s]')
title('Entrada')
axis([0 1 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2, 1, 2); plot(tempo, YMediaMovelArtificial);
xlabel('Tempo [s]')
title('Saída')
axis([0 1 -inf inf])
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);
grid


%%% Visualizando na frequência
gkFArtificial = fft(gkArtificial);
gkFArtificial = fftshift(gkFArtificial);

figure()
subplot(2,1,1); plot(w/(2*pi), ModuloMediaMovel);
xlabel('Frequencia em Hz') 
ylabel('Modulo')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);

subplot(2,1,2); plot(w/(2*pi), real(gkFArtificial));
xlabel('Frequencia em Hz') 
ylabel('Modulo')
set(findall(gcf,'Type','line'),'LineWidth',3);
set(gca,'FontSize',14,'LineWidth',2);


