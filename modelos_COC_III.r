#############################################
# Replicación artículo - Integridad institucional, democracia y COC
# Autorxs: Lesly Flores - Arturo López Estrello
#############################################

# 1. Paquetería ----------------------------------------------------

library(readxl)
library(tidyverse)
library(FactoMineR)
library(lme4)
library(lmerTest)
library(DHARMa)
library(forcats)

# 2. Carga de datos -----------------------------------------------

data <- read_excel("datos_COC_III.xlsx", sheet = "datos")


# 3. Construcción del índice (PCA) -------------------------------

variables_corruption_conflict <- data %>%
  select(
    v2x_rule, v2excrptps, v2exbribe, v2xcl_acjst,
    v2x_corr, v2juaccnt, v2jureform, v2psprlnks,
    v2x_jucon, v2x_neopat_invertido, v2juhcind_invertido
  )

conteo_datos <- colSums(!is.na(variables_corruption_conflict))
print(conteo_datos)

pca_result <- PCA(
  variables_corruption_conflict,
  scale.unit = TRUE,
  graph      = FALSE
)

loadings <- pca_result$var$coord
scores   <- pca_result$ind$coord[, 1]

loadings_pos <- loadings
loadings_pos[, 1] <- abs(loadings[, 1])

scores_pos <- scores * sign(mean(loadings[, 1]))

round(loadings_pos, 4)
data$III <- scores_pos


# 5. Modelos multinivel -------------------------------------------

data$year_centrado <- data$year - mean(data$year)
data$log_NY.GDP.PCAP.PP.KD <- log(data$NY.GDP.PCAP.PP.KD)

data_filtrada <- na.omit(data[, c("III", "v2x_polyarchy", 
                                  "log_NY.GDP.PCAP.PP.KD", "year_centrado", 
                                  "conflicto", "country_name")])


## Modelo con pendiente aleatoria para país------------

modelo_pais <- lmer(III ~ v2x_polyarchy + 
                          log_NY.GDP.PCAP.PP.KD + year_centrado + 
                          conflicto + (1 | country_name), 
                        data = data_filtrada)

summary(modelo_pais)
AIC(modelo_completo); BIC(modelo_pais)
logLik(modelo_pais); deviance(modelo_pais)

## Modelo con pendiente aleatoria para democracia ------------

modelo_poliarquia <- lmer(
  III ~ v2x_polyarchy + conflicto +
    log_NY.GDP.PCAP.PP.KD + year_centrado +
    (1 + v2x_polyarchy | country_name),
  data = data_filtrada,
  REML = FALSE
)

summary(modelo_poliarquia)
AIC(modelo_poliarquia); BIC(modelo_poliarquia)
logLik(modelo_poliarquia); deviance(modelo_poliarquia)


## Modelo con pendiente aleatoria para conflicto  ------------

modelo_conflicto <- lmer(
  III ~ v2x_polyarchy + conflicto +
    log_NY.GDP.PCAP.PP.KD + year_centrado +
    (1 + conflicto | country_name),
  data = data_filtrada,
  REML = FALSE
)

summary(modelo_conflicto)
AIC(modelo_conflicto); BIC(modelo_conflicto)
logLik(modelo_conflicto); deviance(modelo_conflicto)


# 6. Diagnósticos de modelos --------------------------------------

## ICC para modelo con intercepto aleatorio ------------------
modelo_nulo <- lmer(III ~ 1 + (1 | country_name), 
                    data = data_filtrada, REML = FALSE)

modelo_completo <- lmer(III ~ v2x_polyarchy + 
                          log_NY.GDP.PCAP.PP.KD + year_centrado + 
                          conflicto_rev + (1 | country_name), 
                        data = data_filtrada, REML = FALSE)

var_intercepto <- as.numeric(VarCorr(modelo_completo)$country_name[1])
var_residual   <- attr(VarCorr(modelo_completo), "sc")^2
ICC <- var_intercepto / (var_intercepto + var_residual)
ICC

## DHARMa: modelo_país ---------------------------------

sim_pais <- simulateResiduals(fittedModel = modelo_pais)

testDispersion(sim_pais)
testUniformity(sim_pais)
testQuantiles(sim_pais)

residuales_pol <- residuals(modelo_pais)
mean(residuales_pol); sd(residuales_pol)


## DHARMa: modelo_poliarquia ---------------------------------

sim_poliarquia <- simulateResiduals(fittedModel = modelo_poliarquia)

testDispersion(sim_poliarquia)
testUniformity(sim_poliarquia)
testQuantiles(sim_poliarquia)

residuales_pol <- residuals(modelo_poliarquia)
mean(residuales_pol); sd(residuales_pol)


## DHARMa: modelo_conflicto ----------------------------------

sim_conflicto <- simulateResiduals(fittedModel = modelo_conflicto)

testDispersion(sim_conflicto)
testUniformity(sim_conflicto)
testQuantiles(sim_conflicto)

residuales_conf <- residuals(modelo_conflicto)
mean(residuales_conf); sd(residuales_conf)
