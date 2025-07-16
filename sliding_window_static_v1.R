library(plotly)

# Parâmetros da janela deslizante
total_days <- 100
window_size <- 15  # tamanho da janela deslizante
forming_days <- 5
decision_days <- 5
trading_days <- 5

# Dados de exemplo
set.seed(123)
dates <- seq.Date(as.Date("2023-01-01"), by = "days", length.out = total_days)
price <- cumsum(rnorm(total_days))  # Movimento de preço aleatório

# Cria uma função para adicionar retângulos que representam os períodos
add_period_rectangles <- function(fig, start_day, forming_days, decision_days, trading_days) {
  fig <- fig %>%
    layout(
      shapes = list(
        list(type = "rect", x0 = start_day, x1 = start_day + forming_days, y0 = min(price), y1 = max(price),
             fillcolor = "rgba(255, 0, 0, 0.3)", line = list(width = 0), layer = "below"),
        list(type = "rect", x0 = start_day + forming_days, x1 = start_day + forming_days + decision_days, 
             y0 = min(price), y1 = max(price),
             fillcolor = "rgba(0, 255, 0, 0.3)", line = list(width = 0), layer = "below"),
        list(type = "rect", x0 = start_day + forming_days + decision_days, x1 = start_day + forming_days + decision_days + trading_days, 
             y0 = min(price), y1 = max(price),
             fillcolor = "rgba(0, 0, 255, 0.3)", line = list(width = 0), layer = "below")
      )
    )
  return(fig)
}

# Gráfico com os dados e a janela deslizante
fig <- plot_ly(x = ~dates, y = ~price, type = 'scatter', mode = 'lines') %>%
  layout(
    title = "Movimento da Janela Deslizante Dividida em Períodos",
    xaxis = list(title = "Data"),
    yaxis = list(title = "Preço")
  )

# Loop para adicionar a janela deslizante em cada posição
for (i in 1:(total_days - window_size)) {
  fig <- add_period_rectangles(fig, dates[i], forming_days, decision_days, trading_days)
}

fig
