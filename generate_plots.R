library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# Caricamento dati
dati <- read_xlsx("dati_report.xlsx")
# Creazione sequenza temporale (mensile da Gen 1980)
date_seq <- seq(as.Date("1980-01-01"), by = "month", length.out = nrow(dati))

# Prep data
dati_plot <- dati
dati_plot$Date <- date_seq
colnames(dati_plot)[1:3] <- c("Produzione_Industriale", "Occupazione", "Reddito_Reale")

dati_long <- pivot_longer(dati_plot, cols = c("Produzione_Industriale", "Occupazione", "Reddito_Reale"), 
                          names_to = "Variabile", values_to = "Valore")

# Normalize data for plotting together
dati_long <- dati_long %>%
  group_by(Variabile) %>%
  mutate(Valore_Normalizzato = scale(Valore))

p1 <- ggplot(dati_long, aes(x = Date, y = Valore_Normalizzato, color = Variabile)) +
  geom_line(size=0.8) +
  theme_minimal() +
  labs(title = "Andamento delle Variabili Macroeconomiche (1980-2023)",
       subtitle = "Valori normalizzati per permettere il confronto",
       x = "Anno",
       y = "Valore Normalizzato") +
  theme(legend.position = "bottom",
        text = element_text(size=12, family="sans"),
        plot.title = element_text(face="bold")) +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#009E73"))

ggsave("plot_serie_storiche.png", p1, width = 10, height = 6, dpi=300)

# Tassi di crescita (Differenze logaritmiche)
dati_crescita <- dati_plot %>%
  mutate(
    Prod_Growth = c(NA, diff(log(Produzione_Industriale))) * 100,
    Occ_Growth = c(NA, diff(log(Occupazione))) * 100,
    Redd_Growth = c(NA, diff(log(Reddito_Reale))) * 100
  ) %>%
  filter(!is.na(Prod_Growth))

p2 <- ggplot(dati_crescita, aes(x = Date, y = Prod_Growth)) +
  geom_line(color="#56B4E9", size=0.5) +
  theme_minimal() +
  labs(title = "Tasso di Crescita: Produzione Industriale",
       subtitle = "Variazioni mensili %",
       x = "Anno",
       y = "Crescita (%)") +
  theme(text = element_text(size=12, family="sans"),
        plot.title = element_text(face="bold"))

ggsave("plot_tassi_crescita.png", p2, width = 10, height = 4, dpi=300)

print("Plots generated successfully.")
