pkg load control
pkg load signal
%Criacao de uma funcao espectral
%r o comprimento de onda de interesse (de 400nm a 2500nm)
comprimento_onda = linspace(400, 2500, 1000); % 1000 pontos entre 400 e 2500

% Parâmetros dos picos
picos = [500, 1000, 1500, 2000]; % Comprimentos de onda dos picos
%picos = [1000, 2000]; % Comprimentos de onda dos picos
amplitude_maxima = 1; % Amplitude máxima dos picos
amplitude_outros = 0.25; % Amplitude dos pontos fora dos picos

% Gera função espectral genérica
funcao_espectral = zeros(size(comprimento_onda)); % Inicializar função espectral

% Adicionar picos na função espectral
for i = 1:length(picos)
  % Parâmetros da Gaussiana do pico atual
  pico = picos(i);
  desvio_padrao = 50; % Ajuste o desvio padrão conforme necessário
                 
  % Calcular o valor da Gaussiana para o pico atual
  gaussiana = amplitude_maxima * exp(-0.5 * ((comprimento_onda - pico) / desvio_padrao).^2);
                              
  % Adicionar o valor da Gaussiana à função espectral
  funcao_espectral = funcao_espectral + gaussiana;
end

%frequencias = [1, 2  , 5  , 10  , 100  , 1000,  10000]; %hz
frequencias = [5]; %hz
%amplitudes  = [0.5, 1, 0.25, 0.125, 0.01, 0.02, 0.03];
amplitudes  = [0.1];
frequencia_amostragem = 10000;
tempo_total = 1;
t = linspace(0, 1, 1000);
soma_senoides = zeros(size(t));
for i = 1:length(frequencias)
  soma_senoides = soma_senoides + amplitudes(i) * sin(2 * pi * frequencias(i) * t);
end

%Definir os pontos fora dos picos
funcao_espectral(comprimento_onda < min(picos) | comprimento_onda > max(picos)) = amplitude_outros;

funcao_espectral= funcao_espectral+soma_senoides;
ruido = 0.45; % Nível de ruído configurável
funcao_espectral_ruidosa = funcao_espectral + ruido*randn(size(comprimento_onda));

janelaTamanho     = 35;
OrdemInterpolacao = 2;
OrdemDerivada     = 1;
Resuavizacao      = 100;

fprintf('Sauvização 1\n')
[funcaoFiltrada, coefs] = FiltroSavitkzyGolay(funcao_espectral_ruidosa, comprimento_onda, janelaTamanho, OrdemInterpolacao);
% Gera a mesma Sauvização e Diferenciação, porém agora usando as funções prontas do Octave
SmoothedData = sgolayfilt(funcao_espectral_ruidosa, OrdemInterpolacao, janelaTamanho);

for times=1:Resuavizacao
  fprintf('Sauvização %d\n', times+1)
  SmoothedData= sgolayfilt(SmoothedData, OrdemInterpolacao, janelaTamanho);
  [funcaoFiltrada, coefs] = FiltroSavitkzyGolay(funcaoFiltrada, comprimento_onda, janelaTamanho, OrdemInterpolacao);
end
% 4  derivada espectral

fprintf('Derivação Espectral\n')
Derivada=DerivadaSavitzkyGolay(coefs, OrdemDerivada, OrdemInterpolacao);
OctaveDerivative = diff(SmoothedData,1, 2);% ./ diff(comprimento_onda);
fprintf('Done')

% Plotar a função espectral
figure(1);
subplot(2,2,1);
plot(comprimento_onda, funcao_espectral, "magenta")
xlabel('Comprimento de Onda (nm)')
ylabel('Funcao Espectral Ideal')
title('Função Espectral com 4 Picos')

subplot(2,2,2);
plot(comprimento_onda, funcao_espectral_ruidosa, "black")
xlabel('Comprimento de Onda (nm)')
ylabel('Funcao Filtrada')
title('Função Espectral Ruidosa')

subplot(2,2,3);
plot(comprimento_onda, funcaoFiltrada, "red")
xlabel('Comprimento de Onda (nm)')
ylabel('Funcao Filtrada')
title('Filtro Savitzky-Golay')

fprintf('Adaptando Comprimento de Onda e Derivada\n')
ErroDerivada = zeros(length(Derivada), 1);
for i=1:length(ErroDerivada)
  ErroDerivada(i) = OctaveDerivative(i) +Derivada(i);
end
DerivadaAdapt = zeros(length(comprimento_onda), 1);
copiaIndex    = ceil( (length(comprimento_onda) - length(ErroDerivada) ) /2);
extremidades  = copiaIndex + length(ErroDerivada) -1;
DerivadaAdapt(copiaIndex:extremidades) = ErroDerivada;

subplot(2,2,4);
plot(comprimento_onda, DerivadaAdapt, "cyan")
xlabel('Comprimento de Onda (nm)')
ylabel('Erro da Derivada')
title('Erro de Derivação')


figure(2);
subplot(2,2,1);
plot(comprimento_onda, SmoothedData, "magenta")
xlabel('Comprimento de Onda (nm)')
ylabel('Savitzky Golay Nativo')
title('Filtro Nativo')

fprintf('Adaptando Comprimento de Onda e Derivada\n')
OctaveDerivadaAdapt = zeros(length(comprimento_onda), 1);
copiaIndex    = ceil( (length(comprimento_onda) - length(OctaveDerivative) ) /2);
extremidades  = copiaIndex + length(OctaveDerivative) -1;
OctaveDerivadaAdapt(copiaIndex:extremidades) = OctaveDerivative;


subplot(2,2,2);
plot(comprimento_onda, OctaveDerivadaAdapt, "black")
xlabel('Comprimento de Onda (nm)')
ylabel('Derivada Octave')
title('Derivada Nativa')

subplot(2,2,3);
plot(comprimento_onda, funcaoFiltrada, "red")
xlabel('Comprimento de Onda (nm)')
ylabel('Filtro Próprio')
title('Filtro Savitzky-Golay Próprio')

fprintf('Adaptando Comprimento de Onda e Derivada\n')
DerivadaAdapt = zeros(length(comprimento_onda), 1);
copiaIndex    = ceil( (length(comprimento_onda) - length(Derivada) ) /2);
extremidades  = copiaIndex + length(Derivada) -1;
DerivadaAdapt(copiaIndex:extremidades) = -1*Derivada;

subplot(2,2,4);
plot(comprimento_onda, DerivadaAdapt, "cyan")
xlabel('Comprimento de Onda (nm)')
ylabel('Derivada Própria')
title('Derivada Espectral Prórpia')

