#!/bin/python
import numpy as np

start_year = 2017
end_year = 2021
start_doy = 313
end_doy = 365
out_file = "url_list.txt"
file = open(out_file, 'w')

years = np.arange(start_year, end_year+1)
for year in years:
    if year == start_year:
        doy_start = start_doy
    else:
        doy_start = 1
    if year == end_year:
        doy_end = end_doy
    else:
        if np.mod(year,4)==0:
            doy_end = 366
        else:
            doy_end = 365
    for doy in np.arange(doy_start, doy_end+1):
        doy_formatted = "{:03d}".format(doy)
        url = "https://data.earthscope.org/archive/gnss/rinex/obs/" + str(year) + "/" + doy_formatted + "/tylg" + doy_formatted + "0." + str(year-2000) + "d.Z\n"
        file.write(url)

file.close()
    
print('done')
