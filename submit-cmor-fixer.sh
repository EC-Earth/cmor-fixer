#!/bin/bash
#
# Run this script by:
#  sbatch submit-cmor-fixer.sh
#
# Fix the longitude eastward shift in the EC-Earth3 cmorisation.
#
# This scripts requires no arguments.
#
#SBATCH --job-name=cmor-fixer
#SBATCH --partition=all
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=28
#SBATCH --account=proj-cmip6

# Two account options:  proj-cmip6  &  model-testing

# CMORISEDDIR is the directory with the cmorised data
# METADATA    is the name of the meta data file, for instance: ece2cmor3/resources/metadata-templates/cmip6-CMIP-piControl-metadata-template.json


# Example running directly from the command line on the main node:
# ./cmor-fixer.py --verbose --dry --forceid --olist --npp 1 /lustre2/projects/model_testing/reerink/cmorised-results/cmor-cmip-test-all-11/t002/ifs/001/CMIP6/


 if [ "$#" -eq 0 ]; then

   CMORISEDDIR=/lustre2/projects/model_testing/reerink/cmorised-results/cmor-cmip-test-all-11/t002/ifs/001/CMIP6/
   METADATA=/nfs/home/users/reerink/ec-earth-3/branch-r7438-control-output-files/runtime/classic/ctrl/cmip6-output-control-files/CMIP/EC-EARTH-AOGCM/cmip6-experiment-CMIP-piControl/metadata-cmip6-CMIP-piControl-EC-EARTH-AOGCM-$COMPONENT-template.json

   if [ -z "$CMORISEDDIR" ]; then echo "Error: Empty EC-Earth3 data output directory: " $CMORISEDDIR ", aborting" $0 >&2; exit 1; fi

   source /lustre2/projects/model_testing/reerink/miniconda3/etc/profile.d/conda.sh
   conda activate cmorfixer

   export HDF5_USE_FILE_LOCKING=FALSE

   ./cmor-fixer.py --verbose               \
                   --dry                   \
                   --forceid               \
                   --olist                 \
                   --npp         28        \
                   $CMORISEDDIR

                  #--keepid                \
                  #--meta        $METADATA \

 else
  echo
  echo '  Illegal number of arguments: the script requires no arguments, for instance:'
  echo '   sbatch ' $0
  echo
 fi
