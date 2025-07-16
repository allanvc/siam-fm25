# Carregar as bibliotecas necessárias
library(dplyr)
library(quantmod)
library(DBI)
library(RSQLite)

# Definir o período de coleta de dados
start_date <- as.Date("2023-06-01")  # Data inicial
end_date <- Sys.Date()                # Data final é hoje

# Obter os dados do Yahoo Finance
tickers <- c("AAPL", "MSFT", "NVDA", "AMZN", "GOOG", "LLY", "AVGO", "JPM", "TSLA", "KO", "PEP")  # Adicione os tickers desejados
getSymbols(tickers, src = "yahoo", from = start_date, to = end_date)

# Preparar os dados
daily_data_list <- lapply(tickers, function(ticker) {
  data <- data.frame(Date = index(get(ticker)), Price = as.numeric(Cl(get(ticker))))
  colnames(data)[2] <- paste0(ticker, ".NAS")  # Renomear a coluna para o formato desejado
  return(data)
})

# Juntar os dados em um único dataframe
combined_data <- daily_data_list[[1]]
for (i in 2:length(daily_data_list)) {
  combined_data <- left_join(combined_data, daily_data_list[[i]], by = "Date")
}

# Formatando para o formato desejado (incluir coluna 'time')
combined_data <- combined_data %>%
  rename(time = Date) %>%
  mutate(time = as.POSIXct(time))  # Certificando-se de que o tipo de 'time' esteja correto

# Conectar ao banco de dados SQLite
# db_file_path <- 'SP500_daily.db'  # Substitua pelo caminho desejado
# con <- dbConnect(RSQLite::SQLite(), db_file_path)
# 
# # Salvar os dados em uma nova tabela no banco de dados
# dbWriteTable(con, "DailyData", combined_data, overwrite = TRUE)

# Fechar a conexão
# dbDisconnect(con)

# Visualizar os dados formatados
head(combined_data)



# ----------------

# install.packages("RSQLite")
# library(DBI)
# library(RSQLite)
# arq.loc <- file.choose()
# con <- dbConnect(SQLite(), arq.loc)
# 
# # Show List of Tables
# as.data.frame(dbListTables(con))
# 
# # Get table
# sp500.d1 <- dbReadTable(con, 'D1')
# sp500.m5 <- dbReadTable(con, 'M5')
# 
# # data is fetched so disconnect it.
# dbDisconnect(con)
# 
# 
# # select two series of stocks with nice backtest results
# 
# # relatorio de 08-04-23 mostra que melhor periodo para o par eh 132
# library(dplyr)
# nue.nyse_mar.nas_d1 <- sp500.d1 %>%
#   select(time, KO.NYSE, PEP.NAS) %>%
#   # slice_tail(n = 132) %>%
#   # mutate(time = as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S"))
#   mutate(time = as.Date(time))


# initial_date = nue.nyse_mar_d1[1, "time"]
#final_date = nue.nyse_mar._d1[132, "time"] + 1

# M5

# nue.nyse_mar.nas_m5 <- sp500.m5 %>% 
#   select(time, NUE.NYSE, MAR.NAS) %>%
#   mutate(date = as.Date(time)) %>%
#   filter(date >= initial_date)

# nue.nyse_mar.nas_m5 <- sp500.m5 %>% 
#   select(time, NUE.NYSE, MAR.NAS) %>%
#   mutate(time = 1:length(time)) %>%
#   slice_tail(n = 300)


# ----------
# o grafico melhor se usarmos os dados do diario e nao do intraday!

sp500.d1 <- combined_data %>%
  select(time, KO.NAS, PEP.NAS) %>%
  mutate(time = 1:length(time))


nue.nyse_mar.nas_d1 <- sp500.d1

library(plotly)

accumulate_by <- function(dat, var) {
  var <- lazyeval::f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  dplyr::bind_rows(dats)
}

#df <- txhousing 
library(tidyr)
fig <- nue.nyse_mar.nas_d1 %>%
  select(time, 1:3) %>%
  mutate(KO.NAS = log(KO.NAS), PEP.NAS = log(PEP.NAS)- 0.9) %>%
  pivot_longer(!time, names_to = "stock", values_to = "price") #%>%
  # mutate(price = log(price))

#filter(year > 2005, city %in% c("Abilene", "Bay Area"))
fig <- fig %>% accumulate_by(~time)


fig <- fig %>%
  plot_ly(
    x = ~time, 
    y = ~price,
    split = ~stock,
    frame = ~frame, 
    type = 'scatter',
    mode = 'lines', 
    line = list(simplyfy = F),
    # line = list(color = c("red", "green"))  # Definir as cores aqui
    color = ~stock,
    colors = c("#602d89", "gray")
  )
  


fig <- fig %>% layout(
  xaxis = list(
    title = "Date/Time",
    zeroline = F,
    zerolinecolor = '#ffff',
    zerolinewidth = 2,
    gridcolor = 'ffff',
    showticklabels=FALSE
  ),
  yaxis = list(
    title = "Log Price",
    zeroline = F
  ),
  #margin=m,
  autosize = F, width = 900, height = 510
  #paper_bgcolor = "lightblue"
) 
fig <- fig %>% animation_opts(
  frame = 50, 
  transition = 0, 
  redraw = FALSE
)
fig <- fig %>% animation_slider(
  hide = T
)
fig <- fig %>% animation_button(
  x = 1, xanchor = "left", y = 0, yanchor = "bottom"
)

fig 

saveRDS(object=fig, file="plotly_LS2.rds")
