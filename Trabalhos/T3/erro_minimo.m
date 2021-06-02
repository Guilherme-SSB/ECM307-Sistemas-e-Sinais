%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  @author Guilherme Samuel de Souza Barbosa  RA.: 19.00012-0
%%  @author Renan Scheidt Reschke  RA.: 19.02009-0
%%
%%
function [b_bckup, c_bckup, erro_min] = erro_minimo(b, c, Vp, t1, t2)
  erro_min  = 9999999;
  N         = 1;
  Trecho_escolhido = Vp(t1:t2);   % intervalo de 28ms a 36ms deltaT = 8ms
  tic;
  for i = 1: length(b)              %%%%%%%%%
    for j = 1: length(c)            %% Avalia cada dupla (b, c)
      D       = [1 b(i) c(j)];            % denominador
      Gs      = tf(N, D);           % funcao de transferencia estimada
      [serie, ~, ~] = impulse(Gs);
      erro = sum(power(Trecho_escolhido - serie(1:(t2-t1+1)), 2));  % calcula o erro para (b, c) atual
      
      if erro < erro_min            % atualiza o erro minimo encontrado e (b, c)
        erro_min = erro;
        b_bckup = b(i);
        c_bckup = c(j);
      end        
    end
  end
  fprintf("Tempo para achar o erro minimo: ");
  toc;
end