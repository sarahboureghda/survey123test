install.packages("tidyverse")
library(tidyverse)
library(arcgislayers)
library(arcgisutils)
library(sf)

## Étapes parce que je m'en rappelerai plus!!
# 1. Aller sur https://ulaval.maps.arcgis.com/home/index.html -> Onglet "Content"
# 2. Cliquer sur "Enquête sans titre_results" et aller chercher l'URL (colonne à droite)
# 3. Vu que c'est une couche privée, il faut aller créer une nouvelle application pour se connecter. 
#    Aller dans Content -> New item -> Application et créer l'application
# 4. Cliquer sur la nouvelle application dans content et copier le client ID et le client secret.
#    Cela permet de créer les objets URL, client et secret.

# APRES les données crées ici sont enregistrées dans un fichier rds (donnees_pretes.rds).
# L'application Shiny va lire ces données et les reloader chaque 3 secondes (pour l'instant, chiffre a changer).

# setwd("")

#### Se connnecter ####

# Entrer les informations

#Sys.setenv(ARCGIS_CLIENT = "")
#Sys.setenv(ARCGIS_SECRET = "")
url = "https://services2.arcgis.com/RkhyeW7cqOfSjlQG/arcgis/rest/services/survey123_b0629c60e7d54bc0aad0d5892ab14804_results/FeatureServer"
# note: faire un .Renviron avec ces infos (sécurité)

# Authentification
# NOTE: Sur shiny il faut regénérer le token, car expire après 2 heures
token <- auth_client()

# Ouvrir
service <- arc_open(url, token = token)
layer <- arc_open(paste0(url, "/0"), token = token)

df <- arc_select(layer, where = "1=1", token = token) # 1=1: retourne toutes les lignes

# Créer la BD utilisée pour shiny
df2 = df %>%
  dplyr::select("bonjour", "combien", "CreationDate") %>%
  rename("Salutations" = "bonjour",
         "Nombre" = "combien",
         "Date" = "CreationDate")

df3 = df2 %>%
  mutate(Salutations = as.factor(Salutations),
         Nombre2 = Nombre + 5) %>%
  relocate(Date, Salutations, Nombre, Nombre2) %>%
  st_drop_geometry()

bonus = df3 %>%
  dplyr::select(Nombre, Nombre2) %>%
  mutate(Nb1 = sqrt(Nombre),
         Nb2 = sqrt(Nombre2))

# Sauvegarder
data_shiny <- list(
  df3 = df3,
  bonus = bonus)

saveRDS(data_shiny, "data/donnees_pretes.rds")


# VOIR SI ULAVAL A DEJA POSIT CONNECT 
# demander si: l'application doit etre privee, deja de quoi avec l'UL??, combien de fichiers utilisés par shiny, budget
