# Replication materials: Institutional Integrity, Democracy and COC

> **Flores Rivera, L. E., & López Estrello, A. A.** (2026). Integridad institucional, democracia electoral y crimen organizado: un análisis mediante PCA y modelos multinivel. *América Latina Hoy* , 96, e32394.

---

## What this repo contains

| File | Description |
|------|-------------|
| `datos_COC_III.xlsx` | Panel dataset. Sheet `datos`: country-year observations with V-Dem indicators and conflict variable. Sheet `variables`: codebook. |
| `modelos_COC_III.r` | Full R script: PCA-based index construction (III) + multilevel models + diagnostics. |

---

## How to reproduce

**Requirements:** R ≥ 4.2 and the following packages:

```r
install.packages(c("readxl", "tidyverse", "FactoMineR",
                   "lme4", "lmerTest", "DHARMa", "forcats"))
```

**Steps:**

1. Clone or download this repository.
2. Place both files in the same working directory.
3. Open `modelos_COC_III_R.r` and run it top to bottom.

The script will:
- Load the data from `datos_COC_III.xlsx`
- Construct the Institutional Integrity Index (III) via PCA on 11 V-Dem indicators
- Fit three multilevel models (`lmer`) with country random effects
- Run residual diagnostics via DHARMa

---

## Key variables

| Variable | Source | Role |
|----------|--------|------|
| `v2x_rule`, `v2x_corr`, `v2x_jucon`, + 8 more | V-Dem | PCA inputs → III index |
| `v2x_polyarchy` | V-Dem | Predictor (democracy) |
| `conflicto` | HIIK | Predictor (armed conflict) |
| `NY.GDP.PCAP.PP.KD` | World Bank | Control (log GDP per capita) |
| `country_name`, `year` | V-Dem | Grouping / time |

---

## Authors

**Lesly Flores** - **Arturo Azael López Estrello**

---
