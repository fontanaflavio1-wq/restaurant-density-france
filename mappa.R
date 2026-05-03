# Densità di ristoranti (INSEE BPE, tipologia A504) nel sud della Francia.
# Scarica CSV e GeoJSON, poi mappa cloropletica per comune con ggplot2 + sf.

library(sf)
library(ggplot2)
library(dplyr)

url_csv <- "https://raw.githubusercontent.com/holtzy/R-graph-gallery/master/DATA/data_on_french_states.csv"
url_geojson <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson"

data_dir <- file.path(getwd(), "data")
csv_path <- file.path(data_dir, "data_on_french_states.csv")
geo_path <- file.path(data_dir, "communes.geojson")

dir.create(data_dir, showWarnings = FALSE)

opts <- options(timeout = max(600, getOption("timeout")))
on.exit(options(opts), add = TRUE)

download.file(url_csv, destfile = csv_path, mode = "wb")
download.file(url_geojson, destfile = geo_path, mode = "wb")

# Occitanie, PACA, Corse — codici dipartimento INSEE
south_dep <- c(
  "04", "05", "06",
  "09", "11", "12",
  "13", "30", "31", "32", "34",
  "46", "48", "65", "66", "81", "82", "83", "84",
  "2A", "2B"
)

dep_from_commune_code <- function(code) {
  code <- trimws(as.character(code))
  dplyr::case_when(
    grepl("^2[AB]", code) ~ substr(code, 1L, 2L),
    substr(code, 1L, 2L) == "97" ~ substr(code, 1L, 3L),
    TRUE ~ substr(code, 1L, 2L)
  )
}

equip_raw <- utils::read.csv2(
  csv_path,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)
names(equip_raw) <- tolower(names(equip_raw))

# Codice commune INSEE dalla colonna iris (togliendo suffisso sotto-distretto)
commune_from_iris <- function(x) {
  x <- trimws(as.character(x))
  sub("_.*", "", x)
}

restaurants_commune <- equip_raw %>%
  filter(toupper(.data$typequ) == "A504") %>%
  mutate(code = commune_from_iris(.data$dciris)) %>%
  mutate(dept = dep_from_commune_code(.data$code)) %>%
  filter(as.character(.data$dept) %in% south_dep) %>%
  group_by(code = .data$code) %>%
  summarise(n_restaurants = sum(as.numeric(.data$nb_equip), na.rm = TRUE), .groups = "drop")

communes_sf <- st_read(geo_path, quiet = TRUE) %>%
  mutate(
    dept = dep_from_commune_code(.data$code),
    code = trimws(as.character(.data$code))
  ) %>%
  filter(.data$dept %in% south_dep) %>%
  st_transform(crs = 2154) %>%
  left_join(restaurants_commune, by = "code") %>%
  mutate(n_restaurants = coalesce(as.integer(.data$n_restaurants), 0L))

communes_sf$density_per_km2 <-
  communes_sf$n_restaurants / (as.numeric(st_area(communes_sf)) / 1e6)

ggplot(communes_sf) +
  geom_sf(aes(fill = .data$density_per_km2), colour = NA, linewidth = 0) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "sqrt",
    direction = -1,
    name = expression("Restauranti / km"^2)
  ) +
  coord_sf(expand = FALSE) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    legend.position = "right"
  ) +
  labs(
    title = "Densità dei ristoranti per comune (Sud della Francia)",
    subtitle = paste(
      "Dati INSEE 2016, tipologia équipement A504 —",
      "Occitanie, PACA e Corsica"
    ),
    caption = paste(
      "CSV: github.com/holtzy/R-graph-gallery —",
      "GeoJSON communes: github.com/gregoiredavid/france-geojson"
    )
  )
