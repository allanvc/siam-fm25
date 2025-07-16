# Instalar e carregar o pacote 'truncnorm' (se ainda não estiver instalado)
if (!require(truncnorm)) install.packages("truncnorm")
library(truncnorm)

# Definir os parâmetros das distribuições normais truncadas
mean1 <- 1.5
mean2 <- 2.5
sd <- 1

# Criar uma sequência de valores para o eixo x (de 0 em diante, pois é truncada)
betas <- seq(0, 6, length = 100)
q <- quantile(betas, c(0.05, 0.60))

# Calcular as densidades das distribuições normais truncadas para cada valor de x
y1 <- dtruncnorm(x, a = 0, mean = mean1, sd = sd)
y2 <- dtruncnorm(x, a = 0, mean = mean2, sd = sd)

# Plotar a primeira curva de densidade normal truncada
plot(x, y1, type = "l", lwd = 2, col = "gray", 
     xlab = "Betas", 
     ylab = "Density", 
     main = "Full-conditional of " ~ beta[1],
     bty = 'n',
     ylim = c(0, max(y1, y2)))  # Definir o limite do eixo y para acomodar ambas as curvas


# Adicionar o preenchimento da primeira curva com hachuras e alpha suave (azul)
polygon(c(0, x), c(0, y1), col = rgb(0, 0, 1, alpha = 0.2), border = NA)

# Adicionar a segunda curva de densidade normal truncada
# lines(x, y2, col = "#228b22", lwd = 2)

# Adicionar o preenchimento da segunda curva com hachuras e alpha suave (laranja)
# polygon(c(0, x), c(0, y2), col = rgb(1, 0.5, 0, alpha = 0.2), border = NA)

# Adicionar linhas verticais nas médias de ambas as distribuições
# abline(v = mean1, col = "red", lty = 2)
# abline(v = mean2, col = "darkorange", lty = 2)

abline(v = q, col=c("#228b22", "#228b22"), lty=2)
abline(v = mean1, col="#4a90e2")

