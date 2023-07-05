function [FuncaoSuavizada, coef] = FiltroSavitkzyGolay(funcaoEspectral, comprimentoOnda, janelaTamanho, OrdemInterpolacao)
  % Aplicacao do filtro
  % 1  janela de pontos
  %janelaTamanho=10;
  janelaMontante= length(funcaoEspectral)-janelaTamanho;
  janelaIndex=1;
  janelaPontos = zeros(janelaMontante, janelaTamanho);
  interpolacao_x=zeros(janelaMontante, janelaTamanho);
  
  % Janela de Pontos associada ao dominio (comprimento de onda)
  for janelaIndex = 1:janelaMontante
    janelaPontos(janelaIndex, :)=funcaoEspectral(janelaIndex:janelaIndex+janelaTamanho-1);
    interpolacao_x(janelaIndex, :)=comprimentoOnda(janelaIndex:janelaIndex+janelaTamanho-1);
  end
  
  %OrdemInterpolacao=3;
  coeficientes = zeros(janelaMontante, OrdemInterpolacao+1);
  for janelaIndex = 1:janelaMontante
    coeficientes(janelaIndex, :) = polyfit(interpolacao_x(janelaIndex, 1:janelaTamanho), ...
                                           janelaPontos(janelaIndex, 1:janelaTamanho),   ...
                                           OrdemInterpolacao);
  end
  
  % 3  estimação de valores
  funcaoFiltrada =zeros(length(funcaoEspectral)); 
  for janelaIndex = 1:janelaMontante
    round(janelaTamanho/2)+(janelaIndex-1);
    %round(janelaTamanho/2)
    coeficientes(janelaIndex,:);
    polyval(coeficientes(janelaIndex,:),round(janelaTamanho/2));
    
    funcaoFiltrada(round(janelaTamanho/2)+(janelaIndex-1)) = polyval(coeficientes(janelaIndex,:),...
                                                                     comprimentoOnda(round(janelaTamanho/2)+(janelaIndex-1)));
  
  end
  FuncaoSuavizada = funcaoFiltrada;
  coef            = coeficientes;
end

