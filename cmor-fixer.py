#!/usr/bin/env python

import sys
import math
import argparse
import os
import json
import netCDF4
import logging
import uuid
import numpy as np
import multiprocessing
from functools import partial

error_message   = '\n \033[91m' + 'Error:'   + '\033[0m'      # Red    error   message
warning_message = '\n \033[93m' + 'Warning:' + '\033[0m'      # Yellow warning message

# import datetime

version = 'v3.0'

log = logging.getLogger(os.path.basename(__file__))

skipped_attributes = ["source", "comment"]

# The vertices fields on an ORCA1 grid have the following dimension sizes (used to check whether the considered grid is ORCA1):
orca1_grid_shape   = ( 292,  362, 4)
orca025_grid_shape = (1050, 1442, 4)


def load_vertices(vertices_file_name):
    # Loading once at the start the NEMO longitude and latitude vertices from a netcdf file:
    nemo_vertices_file_name=os.path.join("nemo-vertices", vertices_file_name)
    if os.path.isfile(nemo_vertices_file_name) == False: print(error_message, ' The netcdf data file ', nemo_vertices_file_name, '  does not exist.\n'); sys.exit()
    nemo_vertices_netcdf_file = netCDF4.Dataset(nemo_vertices_file_name, 'r')
    lon_vertices_from_nemo_tmp = nemo_vertices_netcdf_file.variables["vertices_longitude"]
    lat_vertices_from_nemo_tmp = nemo_vertices_netcdf_file.variables["vertices_latitude"]
    lon_vertices_from_nemo = np.array(lon_vertices_from_nemo_tmp[...], copy=True)
    lat_vertices_from_nemo = np.array(lat_vertices_from_nemo_tmp[...], copy=True)
    nemo_vertices_netcdf_file.close()
    return lon_vertices_from_nemo, lat_vertices_from_nemo

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


def fix_file(path, write=True, keepid=False, forceid=False, metadata=None, add_attributes=False):
    ds = netCDF4.Dataset(path, "r+" if write else "r")
    modified = forceid
    if getattr(ds, "grid_label") == "gr":
        lonvars = [v for v in ds.variables if getattr(ds.variables[v], "standard_name", "none").lower() == "longitude"]
        if len(lonvars) > 1:
            log.warning("Multiple longitude coordinates found in %s, processing all of them..." % (ds.filepath()))
        shifted_vars = set()
        for lonvarname in lonvars:
            if lonvarname in shifted_vars:
                continue
            lonvar = ds.variables[lonvarname]
            offset = lonvar[...].flat[0]
            # IFS files only
            if offset > 0.:
                log.info("Shifting longitude westward by %s for variable %s in %s" %
                         (str(offset), lonvarname, ds.filepath()))
                if write:
                    lonvar[...] -= offset
                modified = True
                shifted_vars.add(lonvarname)
                bndvarname = getattr(lonvar, "bounds", None)
                if bndvarname is not None and bndvarname not in shifted_vars:
                    log.info("Shifting longitude bounds westward by %s for variable %s in %s" %
                             (str(offset), lonvarname, ds.filepath()))
                    if write:
                        ds.variables[bndvarname][...] -= offset
                    shifted_vars.add(bndvarname)
            # LPJ-GUESS files only
            else:
                bndvarname = getattr(lonvar, "bounds", None)
                if bndvarname is not None and bndvarname not in shifted_vars:
                    bndvar = ds.variables[bndvarname]
                    lowerbnd = bndvar[...].flat[0]
                    if lowerbnd == offset:
                        shift = 0.5 * (lonvar[...].flat[1] - offset)
                        log.info("Shifting longitude bounds westward by %s for variable %s in %s" %
                                 (str(shift), lonvarname, ds.filepath()))
                        if write:
                            ds.variables[bndvarname][...] -= shift
                        modified = True
                        shifted_vars.add(bndvarname)

    # Correcting siconca: convert from fraction to percentage. See ece2cmor3 issue 627:
    # https://github.com/EC-Earth/ece2cmor3/issues/627
    for key in ds.variables:
    #if key == "siconca" and getattr(ds, "grid_label") == "gr":
     if key == "siconca":
      # Check whether no value is larger than 1: In that case it is very liekly that the field is a fraction
      # between 0 and 1 instead of a percentage. Therefore we will convert it:
      if not (ds.variables[key][...] > 1).any():
       log.info('Convert a fraction to a percentage by multiplying by a factor 100 for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
       if write:
        ds.variables[key][...] = 100.0 * ds.variables[key][...] # Convert the fraction to a percentage
        modified = True

    # Correcting evspsbl: convert from fraction to percentage. See EC-Earth portal issue 768-13:
    # https://dev.ec-earth.org/issues/768#note-13
    for key in ds.variables:
    #if key == "evspsbl" and getattr(ds, "grid_label") == "gr":
     if key == "evspsbl":
      # Check the ratio of total positive and negative field values: if the number of positive field values
      # is smaller than the number of negative values, then the sign will be flipped:
     #print('ratio = ', np.count_nonzero(ds.variables[key][...] > 0) / np.count_nonzero(ds.variables[key][...] < 0))
      if np.count_nonzero(ds.variables[key][...] > 0) < np.count_nonzero(ds.variables[key][...] < 0):
       log.info('Flip the sign of the entire field by multiplying by a factor -1 for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
       if write:
        ds.variables[key][...] = -1.0 * ds.variables[key][...] # Flip the sign of the field values
        modified = True

    # Correcting vertices_longitude and vertices_latitude. See ece2cmor3 issue 625:
    # https://github.com/EC-Earth/ece2cmor3/issues/625
    for key in ds.variables:
     if key == "vertices_longitude" and getattr(ds, "grid_label") == "gn":
      if ds.variables[key][...].shape != orca1_grid_shape and ds.variables[key][...].shape != orca025_grid_shape:
       print(warning_message, 'The cmor-fixer currently only supports the vertices fix for the ORCA1 & ORCA025 grid. Here a different grid size is detected: ', ds.variables[key][...].shape, '\n')
       break
      # Check and veritces fix for the ORCA1 grid:
      if ds.variables[key][...].shape == orca1_grid_shape:
       # In order to detect whether the cmorised file contains vertices which are not based on the NEMO data (and thus have the
       # dateline BUG in the longitude vertices), the values of a single ORCA1 vertices_longitude point [290,105,1] is checked.
       # This point is selected (see the developer-scripts/vertices-checker.py script) because it has always different values on
       # the t, u and v staggered grids and the value is different between the incorrect & corrected data for each of those:
       # Check on t-grid for incorrect cmorised data: if ds.variables[key][290,105,1] equals 250.39437866210938 then it concerns the incorrect data.
       # Check on u-grid for incorrect cmorised data: if ds.variables[key][290,105,1] equals 250.52598571777344 then it concerns the incorrect data.
       # Check on v-grid for incorrect cmorised data: if ds.variables[key][290,105,1] equals 253.0              then it concerns the incorrect data.
       # Note that based on this detection of the vertices_longitude, both the vertices_longitude & vertices_latitude are changed.
       if (math.isclose(ds.variables[key][290,105,1], 250.39437866210938, rel_tol=1e-5) or \
           math.isclose(ds.variables[key][290,105,1], 250.52598571777344, rel_tol=1e-5) or \
           math.isclose(ds.variables[key][290,105,1], 253.0             , rel_tol=1e-5)):
        if   math.isclose(ds.variables[key][290,105,1], 250.39437866210938, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude t-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca1_t_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca1_t_grid[...]  # Replacing the latitude  vertices
          modified = True
        elif math.isclose(ds.variables[key][290,105,1], 250.52598571777344, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude u-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca1_u_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca1_u_grid[...]  # Replacing the latitude  vertices
          modified = True
        elif math.isclose(ds.variables[key][290,105,1], 253.0, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude v-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca1_v_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca1_v_grid[...]  # Replacing the latitude  vertices
          modified = True
        else:
         print(error_message, ' The cmor-fixer failed to determine the staggered grid in the procedure to fix the NEMO vertices. \n'); sys.exit()
      # Check and veritces fix for the ORCA025 grid:
      if ds.variables[key][...].shape == orca025_grid_shape:
       # In order to detect whether the cmorised file contains vertices which are not based on the NEMO data (and thus have the
       # dateline BUG in the longitude vertices), the values of a single ORCA025 vertices_longitude point [1020,1220,1] is checked.
       # This point is selected (see the developer-scripts/vertices-checker.py script) because it has always different values on
       # the t, u and v staggered grids and the value is different between the incorrect & corrected data for each of those:
       # Check on t-grid for incorrect cmorised data: if ds.variables[key][1020,1220,1] equals 63.96732  then it concerns the incorrect data.
       # Check on u-grid for incorrect cmorised data: if ds.variables[key][1020,1220,1] equals 64.00045  then it concerns the incorrect data.
       # Check on v-grid for incorrect cmorised data: if ds.variables[key][1020,1220,1] equals 64.135735 then it concerns the incorrect data.
       # Note that based on this detection of the vertices_longitude, both the vertices_longitude & vertices_latitude are changed.
       if (math.isclose(ds.variables[key][1020,1220,1], 63.96732 , rel_tol=1e-5) or \
           math.isclose(ds.variables[key][1020,1220,1], 64.00045 , rel_tol=1e-5) or \
           math.isclose(ds.variables[key][1020,1220,1], 64.135735, rel_tol=1e-5)):
        if   math.isclose(ds.variables[key][1020,1220,1], 63.96732, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude t-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca025_t_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca025_t_grid[...]  # Replacing the latitude  vertices
          modified = True
        elif math.isclose(ds.variables[key][1020,1220,1], 64.00045, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude u-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca025_u_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca025_u_grid[...]  # Replacing the latitude  vertices
          modified = True
        elif math.isclose(ds.variables[key][1020,1220,1], 64.135735, rel_tol=1e-5):
         log.info('Replacing the longitude and latitude v-grid vertices for %s (%s) in %s' % (key, getattr(ds.variables[key], "standard_name", "none"), ds.filepath()))
         if write:
          ds.variables[key][...]                 = lon_vertices_from_nemo_orca025_v_grid[...]  # Replacing the longitude vertices
          ds.variables["vertices_latitude"][...] = lat_vertices_from_nemo_orca025_v_grid[...]  # Replacing the latitude  vertices
          modified = True
        else:
         print(error_message, ' The cmor-fixer failed to determine the staggered grid in the procedure to fix the NEMO vertices. \n'); sys.exit()

    if metadata is not None:
        for key, val in metadata.items():
            attname, attval = str(key), val
            if attname.startswith('#') or attname in skipped_attributes:
                continue
            if (not hasattr(ds, attname) and add_attributes) or \
                    (hasattr(ds, attname) and str(getattr(ds, attname)) != str(attval)):
                log.info("Setting metadata field %s to %s in %s" % (attname, attval, ds.filepath()))
                if write:
                    setattr(ds, attname, attval)
                modified = True
    if modified and not keepid:
        tr_id = '/'.join(["hdl:21.14100", (str(uuid.uuid4()))])
        log.info("Setting tracking_id to %s for %s" % (tr_id, ds.filepath()))
        if write:
            setattr(ds, "tracking_id", tr_id)
    if modified:
        history = getattr(ds, "history", "")
        log.info("Appending message about modification to the history attribute.")
        log.info("The latest applied cmor-fixer version attribute is set to: " + str(version))
        if write:
            setattr(ds, "history", history + 'The cmor-fixer version %s script has been applied.' % (version))
            setattr(ds, "latest_applied_cmor_fixer_version", version)
    #    if modified:
    #        creation_date = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    #        log.info("Setting creation_dr(ate to %s for %s" % (creation_date, ds.filepath()))
    #        if write:
    #            setattr(ds, "creation_date", creation_date)
    ds.close()
    return modified


def process_file(path, flog=None, write=True, keepid=False, forceid=False, metadata=None, add_attributes=False):
    try:
        modified = fix_file(path, write, keepid, forceid, metadata, add_attributes)
        if modified:
            if type(flog) == type(multiprocessing.Queue()):
                flog.put(path)
            elif hasattr(flog, "write"):
                flog.write(path + '\n')
    except IOError as io_err:
        log.error("An IO error for file %s occurred: %s" % (path, io_err.message))
    except AttributeError as att_err:
        log.error("An attribute error for file %s occurred: %s" % (path, att_err.message))


def listener(q, fname):
    with open(fname, 'w') as flog:
        while 1:
            elem = q.get()
            if elem == "kill":
                break
            flog.write(str(elem) + '\n')
            flog.flush()


def main(args=None):
    if args is None:
        pass
    formatter = lambda prog: argparse.HelpFormatter(prog,max_help_position=30)
    parser = argparse.ArgumentParser(description="Fix longitude coordinate (and opt. attributes) in cmorized files", formatter_class=formatter)
    parser.add_argument("datadir", metavar="DIR", type=str, help="Directory containing cmorized files")
    parser.add_argument("--depth", "-d", type=int, help="Directory recursion depth (default: infinite)")
    parser.add_argument("--verbose", "-v", action="store_true", default=False,
                        help="Run verbosely (default: off)")
    parser.add_argument("--dry", "-s", action="store_true", default=False,
                        help="Dry run, no writing (default: no)")
    parser.add_argument("--keepid", "-k", action="store_true", default=False,
                        help="Keep tracking id (default: no)")
    parser.add_argument("--forceid", "-f", action="store_true", default=False,
                        help="Force new tracking id (default: no)")
    parser.add_argument("--meta", metavar="FILE.json", type=str,
                        help="Input file to overwrite metadata (default: None). WARNING: This will be applied to "
                             "**ALL** netcdf files found recursively in your data directory. New attributes in this "
                             "file will be skipped unless the --addatts option is used.")
    parser.add_argument("--olist", "-o", action="store_true", default=False,
                        help="Write list-of-modified-files.txt listing all modified files")
    parser.add_argument("--addattrs", "-a", action="store_true", default=False,
                        help="Add new attributes from metadata file")
    parser.add_argument("--npp", type=int, default=1, help="Number of sub-processes to launch (default 1)")

    args = parser.parse_args()
    logformat = "%(asctime)s %(levelname)s:%(name)s: %(message)s"
    logdateformat = "%Y-%m-%d %H:%M:%S"
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG, format=logformat, datefmt=logdateformat)
    else:
        logging.basicConfig(level=logging.WARNING, format=logformat, datefmt=logdateformat)
    if args.keepid and args.forceid:
        log.error("Options keepid and forceid are mutually exclusive, please choose either one.")
        return
    odir = args.datadir
    depth = getattr(args, "depth", None)
    metajson = getattr(args, "meta", None)
    metadata = None
    if metajson is not None:
        with open(metajson) as jsonfile:
            metadata = json.load(jsonfile)
    if not os.path.isdir(odir):
        log.error("Data directory argument %s is not a valid directory: skipping fix" % odir)
        return
    if args.npp < 1:
        log.error("Invalid number of subprocesses chosen, please pick a number > 0")
        return
    ofilename = "list-of-modified-files.txt"
    if args.olist and os.path.isfile(ofilename):
        i = 1
        while os.path.isfile(ofilename):
            i += 1
            newfilename = "list-of-modified-files-" + str(i) + ".txt"
            log.warning("Output file name %s already exists, trying %s..." % (ofilename, newfilename))
            ofilename = newfilename
    if args.npp == 1:
        ofile = open(ofilename, 'w') if args.olist else None
        worker = partial(process_file, flog=ofile, write=not args.dry, keepid=args.keepid, forceid=args.forceid,
                         metadata=metadata, add_attributes=args.addattrs)
        for root, dirs, files in os.walk(odir, followlinks=False):
            if depth is None or root[len(odir):].count(os.sep) < int(depth):
                for filepath in files:
                    fullpath = os.path.join(root, filepath)
                    if not os.path.islink(fullpath) and filepath.endswith(".nc"):
                        worker(fullpath)
    else:
        considered_files = []
        for root, dirs, files in os.walk(odir, followlinks=False):
            if depth is None or root[len(odir):].count(os.sep) < int(depth):
                for filepath in files:
                    fullpath = os.path.join(root, filepath)
                    if not os.path.islink(fullpath) and filepath.endswith(".nc"):
                        considered_files.append(fullpath)
        manager = multiprocessing.Manager()
        fq = manager.Queue()
        pool = multiprocessing.Pool(processes=args.npp)
        watcher = pool.apply_async(listener, (fq, ofilename))
        jobs = []
        for f in considered_files:
            job = pool.apply_async(process_file, (f, fq, not args.dry, args.keepid, args.forceid, metadata,
                                                  args.addattrs))
            jobs.append(job)
        for job in jobs:
            job.get()
        # now we are done, kill the listener
        fq.put("kill")
        pool.close()
        pool.join()


if __name__ == "__main__":
    main()
