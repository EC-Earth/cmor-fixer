#!/usr/bin/env bash
#
# This script runs without arguments.
#
# Fix EC-Earth3 errors in cmorised data like the longitude eastward shift.
# It is safe to run the script on correct or corrected data.
#
# This scripts requires no arguments.
#

#SBATCH --time=00:05:00
#SBATCH --job-name=cmorfixer
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --qos=nf
#SBATCH --output=stdout-cmorisation.%j.out
#SBATCH --error=stderr-cmorisation.%j.out
#SBATCH --account=nlchekli
#SBATCH --mail-type=FAIL

# CMORISEDDIR is the directory with the cmorised data
# METADATA    is the name of the meta data file, for instance: ece2cmor3/resources/metadata-templates/cmip6-CMIP-piControl-metadata-template.json


# Example running directly from the command line on the main node:
# ./cmor-fixer.py --verbose --dry --forceid --olist --npp 1 /lustre2/projects/model_testing/reerink/cmorised-results/cmor-cmip-test-all-11/t002/ifs/001/CMIP6/


 if [ "$#" -eq 0 ]; then

   CMORISEDDIR=/lustre2/projects/model_testing/reerink/cmorised-results/cmor-cmip-test-all-11/t002/ifs/001/CMIP6/
   METADATA=/nfs/home/users/reerink/ec-earth-3/trunk/runtime/classic/ctrl/cmip6-output-control-files/CMIP/EC-EARTH-AOGCM/cmip6-experiment-CMIP-piControl/metadata-cmip6-CMIP-piControl-EC-EARTH-AOGCM-ifs-template.json

   if [ -z "$CMORISEDDIR" ]; then echo "Error: Empty EC-Earth3 data output directory: " $CMORISEDDIR ", aborting" $0 >&2; exit 1; fi

   source ${PERM}/mamba/etc/profile.d/conda.sh
   conda activate cmorfixer

   export HDF5_USE_FILE_LOCKING=FALSE

   ./cmor-fixer.py --verbose               \
                   --forceid               \
                   --olist                 \
                   --npp         128       \
                   $CMORISEDDIR

#  ./cmor-fixer.py --verbose               \
#                  --dry                   \
#                  --keepid                \
#                  --meta        $METADATA \
#                  --olist                 \
#                  --npp         128       \
#                  $CMORISEDDIR

 else
  echo
  echo "  Illegal number of arguments: this script itself requires no arguments. Thus run:"
  echo "   sbatch  $0"
  echo
 fi
