#!/usr/bin/env python

import argparse
import os
import json
import netCDF4
import logging
import uuid
#import datetime

log = logging.getLogger(os.path.basename(__file__))


def fix_file(path, write=True, keepid=False, forceid=False, metadata=None):
    ds = netCDF4.Dataset(path, "r+" if write else "r")
    modified = forceid
    # TODO: Figure out whether this filters only IFS data:
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
                        modified = True
                    shifted_vars.add(bndvarname)
    if metadata is not None:
        for key, val in metadata:
            if getattr(ds, key, None) != val:
                log.info("Setting metadata field %s to %s in %s" % (key, val, ds.filepath()))
                if write:
                    setattr(ds, key, val)
                    modified = True
    if modified and not keepid:
        tr_id = '/'.join(["hdl:21.14100", (str(uuid.uuid4()))])
        log.info("Setting tracking_id to %s for %s" % (tr_id, ds.filepath()))
        if write:
            setattr(ds, "tracking_id", tr_id)
#    if modified:
#        creation_date = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
#        log.info("Setting creation_dr(ate to %s for %s" % (creation_date, ds.filepath()))
#        if write:
#            setattr(ds, "creation_date", creation_date)
    ds.close()
    return modified


def main(args=None):
    if args is None:
        pass
    parser = argparse.ArgumentParser(description="Fix longitude coordinate (and opt. attributes) in cmorized files")
    parser.add_argument("datadir", metavar="DIR", type=str)
    parser.add_argument("--depth", "-d", type=int, help="Directory recursion depth (default: infinite)")
    parser.add_argument("--verbose", "-v", action="store_true", default=False,
                        help="Run verbosely (default: off)")
    parser.add_argument("--dry", "-s", action="store_true", default=False,
                        help="Dry run, no writing (default: no)")
    parser.add_argument("--keepid", "-k", action="store_true", default=False,
                        help="Keep tracking id and creation date (default: no)")
    parser.add_argument("--forceid", "-f", action="store_true", default=False,
                        help="Force new tracking id and creation date (default: no)")
    parser.add_argument("--meta", metavar="FILE.json", type=str,
                        help="Input file to overwrite metadata (default: None)")
    parser.add_argument("--olist", "-o", action="store_true", default=False,
                        help="Write modified_files.txt listing all modified files")

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
    if os.path.exists(odir):
        modified_files = []
        for root, dirs, files in os.walk(odir):
            if depth is None or root[len(odir):].count(os.sep) < int(depth):
                for filepath in files:
                    if filepath.endswith(".nc"):
                        modified = fix_file(os.path.join(root, filepath), not args.dry, args.keepid,
                                            args.forceid, metadata)
                        if modified:
                            modified_files.append(os.path.join(root, filepath))
        if args.olist:
            with open("modified_files.txt", 'w') as ofile:
                for f in modified_files:
                    ofile.write(f + '\n')


if __name__ == "__main__":
    main()
