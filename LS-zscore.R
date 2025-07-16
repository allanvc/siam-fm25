library(dplyr)
library(quantmod)
library(ggplot2)
library(gridExtra)

# Definir o período de coleta de dados
start_date <- as.Date("2023-01-01")
end_date <- Sys.Date()

# Obter os dados do Yahoo Finance
tickers <- c("KO", "PEP")
getSymbols(tickers, src = "yahoo", from = start_date, to = end_date)

# Extrair os preços de fechamento e calcular o log dos preços
KO_log_prices <- log(Cl(KO))
PEP_log_prices <- log(Cl(PEP))

# Criar um dataframe com os preços em log
prices_df <- data.frame(
  Date = index(KO_log_prices),
  KO = as.numeric(KO_log_prices),
  PEP = as.numeric(PEP_log_prices - 0.6)
)

mod <- lm(KO ~ PEP, data = prices_df)

# Calcular o spread entre os preços em log e o z-score
prices_df <- prices_df %>%
  mutate(
    Spread = KO - KO - (coef(mod)[2] * PEP),
    Zscore = (Spread - mean(Spread)) / sd(Spread)
  )

# Gráfico 1: Preços históricos em log de KO e PEP com legenda abaixo
p1 <- ggplot(prices_df, aes(x = Date)) +
  geom_line(aes(y = KO, color = "KO"), size = 0.6) +
  geom_line(aes(y = PEP, color = "PEP"), size = 0.6) +
  scale_color_manual(values = c("KO" = "#602d89", "PEP" = "gray")) +
  labs(title = "Historical Log Prices of KO and PEP", y = "Log Price", x = NULL) +
  theme_minimal() +
  theme(
    legend.title = element_blank(),
    legend.position = "bottom"  # Posiciona a legenda na parte inferior
  )

# Gráfico 2: Z-score do spread com linhas em -2 e +2 desvios padrão
# Gráfico 2: Z-score do spread com linhas em -2 e +2 desvios padrão e novas cores
p2 <- ggplot(prices_df, aes(x = Date, y = Zscore)) +
  geom_line(color = "black", size = 0.6) +  # Azul suave
  geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "#228b22") +  # Verde escuro
  labs(title = "Z-score of Spread", y = "Z-score", x = "Date") +
  theme_minimal()

# Combinar os gráficos
grid.arrange(p1, p2, ncol = 1, heights = c(2, 1))
