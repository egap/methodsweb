

suppressMessages({
  library(tidyverse)
  library(sf)
  sf::sf_use_s2(FALSE)
  library(countrycode)
  library(rnaturalearth)
})

participant_countries <-
  readxl::read_excel("_map/EGAP_LD_participants.xlsx") %>%
  mutate(iso3c = countrycode::countrycode(`Primary Country`, "country.name", "iso3c")) |> 
  count(iso3c)

host_countries <- 
  readxl::read_excel("_map/EGAP_LD_participants.xlsx") |> 
  distinct(`Workshop Attended`) |> 
  separate(`Workshop Attended`, into = c("site", "year"), sep = "\\(") |> 
  mutate(
    year = str_replace(year, "\\)", ""),
    city = str_squish(site), 
    country = str_squish(site),
    city = case_when(
      city == "Malawi" ~ "Lilongwe",
      city == "Guatemala" ~ "Guatemala City",
      city == "Uruguay" ~ "Montevideo",
      city == "Benin" ~ "Porto-Novo",
      TRUE ~ city
    ),
    country = case_when(
      country == "Accra" ~ "Ghana",
      country == "Bogotá" ~ "Colombia",
      country == "Abidjan" ~ "Cote d'Ivoire",
      country == "Santiago" ~ "Chile",
      country == "Abu Dhabi" ~ "UAE",
      TRUE ~ country
    )
  ) |> 
  select(-site) |> 
  mutate(iso3c = countrycode::countrycode(country, "country.name", "iso3c"))



# library(rworldmap) # for getMap()

countries <- rnaturalearth::ne_countries(scale = 110) %>% st_as_sf %>% filter(is.na(tiny))

cities <- rnaturalearth::ne_download(scale = 110, type = "populated_places") %>% st_as_sf

cities_hosts <- cities |> 
  right_join(host_countries, by = c("NAME" = "city", "ADM0_A3" = "iso3c"))

countries <-
  countries %>%
  left_join(participant_countries %>% transmute(iso3c, n), by = c("adm0_a3" = "iso3c")) %>%
  mutate(n = replace_na(n, 0)) |> 
  filter(name != "Antarctica")

crs_robin <- "+proj=robin +lat_0=0 +lon_0=0 +x0=0 +y0=0"
# projection outline in long-lat coordinates
lats <- c(90:-90,-90:90, 90)
longs <- c(rep(c(180,-180), each = 181), 180)
robin_outline <-
  list(cbind(longs, lats)) %>%
  st_polygon() %>%
  st_sfc(crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") %>%
  st_transform(crs = crs_robin)
# bounding box in transformed coordinates
xlim <- c(-18494733, 18613795)
ylim <- c(-9473396, 9188587)
robin_bbox <-
  list(cbind(
    c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]),
    c(ylim[1], ylim[1], ylim[2], ylim[2], ylim[1])
  )) %>%
  st_polygon() %>%
  st_sfc(crs = crs_robin)
# area outside the earth outline
robin_without <- st_difference(robin_bbox, robin_outline)

label_pts <- 
  countries %>% 
  st_centroid() %>% 
  mutate(
    x = sf::st_coordinates(.)[,1],
    y = sf::st_coordinates(.)[,2]
  ) %>% 
  as_tibble

# devtools::install_github("yutannihilation/ggsflabel")
library(ggsflabel)

gg <-
  ggplot(countries) +
  geom_sf(
    fill = "white", alpha = 0.65,
    color = NA) +
  geom_sf(
    data = countries %>% filter(n > 0),
    aes(alpha = n),
    fill = "#F5520A",
    color = NA,
    size = 0) +
  geom_sf(
    fill = NA,
    color = gray(0.7),
    size = 0.1 / .pt) +
  geom_sf(data = cities_hosts, color = "white", pch = 19, size = 2) + 
  geom_sf(data = cities_hosts, color = "#202A38", pch = 19) + 
  # geom_sf_text_repel(data = cities_hosts, aes(label = paste(NAME, "\n", year)), color = "darkblue") +
  scale_x_continuous(name = NULL, breaks = seq(-120, 120, by = 60)) +
  scale_y_continuous(name = NULL, breaks = seq(-60, 60, by = 30)) +
  coord_sf(
    xlim = 0.95 * xlim,
    ylim = 0.95 * ylim,
    expand = FALSE,
    crs = crs_robin,
    ndiscr = 1000
  ) +
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",
    plot.margin = unit(c(-0.30, 0, 0, 0), "null")
  )

gg

ggsave("img/ldmap.svg", width = 5, height = 3, gg)
