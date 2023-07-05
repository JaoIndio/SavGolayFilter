function DerivadaEspectral= DerivadaSavitzkyGolay(coeficientes, OrdemDerivada, OrdemInterpolacao)
  
  if OrdemDerivada<=OrdemInterpolacao
    derivada = zeros(length(coeficientes), 1); 
    fatorial = 1;
    for i = 2:OrdemDerivada
      fatorial = fatorial * i;
    end

    OrdemDerivada = OrdemDerivada+1; 
    for i=1:length(derivada)
      derivada(i,1) = fatorial*coeficientes(i, OrdemDerivada);
    end
    DerivadaEspectral = derivada;
  end
end
