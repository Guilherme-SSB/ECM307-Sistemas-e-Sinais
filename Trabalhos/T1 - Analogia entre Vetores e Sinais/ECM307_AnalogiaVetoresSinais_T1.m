%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guilherme Samuel de Souza Barbosa
%% RA: 19.00012-0
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1 - Prepara��o do c�digo
%% 

clc;         % limpa visual da tela de comandos
close all;   % limpa as figuras
clear all;   % limpa as vari�veis

disp('1 - Preparando o c�digo ...')

%%% Carregar biblioteca simb�lica

% pkg load symbolic;

%%% Omite mensagens de warning

warning('off') % N�o mostra eventos de warning


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2 - Problema
%% 
%% Aproximar uma exponencial por uma S�rie Exponencial de Fourier
%%
 
disp('2 - Definindo o sinal g(t) ...')

To = 1;   % per�odo da onda quadrada
to = 0;   % instante inicial de g(t)

%%% C�lculo dos demais par�metros

fo = 1/To;      % frequ�ncia da onda quadrada
wo = 2*pi*fo;   % frequ�ncia angular de g(t)

%%% Fun��o g(t) te�rica

gtTeorico = @(t) exp(-t);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3 - Calcular o valor de Dn
%% 
%% Ambiente de c�lculo integral e simb�lico
%%
%% Symbolic pkg v2.9.0: 
%% Python communication link active, SymPy v1.5.1.
%%

disp('3 - S�rie de Fourier simb�lica ...')

%%% Definindo as vari�veis simb�licas

syms n t   % vari�veis simb�licas

%%% C�lculo do numerador de Dn

Inum = int(exp(-(1 + 1i*wo*n)*t), t, to, To);

%%% C�lculo do Dn

Dn = Inum / To;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4 - Avaliando proje��es
%% 

n = [-1 0 +1];           % Valores de n para an�lise da primeira harm�nica

DnNumerico = eval(Dn);   % Substitui os valores de 'n' em 'Dn'

%%% Sintetizando a 1� harm�nica

M = 1000;                       % resolu��o do sinal
tempo = linspace(-To, To, M);   % Intervalo de an�lise com M pontos

cMinus1 = DnNumerico(1)*exp(n(1)*1i*wo*tempo);   % C�lculo do c_{-1}
c0 = DnNumerico(2)*exp(n(2)*1i*wo*tempo);        % C�lculo do c_{0}
c1 = DnNumerico(3)*exp(n(3)*1i*wo*tempo);        % C�lculo do c_{+1}

p1 = cMinus1 + c0 + c1;   % Primeira harm�nica


%%% Compararando a 1� harm�nica com o sinal te�rico

tempo1 = linspace(0, To, M/2);

gtNumerico = [gtTeorico(tempo1) gtTeorico(tempo1)];   % O valor n�merico te�rico da onda


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5 - Visualizando a aproxima��o
%% 

figure(1)
plot(tempo, gtNumerico, 'b', 'linewidth', 2);   % g(t) Te�rico
hold on;
plot(tempo, p1, 'k-', 'linewidth', 2);          % g(t) Aproximado      
xlabel('Tempo em segundos');
ylabel('Amplitude');
legend('Sinal te�rico', 'Primeira Harm�nica');
title('1� harm�nica - Fun��o te�rica')
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6 - Avaliando novas proje��es
%% 

n = [-2 +2];             % Valores de n para an�lise da segunda harm�nica

DnNumerico = eval(Dn);   % Substitui os valores de 'n' em 'Dn'

%%% Sintetizando a 2� harm�nica

M = 1000;                       % resolu��o do sinal
tempo = linspace(-To, To, M);   % Intervalo de an�lise com M pontos

cMinus2 = DnNumerico(1)*exp(n(1)*1i*wo*tempo);   % C�lculo do c_{-2}
c2 = DnNumerico(2)*exp(n(2)*1i*wo*tempo);        % C�lculo do c_{+2}

p2 = p1 + cMinus2 + c2;   % Segunda harm�nica

%%% Comparar a 2� harm�nica com o sinal te�rico

tempo1 = linspace(0, To, M/2);

gtNumerico = [gtTeorico(tempo1) gtTeorico(tempo1)];   % O valor n�merico te�rico da onda


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7 - C�lculo dos res�duos r1(t) e r2(t)
%% 

disp('4 - Analisando erro ...')
fprintf('\nUtiliza-se o m�todo do MSE (Mean-Squared Error) para comparar os res�duos obtidos.\n')

%%% C�lculo do res�duo r1(t)
r1 = immse(gtNumerico, p1);

%%% C�lculo do res�duo r2(t)
r2 = immse(gtNumerico, p2);

%%% Compara��o de r1(t) com r2(t)
var = (r1-r2)/r2 * 100;
fprintf('\nTivemos os seguintes resultados: r1(t) = %.4f %% e r2(t) = %.4f %%\n', r1*100, r2*100);
fprintf('\nAssim, a varia��o percentual entre os res�duos da 1� e 2� harm�nica � de %.2f%%, ou seja, r2(t) � %.2f%% menor que r1(t).', var, var);
fprintf('\nO que faz sentido, visto que adicionando cada vez mais harm�nicas � nossa aproxima��o, o erro tende a ser cada vez menor.\n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 8 - Visualizando a nova aproxima��o
%% 

figure(2)
plot(tempo, gtNumerico, 'b', 'linewidth', 2); 
hold on;
plot(tempo, p2, 'k-', 'linewidth', 2);  
xlabel('Tempo em segundos');
ylabel('Amplitude');
legend('Sinal te�rico', 'Segunda Harm�nica');
title('2� harm�nica - fun��o te�rica')
grid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 9 - Encontrando uma melhor aproxima��o
%% com base em um crit�rio de parada
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

disp(['5 - Analisando o erro da ' num2str(i) '� harm�nica ...'])
fprintf('\nDefinimos como crit�rio de parada rn(t) < 0.10%%\n')

fprintf('Ap�s %d itere��es, chegamos em um resutado de: r%d(t) = %.5f %%\n\n', i, i, rn*100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 10 - Visualizando a "melhor" aproxima��o
%% 

figure(3)
plot(tempo, gtNumerico, 'b', 'linewidth', 2); 
hold on;
plot(tempo, pn, 'k-', 'linewidth', 2);  
xlabel('Tempo em segundos');
ylabel('Amplitude');
titulo = [num2str(i) '� harm�nica - fun��o te�rica'];
legenda = [num2str(i) '� harm�nica'];
legend('Sinal te�rico', legenda);
title(titulo)
grid
