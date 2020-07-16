#!/usr/bin/env python

import sys
import os
import netCDF4
import numpy as np

error_message   = '\n \033[91m' + 'Error:'   + '\033[0m'      # Red    error   message
warning_message = '\n \033[93m' + 'Warning:' + '\033[0m'      # Yellow warning message

# The vertices fields on an ORCA1 grid have the following dimension sizes (used to check whether the considered grid is ORCA1):
orca1_grid_shape   = ( 292,  362, 4)
orca025_grid_shape = (1050, 1442, 4)

def load_vertices(vertices_file_name):
    # Loading once at the start the NEMO longitude and latitude vertices from a netcdf file:
    nemo_vertices_file_name=os.path.join("../nemo-vertices", vertices_file_name)
    if os.path.isfile(nemo_vertices_file_name) == False: print(error_message, ' The netcdf data file ', nemo_vertices_file_name, '  does not exist.\n'); sys.exit()
    nemo_vertices_netcdf_file = netCDF4.Dataset(nemo_vertices_file_name, 'r')
    lon_vertices_from_nemo_tmp = nemo_vertices_netcdf_file.variables["vertices_longitude"]
    lat_vertices_from_nemo_tmp = nemo_vertices_netcdf_file.variables["vertices_latitude"]
    lon_vertices_from_nemo = np.array(lon_vertices_from_nemo_tmp[...], copy=True)
    lat_vertices_from_nemo = np.array(lat_vertices_from_nemo_tmp[...], copy=True)
    nemo_vertices_netcdf_file.close()
    return lon_vertices_from_nemo, lat_vertices_from_nemo

def load_lon_lat(path, lon_lat_file_name, lonvarname, latvarname):
    # Loading once at the start the cmorised longitudes and latitudes from a netcdf file:
    cmorised_lon_lat_file_name=os.path.join(path, lon_lat_file_name)
    if os.path.isfile(cmorised_lon_lat_file_name) == False: print(error_message, ' The netcdf data file ', cmorised_lon_lat_file_name, '  does not exist.\n'); sys.exit()
    cmorised_lon_lat_netcdf_file = netCDF4.Dataset(cmorised_lon_lat_file_name, 'r')
    lon_from_nemo_tmp = cmorised_lon_lat_netcdf_file.variables[lonvarname]
    lat_from_nemo_tmp = cmorised_lon_lat_netcdf_file.variables[latvarname]
    lon_from_nemo = np.array(lon_from_nemo_tmp[...], copy=True)
    lat_from_nemo = np.array(lat_from_nemo_tmp[...], copy=True)
    cmorised_lon_lat_netcdf_file.close()
    return lon_from_nemo, lat_from_nemo

# Load the vertices fields (Note these are global variables which otherwise have to be given as arguments via the function process_file to the function fix_file):
lon_vertices_from_nemo_orca1_t_grid, lat_vertices_from_nemo_orca1_t_grid = load_vertices("nemo-vertices-ORCA1-t-grid.nc")
lon_vertices_from_nemo_orca1_u_grid, lat_vertices_from_nemo_orca1_u_grid = load_vertices("nemo-vertices-ORCA1-u-grid.nc")
lon_vertices_from_nemo_orca1_v_grid, lat_vertices_from_nemo_orca1_v_grid = load_vertices("nemo-vertices-ORCA1-v-grid.nc")
# Convert the vertices_longitude to the 0-360 degree interval:
lon_vertices_from_nemo_orca1_t_grid = np.where(lon_vertices_from_nemo_orca1_t_grid < 0, lon_vertices_from_nemo_orca1_t_grid + 360.0, lon_vertices_from_nemo_orca1_t_grid)
lon_vertices_from_nemo_orca1_u_grid = np.where(lon_vertices_from_nemo_orca1_u_grid < 0, lon_vertices_from_nemo_orca1_u_grid + 360.0, lon_vertices_from_nemo_orca1_u_grid)
lon_vertices_from_nemo_orca1_v_grid = np.where(lon_vertices_from_nemo_orca1_v_grid < 0, lon_vertices_from_nemo_orca1_v_grid + 360.0, lon_vertices_from_nemo_orca1_v_grid)

# Load the vertices fields (Note these are global variables which otherwise have to be given as arguments via the function process_file to the function fix_file):
lon_vertices_from_nemo_orca025_t_grid, lat_vertices_from_nemo_orca025_t_grid = load_vertices("nemo-vertices-ORCA025-t-grid.nc")
lon_vertices_from_nemo_orca025_u_grid, lat_vertices_from_nemo_orca025_u_grid = load_vertices("nemo-vertices-ORCA025-u-grid.nc")
lon_vertices_from_nemo_orca025_v_grid, lat_vertices_from_nemo_orca025_v_grid = load_vertices("nemo-vertices-ORCA025-v-grid.nc")
# Convert the vertices_longitude to the 0-360 degree interval:
lon_vertices_from_nemo_orca025_t_grid = np.where(lon_vertices_from_nemo_orca025_t_grid < 0, lon_vertices_from_nemo_orca025_t_grid + 360.0, lon_vertices_from_nemo_orca025_t_grid)
lon_vertices_from_nemo_orca025_u_grid = np.where(lon_vertices_from_nemo_orca025_u_grid < 0, lon_vertices_from_nemo_orca025_u_grid + 360.0, lon_vertices_from_nemo_orca025_u_grid)
lon_vertices_from_nemo_orca025_v_grid = np.where(lon_vertices_from_nemo_orca025_v_grid < 0, lon_vertices_from_nemo_orca025_v_grid + 360.0, lon_vertices_from_nemo_orca025_v_grid)

def show_incorrect_selection_point_values():
    # Determine a distinguising point with which help we can distinguish the t, u and v grid (Needed for the vertices correction):
    # Load the vertices fields (Note these are global variables which otherwise have to be given as arguments via the function process_file to the function fix_file):
    lon_vertices_from_incorrect_cmorised_orca1_t_grid, lat_vertices_from_incorrect_cmorised_orca1_t_grid = load_vertices("incorrect-cmorised-vertices-ORCA1-t-grid.nc")
    lon_vertices_from_incorrect_cmorised_orca1_u_grid, lat_vertices_from_incorrect_cmorised_orca1_u_grid = load_vertices("incorrect-cmorised-vertices-ORCA1-u-grid.nc")
    lon_vertices_from_incorrect_cmorised_orca1_v_grid, lat_vertices_from_incorrect_cmorised_orca1_v_grid = load_vertices("incorrect-cmorised-vertices-ORCA1-v-grid.nc")
    print('lon vertex cmor t-grid for ORCA1: ', lon_vertices_from_incorrect_cmorised_orca1_t_grid[290,105,1])       # 250.39437866210938  this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex cmor u-grid for ORCA1: ', lon_vertices_from_incorrect_cmorised_orca1_u_grid[290,105,1])       # 250.52598571777344  this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex cmor v-grid for ORCA1: ', lon_vertices_from_incorrect_cmorised_orca1_v_grid[290,105,1])       # 253.0               this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex nemo t-grid for ORCA1: ', lon_vertices_from_nemo_orca1_t_grid[290,105,1])                     # 247.78886
    print('lon vertex nemo u-grid for ORCA1: ', lon_vertices_from_nemo_orca1_u_grid[290,105,1])                     # 248.04973
    print('lon vertex nemo v-grid for ORCA1: ', lon_vertices_from_nemo_orca1_v_grid[290,105,1])                     # 250.40128
    print('lat vertex nemo t-grid for ORCA1: ', lat_vertices_from_nemo_orca1_t_grid[290,105,1])                     # 85.726585
    print('lat vertex nemo u-grid for ORCA1: ', lat_vertices_from_nemo_orca1_u_grid[290,105,1])                     # 85.51555
    print('lat vertex nemo v-grid for ORCA1: ', lat_vertices_from_nemo_orca1_v_grid[290,105,1])                     # 85.74064
    print('')
    # WAITING FOR INCORRECT CMORISED ORCA025 T-, U-, V-GRID files:
    lon_vertices_from_incorrect_cmorised_orca025_t_grid, lat_vertices_from_incorrect_cmorised_orca025_t_grid = load_vertices("incorrect-cmorised-vertices-ORCA025-t-grid.nc")
    lon_vertices_from_incorrect_cmorised_orca025_u_grid, lat_vertices_from_incorrect_cmorised_orca025_u_grid = load_vertices("incorrect-cmorised-vertices-ORCA025-u-grid.nc")
    lon_vertices_from_incorrect_cmorised_orca025_v_grid, lat_vertices_from_incorrect_cmorised_orca025_v_grid = load_vertices("incorrect-cmorised-vertices-ORCA025-v-grid.nc")
    print('lon vertex cmor t-grid for ORCA025: ', lon_vertices_from_incorrect_cmorised_orca025_t_grid[290,105,1])   # 250.39437866210938  this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex cmor u-grid for ORCA025: ', lon_vertices_from_incorrect_cmorised_orca025_u_grid[290,105,1])   # 250.52598571777344  this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex cmor v-grid for ORCA025: ', lon_vertices_from_incorrect_cmorised_orca025_v_grid[290,105,1])   # 253.0               this concerns the buggy cmorised data therefore this value is used to detect whether the data set is incorrect
    print('lon vertex nemo t-grid for ORCA025: ', lon_vertices_from_nemo_orca025_t_grid[290,105,1])                 # 247.78886
    print('lon vertex nemo u-grid for ORCA025: ', lon_vertices_from_nemo_orca025_u_grid[290,105,1])                 # 248.04973
    print('lon vertex nemo v-grid for ORCA025: ', lon_vertices_from_nemo_orca025_v_grid[290,105,1])                 # 250.40128
    print('lat vertex nemo t-grid for ORCA025: ', lat_vertices_from_nemo_orca025_t_grid[290,105,1])                 # 85.726585
    print('lat vertex nemo u-grid for ORCA025: ', lat_vertices_from_nemo_orca025_u_grid[290,105,1])                 # 85.51555
    print('lat vertex nemo v-grid for ORCA025: ', lat_vertices_from_nemo_orca025_v_grid[290,105,1])                 # 85.74064
    print('')
show_incorrect_selection_point_values()


# Load the longitude and latitude fields from the incorrect cmorised ORCA1 grid:
lon_from_cmorised_orca1_t_grid, lat_from_cmorised_orca1_t_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "tos-ORCA1-t-grid-incorrect-cmorised.nc", "longitude", "latitude")
lon_from_cmorised_orca1_u_grid, lat_from_cmorised_orca1_u_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "uo-ORCA1-u-grid-incorrect-cmorised.nc" , "longitude", "latitude")
lon_from_cmorised_orca1_v_grid, lat_from_cmorised_orca1_v_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "vo-ORCA1-v-grid-incorrect-cmorised.nc" , "longitude", "latitude")
i = 290
j = 105
print(' (lon, lat) at ORCA1 t-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_cmorised_orca1_t_grid[i,j], lat_from_cmorised_orca1_t_grid[i,j])) # 250.2568359375     85.9527359008789
print(' (lon, lat) at ORCA1 u-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_cmorised_orca1_u_grid[i,j], lat_from_cmorised_orca1_u_grid[i,j])) # 250.40127563476562 85.74063873291016
print(' (lon, lat) at ORCA1 v-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_cmorised_orca1_v_grid[i,j], lat_from_cmorised_orca1_v_grid[i,j])) # 253.0              85.9576187133789
print('')



# Load the longitude and latitude fields from the NEMO ORCA1 grid:
lon_from_nemo_orca1_t_grid, lat_from_nemo_orca1_t_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "tos-ORCA1-t-grid-nemo.nc", "nav_lon", "nav_lat")
lon_from_nemo_orca1_u_grid, lat_from_nemo_orca1_u_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "uo-ORCA1-u-grid-nemo.nc" , "nav_lon", "nav_lat")
lon_from_nemo_orca1_v_grid, lat_from_nemo_orca1_v_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA1", "vo-ORCA1-v-grid-nemo.nc" , "nav_lon", "nav_lat")
# Convert the vertices_longitude to the 0-360 degree interval:
lon_from_nemo_orca1_t_grid = np.where(lon_from_nemo_orca1_t_grid < 0, lon_from_nemo_orca1_t_grid + 360.0, lon_from_nemo_orca1_t_grid)
lon_from_nemo_orca1_u_grid = np.where(lon_from_nemo_orca1_u_grid < 0, lon_from_nemo_orca1_u_grid + 360.0, lon_from_nemo_orca1_u_grid)
lon_from_nemo_orca1_v_grid = np.where(lon_from_nemo_orca1_v_grid < 0, lon_from_nemo_orca1_v_grid + 360.0, lon_from_nemo_orca1_v_grid)
i = 290
j = 105
print(' (lon, lat) at ORCA1 t-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca1_t_grid[i,j], lat_from_nemo_orca1_t_grid[i,j])) # 
print(' (lon, lat) at ORCA1 u-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca1_u_grid[i,j], lat_from_nemo_orca1_u_grid[i,j])) # 
print(' (lon, lat) at ORCA1 v-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca1_v_grid[i,j], lat_from_nemo_orca1_v_grid[i,j])) # 
print('')

if (lon_from_cmorised_orca1_t_grid == lon_from_nemo_orca1_t_grid).all():
 print(' Ok: lon_from_cmorised_orca1_t_grid = lon_from_nemo_orca1_t_grid')
else:
 difference = np.subtract(lon_from_cmorised_orca1_t_grid, lon_from_nemo_orca1_t_grid)
#print(difference)
 counter = 0
 Ni = lon_from_cmorised_orca1_t_grid.shape[0]
 Nj = lon_from_cmorised_orca1_t_grid.shape[1]
 for j in range(Nj):
  for i in range(Ni):
    if difference[i][j] > 1.e-4:
     print(i, j, difference[i][j])
     counter = counter +1
 print('', 100 * counter / (Ni * Nj), '% exceeds the criterium\n')

np.subtract(lon_from_cmorised_orca1_t_grid, lon_from_nemo_orca1_t_grid)

# Load the longitude and latitude fields from the NEMO ORCA1 grid:
lon_from_nemo_orca025_t_grid, lat_from_nemo_orca025_t_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA025", "tos-ORCA025-t-grid-nemo.nc", "nav_lon", "nav_lat")
lon_from_nemo_orca025_u_grid, lat_from_nemo_orca025_u_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA025", "uo-ORCA025-u-grid-nemo.nc" , "nav_lon", "nav_lat")
lon_from_nemo_orca025_v_grid, lat_from_nemo_orca025_v_grid = load_lon_lat("../nemo-vertices/compare-vertices-ORCA025", "vo-ORCA025-v-grid-nemo.nc" , "nav_lon", "nav_lat")
i = 290
j = 105
print(' (lon, lat) at ORCA025 t-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca025_t_grid[i,j], lat_from_nemo_orca025_t_grid[i,j])) # 
print(' (lon, lat) at ORCA025 u-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca025_u_grid[i,j], lat_from_nemo_orca025_u_grid[i,j])) # 
print(' (lon, lat) at ORCA025 v-grid [{:1},{:1}] = {:4.15f} {:}'.format(i, j, lon_from_nemo_orca025_v_grid[i,j], lat_from_nemo_orca025_v_grid[i,j])) # 
print('')





# Check if longitudes & latitudes are inbetween their vertices:

# The vertices are probably counter clockwise stored at the 0-3 index in the vertex array starting at the zero index
# with the upper left vertex in terms of the i,j curvilinear indices:

# However, it turns out that this is tricky: the curvilinear ORCA grid is such deformed ner the two ORCA poles that
# the 'simple logic' concerning the coordinate values and their bounds values does not hold

def print_lonlat_and_vertices_of_some_point(i, j, string, lon, lon_vertices, lat, lat_vertices):
    # For testing: Just to study the values at the a given stagered grid in some central point:
    print('')
    print('lon at', string, '[', i, '][', j, '][0] =', lon[i][j], '>', lon_vertices[i][j][0])
    print('lon at', string, '[', i, '][', j, '][1] =', lon[i][j], '<', lon_vertices[i][j][1])
    print('lon at', string, '[', i, '][', j, '][2] =', lon[i][j], '<', lon_vertices[i][j][2])
    print('lon at', string, '[', i, '][', j, '][3] =', lon[i][j], '>', lon_vertices[i][j][3])
    print('')
    print('lat at', string, '[', i, '][', j, '][0] =', lat[i][j], '>', lat_vertices[i][j][0])
    print('lat at', string, '[', i, '][', j, '][1] =', lat[i][j], '>', lat_vertices[i][j][1])
    print('lat at', string, '[', i, '][', j, '][2] =', lat[i][j], '<', lat_vertices[i][j][2])
    print('lat at', string, '[', i, '][', j, '][3] =', lat[i][j], '<', lat_vertices[i][j][3])
#print_lonlat_and_vertices_of_some_point(i=210, j=110, string='t-grid', lon=lon_from_cmorised_orca1_t_grid, lon_vertices=lon_vertices_from_nemo_orca1_t_grid, lat=lat_from_cmorised_orca1_t_grid, lat_vertices=lat_vertices_from_nemo_orca1_t_grid)
#print_lonlat_and_vertices_of_some_point(i=290, j=105, string='t-grid', lon=lon_from_cmorised_orca1_t_grid, lon_vertices=lon_vertices_from_nemo_orca1_t_grid, lat=lat_from_cmorised_orca1_t_grid, lat_vertices=lat_vertices_from_nemo_orca1_t_grid)


def check_vertices_positions(lon, lat, lon_vertices, lat_vertices):
    # orca1_grid_shape = (row=292, column=362, 4)
    ni = lon[...].shape[0]
    nj = lon[...].shape[1]

    counter_correct = 0.
    counter_incorrect = 0.
    for j in range(0, nj - 0):
        for i in range(0, ni - 0):
       #for i in range(0, ni - 40):                         # This criterium reduces the non-matching ones from 9.98% to 1.2%
          #if((lon[i][j] > 5) and (lon[i][j] < 355)):       # This criterium seems to have no significant effect
           #print(i, j, lon[i][j])
            if lon[i][j] > lon_vertices[i][j][0] and \
               lon[i][j] < lon_vertices[i][j][1] and \
               lon[i][j] < lon_vertices[i][j][2] and \
               lon[i][j] > lon_vertices[i][j][3] and \
               lat[i][j] > lat_vertices[i][j][0] and \
               lat[i][j] > lat_vertices[i][j][1] and \
               lat[i][j] < lat_vertices[i][j][2] and \
               lat[i][j] < lat_vertices[i][j][3]:
               counter_correct = counter_correct + 1.
            else:
               print('Wrong:')
               print('lon[', i, '][', j, '][0] =', lon[i][j], '>', lon_vertices[i][j][0])
               print('lon[', i, '][', j, '][1] =', lon[i][j], '<', lon_vertices[i][j][1])
               print('lon[', i, '][', j, '][2] =', lon[i][j], '<', lon_vertices[i][j][2])
               print('lon[', i, '][', j, '][3] =', lon[i][j], '>', lon_vertices[i][j][3])
               print('lat[', i, '][', j, '][0] =', lat[i][j], '>', lat_vertices[i][j][0])
               print('lat[', i, '][', j, '][1] =', lat[i][j], '>', lat_vertices[i][j][1])
               print('lat[', i, '][', j, '][2] =', lat[i][j], '<', lat_vertices[i][j][2])
               print('lat[', i, '][', j, '][3] =', lat[i][j], '<', lat_vertices[i][j][3])
               counter_incorrect = counter_incorrect + 1.
    print('Matching vertices: ', counter_correct, 'Non matching vertices: ', counter_incorrect, 'Incorrect percentage: ', 100. * counter_incorrect / (ni * nj))

#check_vertices_positions(lon_from_cmorised_orca1_t_grid, lat_from_cmorised_orca1_t_grid, lon_vertices_from_nemo_orca1_t_grid, lat_vertices_from_nemo_orca1_t_grid)
