# Site map
library(raster)
library(RStoolbox)
library(sf)
library(tidyverse)

# Read in Sentinel imagery
v1 <<- brick('data/gis/sentinel2_raw_2019_11_18_Bonney.tif')
ggRGB(v1, r=1, g=2, b=3, stretch = 'sqrt') 
ggRGB(v1, r = 3, g = 2, b = 1, stretch = "lin", clipValues = c(0.02, 0.98))


# Get range for each band
ranges <- sapply(1:nlayers(v1), function(i) {
  range(values(v1[[i]]), na.rm = TRUE)
})

# Transpose for readability
t(ranges)

# Load sites (Taylor Glacier GPS, Lake Bonney thermistors, Blood Falls camera)
sites <- data.frame(
  Site = c("TG", "LB", "BF.C"),
  Lat  = c(-77.7256, -77.723, -77.71965),
  Lon  = c(162.2653, 162.285, 162.274533)
)

# Lake Bonney instrument sites (all thermister strings)
wlb.sites <- data.frame(
  Site = c("wlb-tchain-e1415",
           "wlb-tchain-w1415",
           "wlb-w-1516-ctd",
           "wlb-w-1516-tch",
           "wlb-e_1516"),
  Lat = c(-77.72069,
          -77.72114,
          -77.72312,
          -77.72313,
          -77.722250),
  Lon = c(162.28675,
          162.28126,
          162.28512,
          162.28503,
          162.288283)
)
# Convert to sf spatial points
sites_sf <- st_as_sf(sites, coords = c("Lon", "Lat"), crs = 4326)  # 4326 = WGS84
sites_sf <- sites_sf |> st_transform(st_crs(v1))

# Convert to sf spatial points
sites_wlb_sf <- st_as_sf(wlb.sites, coords = c("Lon", "Lat"), crs = 4326)  # 4326 = WGS84
sites_wlb_sf <- sites_wlb_sf |> st_transform(st_crs(v1))

# stretch = Character. Either 'none', 'lin', 'hist', 'sqrt' or 'log' for no stretch, 
# linear, histogram, square-root or logarithmic stretch.
# Plot flight lines
ggRGB(v1, r=3, g=2, b=1, stretch = "sqrt", clipValues = c(0.02, 0.98)) +
  geom_sf(data = sites_sf, shape = 22, fill = c('gold', '#54a5c4', '#ba532b'), size = 2) +
  # geom_sf(data = sites_wlb_sf, shape = 21, size = 2) + # Don't plot all sites
  theme_bw(base_size = 7) +
  scale_x_continuous(expand = expansion(0)) + 
  scale_y_continuous(expand = expansion(0)) +
  theme(axis.title = element_blank()) +
  annotate("text", 
           x = 435859.6,   # longitude (adjust to center on lake)
           y = 1371925,   # latitude (adjust to center on lake)
           label = "Lake Bonney",
           angle = 28,    # rotate text
           size = 3, 
           fontface = "italic", 
           color = "grey90") +
  annotate("text", 
           x = 434000,   # longitude (adjust to center on lake)
           y = 1371250,   # latitude (adjust to center on lake)
           label = "Taylor Glacier",
           angle = 10,    # rotate text
           size = 3, 
           fontface = "italic", 
           color = "grey90")

ggsave('figures/Figure1_map.png', width = 3, height = 1.8, dpi = 500)

