# Carregar as bibliotecas necessárias
library(ggplot2)
library(dplyr)

# Definir os dados
x <- c(5.3, 5.4, 6, 7.2, 6.7, 5.5, 5.6)
y <- c(2.7, 2.8, 3.5, 2.5, 3.1, 3.6, 3.9)
dates <- as.Date(1:7, origin = "2023-01-01")  # Criar datas comuns

# Criar um data frame
df <- data.frame(dates, stock_X = x, stock_Y = y)

# Transformar para formato longo para ggplot2
df_long <- df %>%
  pivot_longer(cols = c(stock_X, stock_Y), names_to = "stock", values_to = "values")

# Criar o gráfico usando ggplot2
ggplot(df_long, aes(x = dates, y = values, color = stock, linetype = stock)) +
  geom_line(size = 1.2) +
  scale_color_manual(values = c("blue", "orange")) + # Define cores para cada série
  scale_linetype_manual(values = c("solid", "dashed")) + # Define tipos de linha
  ylim(2, 8) +  # Limites do eixo y
  labs(title = "Pairs Trading Mechanism", x = "Date", y = "Values") +
  theme_minimal() +  # Tema minimalista
  theme(
    legend.position = "none",  # Remover a legenda
    plot.title = element_text(hjust = 0, vjust = 1, size = 12),  # Alinhar título à esquerda
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20)  # Ajustar margens
  ) +
  # Adicionar o intervalo de datas no canto superior direito
  annotate("text", x = as.Date("2023-01-08"), y = 8.0, 
           label = "2023-01-02 / 2023-01-08", 
           hjust = 1, size = 3, color = "black") +
  # Adicionar anotações
  annotate("text", x = as.Date("2023-01-04"), y = 7.4, label = "Open\nshort position", size = 3.5, color = "black") +
  annotate("text", x = as.Date("2023-01-04"), y = 2.3, label = "Open\nlong position", size = 3.5, color = "black") +
  annotate("text", x = as.Date("2023-01-06"), y = 4.7, label = "Rewind\npositions", size = 3.5, color = "black")
