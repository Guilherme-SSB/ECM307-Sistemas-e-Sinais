%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guilherme Samuel de Souza Barbosa
%% RA: 19.00012-0
%%
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

disp('1 - Preparando o código ...')

%%% Omite mensagens de warning

warning('off')   % Não mostra eventos de warning


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2 - Problema
%% 
%% Sinal g[k] - Sinal amostrado
%%

%%% Importação dos Sinais
disp('2 - Importando os sinais das vogais ...')

% Para obter o espectro de amplitude de cada vogal, deve-se apenas alterar
% o valor do parâmetro da função audioread
[gk, fs] = audioread('a.wav');   % gk ← vetor do sinal amostrado
                                 % fs ← frequência de amostragem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3 - Pré - processamento do sinal
%%  
%% X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N)
%%
disp('3 - Extraindo informações do sinal ...')

N                 = length(gk);                      % Número de pontos do vetor  
Ts                = 1/fs;                            % Intervalo de amostragem
Duracao_Sinal     = N*Ts;                            % Duração do sinal em segundos
tempo             = linspace(0, Duracao_Sinal, N);   % Vetor tempo
fmax              = fs/2;                            % Frequência máxima, respeitando Teorema da Amostragem
frequencia        = linspace(-fmax, +fmax, N);       % Vetor de frequência de N pontos

fprintf('\nb) O sinal tem duração de %.3f segundos\n\n', Duracao_Sinal)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4 -  Cálculo do X[n] (for) e Cálculo do X[f] (produto matricial)
%%
%% X[n] = 1/N sum_{k=0}^{N-1} g(k) exp(-j*n*k*2*pi/N) -> Série de Fourier
%% 
%% X[f] =  exp(-1i*2*pi/N)*ones(N, N).^[0:1:N-1]'*[0:1:N-1] -> Produto Matricial
%%

disp('4 - Calculando tempo de execução do algoritmo ...')
%%% Visando comparar ambos algoritmos, vamos rodar os dois.

%%% Utilizando estrutura for
tic;
for n=0 : N-1                                          % N pontos
    aux_k = 0;                                         % Valor inicial de aux_k
    for k=0 : N-1                                      % Lendo N pontos
        aux_k = aux_k + gk(k+1)*exp(-1i*n*k*2*pi/N);   % Valor acumulado em aux_k
    end  
    Xn(n+1) = aux_k/N;                                 % Atualiza o valor de Fourier
end
fprintf('\nUtilizando `for`: ')
toc;

%%% e) Utilizando produto matricial
% A justificativa desses calculados estão na Seção 6 - Observações

tic;
wn                = exp(-1i*2*pi/N);                   % Definindo wn
Matriz_jotas      = wn*ones(N, N);                     % Matriz NxN wn

Matriz_expoentes  = [0:1:N-1]'*[0:1:N-1];              

Matriz_fourier    = Matriz_jotas.^Matriz_expoentes;

Xf = Matriz_fourier*gk;
fprintf('Utilizando `produto matricial`: ')
toc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5 - Visualização 
%% 

fig1 = figure(1);

plot(tempo, gk)
xlabel('Tempo em segundos')                  
ylabel('Amplitude')                         
title('Sinal amostrado da vogal')
grid
%saveas(fig1,'Sinal amostrado.png')         % Salva a imagem

fig2 = figure(2);

stem(frequencia, fftshift(abs(Xf)))         % fftshift: move a componente de frequência 0 
                                            %para o centro do array 'frequência'
                                            % abs(x): toma a parte real de x
xlabel('Frequência em Hz')                  
ylabel('Amplitude')                         
title('a) Espectro de amplitude da vogal')
grid
%saveas(fig2,'Espectro de amplitude.png')   % Salva a imagem


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6 - Observações
%%%  
%%  Perguntas:
%%% a. Analisar as 5 vogais: Xa, Xe, Xi, Xo, Xu (Fourier de cada vogal)
%%% b. Os tempos de execução de cada vogal
%%% c. O que você observa de diferente em cada Série de Fourier? Qualitativamente
%%% d. Você conseguiria analisar no tempo? (Mesma conclusão sem Fourier?)
%%% e. Como você transformaria o for em um produto matricial como feito na teoria? (Assunto da proxima aula)
%%%
%%%
%% Respostas:
%%% a. Cada espectro de amplitude das vogais são plotados na figura 2. A
%%% análise foi feita caso a caso e os gráficos estão salvos em png no
%%% repositório: encurtador.com.br/nxMP4
%%% 
%%% b. O tempo de execução da vogal importada está sendo importado e
%%% printada na Janela de Comandos. Porém, o tempo de cada vogal é:
%%% - Tempo(a) = 0.437 segundos
%%% - Tempo(e) = 0.519 segundos
%%% - Tempo(i) = 0.360 segundos
%%% - Tempo(o) = 0.401 segundos
%%% - Tempo(u) = 0.617 segundos
%%%
%%% c. Com a série de Fourier, podemos observar as diferentes componentes
%%% de frequência que constroem o sinal da vogal amostrado.
%%%
%%% d. No domínio temporal, seria muito dificil visualizar as compenentes
%%% senoidais e cossenoidas do sinal amostrado. Já no domínio das
%%% frequências, essa análise se torna bem mais fácil pois temos uma
%%% representação visual da decomposição em frequências em função da
%%% amplitude.
%%%
%%% e. Para transformarmos o laço de repetição 'for' em produto matricial,
%%% primeiro temos que definir a resolução em frequência do sinal,
%%% comumente chamada de wn e assim obtemos a matriz NxN de
%%% jotas visto na teoria, sendo N o número de pontos de gk, preenchendo
%%% uma matriz NxN com o valor de wn. 
%%%
%%%    O próximo passo é encontrar uma matriz que conterá os expoentes da
%%% nossa Matriz_jotas. Para obter essa Matriz_expoentes, é criado um vetor
%%% que varia de 0 até N-1, toma-se sua transposta e multiplicado o
%%% resultado pelo vetor criado originalmente. O que resulta na Matriz_expoentes (N-1xN-1), que será do tipo:
%%% 0 0 0 0 ... 0
%%% 0 1 2 3 ... {N-1}
%%% 0 2 4 6 ... {2(N-1)}
%%% 0 3 6 9 ... {3(N-1)}
%%%
%%%    Pelas propriedades de produto matricial, sabemos que se a matriz A (MxP) for multiplicada pela matriz
%%% B (PxN), o produto é uma matriz C (MxN), ou seja, tomando o produto
%%% entre um vetor linear (N-1x1) a sua transposta (1xN-1), obteremos uma
%%% matriz (N-1xN-1).
%%%
%%%    Com a Matriz_expoentes pronto, basta elevar cada elemento da
%%% Matriz_jotas por cada elemento da Matriz_expoentes. O resultado dessa
%%% operação a Matriz_fourier, ou DFT Matrix. 
%%% A Matriz_fourier será do tipo:
%%% 1   1           1            1        ...    1
%%% 1 wn^1         wn^2         wn^3      ...   wn^{N-1}
%%% 1 wn^2         wn^4         wn^6      ...   wn^{2(N-1)}
%%% 1 wn^3         wn^6         wn^9      ...   wn^{3(N-1)}
%%% ⋮   ⋮          ⋮            ⋮         ⋱      ⋮
%%% 1 wn^{N-1}  wn^{2(N-1}}  wn^{3(N-1}}  ...   wn^{(N-1)(N-1)}
%%%
%%%    Concluido esse processo, a Matriz_fourier conterá o mesmo resultado do for, porém com uma
%%% eficiencia computacional bem maior. Calculando a média dos tempos de
%%% execução de cada vogal do for e do produto matricial, obtemos cerca de
%%% 157% mais velocidade utilizando produto matricial.
%%%