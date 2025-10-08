# library(oce)
library(tidyverse)
library(patchwork)
library(scales)

# Use dates for "event"
usedates = data.frame(startdate = as.POSIXct(c('2018-09-01'), tz = 'UTC')) |> 
  mutate(enddate = startdate + days(75))

# Read in TG GPS data from Matt
tg = read_csv('data/tylg/tylg_daily_15day.csv') |> 
  select(datetime = time_mean, velocity_m_d = `velocity (m/d)`, z_median) |> 
  filter(datetime >= as.Date('2018-05-01') & datetime <= as.Date('2019-05-01')) 

range_velocity_all <- range(tg$velocity_m_d)
range_z_all <- range(tg$z_median)
tg <- tg %>%
  mutate(z_median_scaled = scales::rescale(z_median, to = range_velocity_all, from = range_z_all))

p1 = ggplot(tg, aes(x = datetime)) +
  geom_rect(inherit.aes = FALSE, data = data.frame( xmin = as.POSIXct('2018-09-05'), xmax = as.POSIXct('2018-10-22'), ymin = -Inf, ymax = Inf),
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = '#ede3be', alpha = 0.5, color = 'black', linetype = 2, linewidth = 0.2) +
  # geom_line(aes(y = velocity_m_d), color = "#647587") +
  # geom_line(aes(y = z_median_scaled), color = "#a85c32") +
  geom_point(aes(y = velocity_m_d), color = "#647587", size = 0.3) +
  geom_point(aes(y = z_median_scaled), color = "#a85c32", size = 0.3) +
  scale_y_continuous(
    name = expression("Velocity (m d"^{-1}*")"),
    sec.axis = sec_axis(~ scales::rescale(., to = range_z_all, from = range_velocity_all), name = "Elevation")
  ) +
  scale_x_datetime(expand = c(0,0), breaks = '3 months',  labels = date_format("%b %Y")) +
  theme_bw(base_size = 8) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(size = 7),
        axis.title.y.left = element_text(color = "#647587"),
        axis.title.y.right = element_text(color = "#a85c32")); p1

# Plot second panel
tg.date = tg |> filter(datetime >= usedates$startdate[1] & datetime <= usedates$enddate[1]) |> 
  mutate(z_diff = 1000*(z_median - z_median[1]))

range_velocity <- range(tg.date$velocity_m_d)
range_z <- range(tg.date$z_diff)

tg.date <- tg.date %>%
  mutate(z_median_scaled = scales::rescale(z_diff, to = range_velocity, from = range_z))

p2 = ggplot(tg.date, aes(x = datetime)) +
  geom_rect(inherit.aes = FALSE, data = data.frame( xmin = as.POSIXct('2018-09-05'), xmax = as.POSIXct('2018-10-22'), ymin = -Inf, ymax = Inf),
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = '#ede3be', alpha = 0.1, color = 'black', linetype = 2) +
  geom_point(aes(y = velocity_m_d), color = "#647587", size = 0.3) +
  geom_point(aes(y = z_median_scaled), color = "#a85c32", size = 0.3) +
  scale_y_continuous(
    name = expression("Velocity (m d"^{-1}*")"),
    sec.axis = sec_axis(~ scales::rescale(., to = range_z, from = range_velocity), name = "Z Diff (mm)")
  ) +
  scale_x_datetime(expand = c(0,0), breaks = '2 weeks',  labels = date_format("%b %d")) +
  labs(y = "Elevation") +
  theme_bw(base_size = 8) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(size = 7),
        axis.title.y.left = element_text(color = "#647587"),
        axis.title.y.right = element_text(color = "#a85c32")); p2

# Panel 3: WLB thermistor data 
# Read in WLB data 
wlb.raw = read_csv('data/thermistor/wlb_tstring_w_20180901_20181115.csv')
depths.west = rev(c(12.13, 13.57, 15.01, 16.45, 17.89, 19.33, 20.77, 22.21, 23.65, 25.09))

p3 = ggplot(wlb.raw |> arrange(desc(temp_anomaly_C)), aes(x = dateTime, y = depth_m - temp_anomaly_C, col = temp_anomaly_C)) +
  geom_rect(inherit.aes = FALSE, data = data.frame( xmin = as.POSIXct('2018-09-05'), xmax = as.POSIXct('2018-10-22'), ymin = -Inf, ymax = Inf),
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = '#ede3be', alpha = 0.1, color = 'black', linetype = 2) +
  geom_point(size = 0.5) +
  geom_point(inherit.aes = F, data = data.frame(x = as.POSIXct('2018-09-02'), y = depths.west),
                aes(x = x, y = y), col = 'black', size = 0.5, shape = 17) +
  scale_y_reverse() +
  scale_x_datetime(expand = c(0,0), breaks = '2 weeks',  labels = date_format("%b %d")) +
  scale_color_gradient2(
    low = "#292b54", mid = "#fafcc7", high = "red4", midpoint = 0,
    limits = c(-1.6, 0.5),  # Set min and max
    name = "WLB Temp Anomaly (°C)  ") + 
  labs(y = "Thermistor Depth (m)") +
  labs(x = year(wlb.raw$dateTime[1])) +
  theme_bw(base_size = 8) +
  theme(axis.title.x = element_blank(),
    axis.text.x = element_text(size = 7)); p3

# Combine panels and plot
layout <- "
A
B
C
C
"
p1 + p2 + p3 +
  plot_layout(design = layout, guides = 'collect') +
  plot_annotation(tag_levels = "a", tag_prefix = "(", tag_suffix = ")") & 
  theme(plot.tag = element_text(size = 8),
        plot.margin = margin(t = 0, r = 0.3, b = 0, l = 0),
        legend.position = 'bottom', 
        legend.key.width = unit(0.5, 'cm'),
        legend.key.height = unit(0.1, 'cm'),
        legend.margin = margin(t = 0, r = 0, b = 0, l = 0),   # outer space around legend
        legend.box.margin = margin(t = 0, r = 0, b = 0, l = 0)) # space between legends and plot

ggsave('figures/Figure2.png', width = 3, height = 4, dpi = 500)


# Magnitude of anomalies
wlb.raw |> filter(depth_m == 17.89) |> filter(temp_anomaly_C < -1) |> 
  arrange(temp_anomaly_C)

