#!/bin/bash
# Thomas Reerink
#
# This script is a wrapper of cmor-fixer. It only applies cmor-fixer changes when in the dataset at least one error is found. 
# That means if all files in the entire dataset are correct, that never a tracking_id will be changed.
# See #731 and the wiki https://dev.ec-earth.org/projects/cmip6/wiki/Correct-cmorised-data-with-the-cmor-fixer for further background.
#
# This scripts requires one argument: The path of the directory with the cmorised data
#
# Run example:
#  ./cmor-fixer-save-mode-wrapper.sh
#

if [ "$#" -eq 1 ]; then

   dir_with_cmorised_data=$1
   number_of_cores=1
  #number_of_cores=$2

   olist_filename='list-of-modified-files.txt'
   olist_2_filename='list-of-modified-files-2.txt'
   olist_3_filename='list-of-modified-files-3.txt'
   olist_4_filename='list-of-modified-files-4.txt'
   diff_olists='diff-list-of-modified-files.txt'

   if [[ -e ${olist_filename} || -e ${olist_2_filename} || -e ${olist_3_filename} || -e ${olist_4_filename} || -e ${diff_olists} ]] ; then
    echo
    echo ' Aborting' $0 ' because you have to rename any of the files with the names:'
    echo ' ' ${olist_filename}
    echo ' ' ${olist_2_filename}
    echo ' ' ${olist_3_filename}
    echo ' ' ${olist_4_filename}
    echo ' ' ${diff_olists}
    echo
    exit 1
   fi


#  # First move list-of-modified-files.txt if they exists already:
#  olist_filename='list-of-modified-files'
#  if [[ -e ${olist_filename}.txt ]] ; then
#      i=1
#      while [[ -e ${olist_filename}-backup-$i.txt ]] ; do
#          let i++
#      done
#      olist_filename=${olist_filename}-backup-$i.txt
#  fi


   # First run cmor-fixer in the save dry-run mode in order to figure out if there is any file with an error at all:
   ./cmor-fixer.py --dry --verbose --olist --npp ${number_of_cores} ${dir_with_cmorised_data}

   # For testing the script with non-empty case:
  #echo ' Make non-empty for test only.' >> ${olist_filename}
  #more bup-list-of-modified-files-3.txt > ${olist_filename}
   
  #sleep 1
   if [[ ! -e ${olist_filename} ]] ; then
    echo
    echo ' Error: the file ' ${olist_filename} ' should have been produced.'
    echo
    exit 1
   fi

   if [[ ! -s ${olist_filename} ]]; then
    echo
    echo ' All files in the entire dataset are correct, so ' $0 ' will not apply any changes.'
    echo
    exit 1
   fi

   # Create, before really applying the changes, the olist for the --forceid case:
   ./cmor-fixer.py --dry --verbose --forceid --olist --npp ${number_of_cores} ${dir_with_cmorised_data}

   if [[ ! -e ${olist_2_filename} ]] ; then
    echo
    echo ' Error: the file ' ${olist_2_filename} ' should have been produced.'
    echo
    exit 1
   fi

   # Apply the changes the olist for the --forceid case:
   ./cmor-fixer.py --verbose --forceid --olist --npp ${number_of_cores} ${dir_with_cmorised_data}


   diff ${olist_2_filename} ${olist_filename} >> ${diff_olists}

   if [[ ! -s ${diff_olists} ]]; then
    echo
    echo ' The changes are applied and agree with the preceding dry-run, so all seems fine.'
    echo
    rm -f ${diff_olists}
   else
    echo
    echo ' Warning: the ' ${diff_olists} ' file is not empty. So it seems that the dry-run before and the modification run thereafter differ. Check for any interruption.'
    echo
   fi


   # Final check: Check whether after modifying the errors, the dataser is now error free:
   ./cmor-fixer.py --dry --verbose --olist --npp ${number_of_cores} ${dir_with_cmorised_data}

   if [[ ! -e ${olist_4_filename} ]] ; then
    echo
    echo ' Error: the file ' ${olist_4_filename} ' should have been produced.'
    echo
    exit 1
   fi

   if [[ ! -s ${olist_4_filename} ]]; then
    echo
    echo ' All files in the entire dataset are correct after correcting, so ending successful!'
    echo
   else
    echo
    echo ' Warning: After correcting with cmor-fixer, it seems there are still errors in the dataset. Check the files by looking into ' ${olist_4_filename}
    echo
   fi



   # Run the script ./versions.sh for instance to set all version directory names to January 20 2020:
    echo ' The versions in this dataset are:'
   ./versions.sh -l ${dir_with_cmorised_data}


else
    echo '  '
    echo '  This scripts requires one argument, e.g.:'
    echo '  ' $0 CMIP6/
    echo '  '
fi
