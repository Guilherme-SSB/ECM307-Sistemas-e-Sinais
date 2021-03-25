%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guilherme Samuel de Souza Barbosa
%% RA: 19.00012-0
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1 - Preparação do código
%% 

clc;         % limpa visual da tela de comandos
close all;   % limpa as figuras
clear all;   % limpa as variáveis

disp('1 - Preparando o código ...')

%%% Carregar biblioteca simbólica

% pkg load symbolic;

%%% Omite mensagens de warning

warning('off') % Não mostra eventos de warning


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2 - Problema
%% 
%% Aproximar uma exponencial por uma Série Exponencial de Fourier
%%
 
disp('2 - Definindo o sinal g(t) ...')

To = 1;   % período da onda quadrada
to = 0;   % instante inicial de g(t)

%%% Cálculo dos demais parâmetros

fo = 1/To;      % frequência da onda quadrada
wo = 2*pi*fo;   % frequência angular de g(t)

%%% Função g(t) teórica

gtTeorico = @(t) exp(-t);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3 - Calcular o valor de Dn
%% 
%% Ambiente de cálculo integral e simbólico
%%
%% Symbolic pkg v2.9.0: 
%% Python communication link active, SymPy v1.5.1.
%%

disp('3 - Série de Fourier simbólica ...')

%%% Definindo as variáveis simbólicas

syms n t   % variáveis simbólicas

%%% Cálculo do numerador de Dn

Inum = int(exp(-(1 + 1i*wo*n)*t), t, to, To);

%%% Cálculo do Dn

Dn = Inum / To;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4 - Avaliando projeções
%% 

n = [-1 0 +1];           % Valores de n para análise da primeira harmônica

DnNumerico = eval(Dn);   % Substitui os valores de 'n' em 'Dn'

%%% Sintetizando a 1º harmônica

M = 1000;                       % resolução do sinal
tempo = linspace(-To, To, M);   % Intervalo de análise com M pontos

cMinus1 = DnNumerico(1)*exp(n(1)*1i*wo*tempo);   % Cálculo do c_{-1}
c0 = DnNumerico(2)*exp(n(2)*1i*wo*tempo);        % Cálculo do c_{0}
c1 = DnNumerico(3)*exp(n(3)*1i*wo*tempo);        % Cálculo do c_{+1}

p1 = cMinus1 + c0 + c1;   % Primeira harmônica


%%% Compararando a 1º harmônica com o sinal teórico

tempo1 = linspace(0, To, M/2);

gtNumerico = [gtTeorico(tempo1) gtTeorico(tempo1)];   % O valor númerico teórico da onda


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5 - Visualizando a aproximação
%% 

figure(1)
plot(tempo, gtNumerico, 'b', 'linewidth', 2);   % g(t) Teórico
hold on;
plot(tempo, p1, 'k-', 'linewidth', 2);          % g(t) Aproximado      
xlabel('Tempo em segundos');
ylabel('Amplitude');
legend('Sinal teórico', 'Primeira Harmônica');
title('1º harmônica - Função teórica')
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6 - Avaliando novas projeções
%% 

n = [-2 +2];             % Valores de n para análise da segunda harmônica

DnNumerico = eval(Dn);   % Substitui os valores de 'n' em 'Dn'

%%% Sintetizando a 2º harmônica

M = 1000;                       % resolução do sinal
tempo = linspace(-To, To, M);   % Intervalo de análise com M pontos

cMinus2 = DnNumerico(1)*exp(n(1)*1i*wo*tempo);   % Cálculo do c_{-2}
c2 = DnNumerico(2)*exp(n(2)*1i*wo*tempo);        % Cálculo do c_{+2}

p2 = p1 + cMinus2 + c2;   % Segunda harmônica

%%% Comparar a 2º harmônica com o sinal teórico

tempo1 = linspace(0, To, M/2);

gtNumerico = [gtTeorico(tempo1) gtTeorico(tempo1)];   % O valor númerico teórico da onda


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7 - Cálculo dos resíduos r1(t) e r2(t)
%% 

disp('4 - Analisando erro ...')
fprintf('\nUtiliza-se o método do MSE (Mean-Squared Error) para comparar os resíduos obtidos.\n')

%%% Cálculo do resíduo r1(t)
r1 = immse(gtNumerico, p1);

%%% Cálculo do resíduo r2(t)
r2 = immse(gtNumerico, p2);

%%% Comparação de r1(t) com r2(t)
var = (r1-r2)/r2 * 100;
fprintf('\nTivemos os seguintes resultados: r1(t) = %.4f %% e r2(t) = %.4f %%\n', r1*100, r2*100);
fprintf('\nAssim, a variação percentual entre os resíduos da 1º e 2º harmônica é de %.2f%%, ou seja, r2(t) é %.2f%% menor que r1(t).', var, var);
fprintf('\nO que faz sentido, visto que adicionando cada vez mais harmônicas à nossa aproximação, o erro tende a ser cada vez menor.\n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 8 - Visualizando a nova aproximação
%% 

figure(2)
plot(tempo, gtNumerico, 'b', 'linewidth', 2); 
hold on;
plot(tempo, p2, 'k-', 'linewidth', 2);  
xlabel('Tempo em segundos');
ylabel('Amplitude');
legend('Sinal teórico', 'Segunda Harmônica');
title('2º harmônica - função teórica')
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 9 - Encontrando uma melhor aproximação
%% com base em um critério de parada
%% 

n = [-50:+50];
DnNumerico = eval(Dn);
pn = 0;


i = 1;
rn = Inf;
while rn > 0.001
    
    pn = pn + DnNumerico(i)*exp( n(i) *1i*wo*tempo);
    i = i + 1;
    rn = immse(gtNumerico, pn);
end

disp(['5 - Analisando o erro da ' num2str(i) 'º harmônica ...'])
fprintf('\nDefinimos como critério de parada rn(t) < 0.10%%\n')

fprintf('Após %d itereções, chegamos em um resutado de: r%d(t) = %.5f %%\n\n', i, i, rn*100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 10 - Visualizando a "melhor" aproximação
%% 

figure(3)
plot(tempo, gtNumerico, 'b', 'linewidth', 2); 
hold on;
plot(tempo, pn, 'k-', 'linewidth', 2);  
xlabel('Tempo em segundos');
ylabel('Amplitude');
titulo = [num2str(i) 'º harmônica - função teórica'];
legenda = [num2str(i) 'º harmônica'];
legend('Sinal teórico', legenda);
title(titulo)
grid
