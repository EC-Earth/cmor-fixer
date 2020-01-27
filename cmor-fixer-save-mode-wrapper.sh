#!/bin/bash
# Thomas Reerink
#
# This script is a wrapper of cmor-fixer. It only applies cmor-fixer changes when in the dataset at least one error is found.
# That means, if all files in the entire dataset are correct, then no tracking_id will be changed anywhere.
# See #731 and the wiki:
#  https://dev.ec-earth.org/issues/731
#  https://dev.ec-earth.org/projects/cmip6/wiki/Correct-cmorised-data-with-the-cmor-fixer for further background.
#
# This scripts needs two arguments:
#
# ${1} the first   argument is the number of cores (one node can be used).
# ${2} the second  argument is path of the directory with the cmorised data.
#
# Run example:
#  ./cmor-fixer-save-mode-wrapper.sh 1 CMIP6
#

if [ "$#" -eq 2 ]; then

   number_of_cores=$1
   dir_with_cmorised_data=$2

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

   case "${number_of_cores}" in
       ("" | *[!0-9]*)
           echo -e "\e[1;31m Error:\e[0m"' Invalid value for the number of cores: ' ${number_of_cores} '. It should be [0-9][0-9]' >&2
           exit 1
   esac

   if [ "${number_of_cores}" -lt 1 ] || [ "$1" -gt 100 ]; then
       echo -e "\e[1;31m Error:\e[0m"' The value of number of cores ' ${number_of_cores} ' is out of range. Allowed range: 1-100.' >&2
       exit 1
   fi

   if [ ! -d ${dir_with_cmorised_data} ]; then
    echo
    echo -e "\e[1;31m Error:\e[0m"' the directory ' ${dir_with_cmorised_data} ' does not exist.'
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
   ./cmor-fixer.py --dry --verbose --olist --npp ${number_of_cores} ${dir_with_cmorised_data} &> cmor-fixer-messages-1.log

   # For testing the script with non-empty case:
  #echo ' Make non-empty for test only.' >> ${olist_filename}
  #more bup-list-of-modified-files-3.txt > ${olist_filename}
   
  #sleep 1
   if [[ ! -e ${olist_filename} ]] ; then
    echo
    echo -e "\e[1;31m Error:\e[0m"' the file ' ${olist_filename} ' should have been produced.'
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
   ./cmor-fixer.py --dry --verbose --forceid --olist --npp ${number_of_cores} ${dir_with_cmorised_data} &> cmor-fixer-messages-2.log

   if [[ ! -e ${olist_2_filename} ]] ; then
    echo
    echo -e "\e[1;31m Error:\e[0m"' the file ' ${olist_2_filename} ' should have been produced.'
    echo
    exit 1
   fi

   # Apply the changes the olist for the --forceid case:
   ./cmor-fixer.py --verbose --forceid --olist --npp ${number_of_cores} ${dir_with_cmorised_data} &> cmor-fixer-messages-3.log


   diff ${olist_2_filename} ${olist_filename} >> ${diff_olists}

   if [[ ! -s ${diff_olists} ]]; then
    echo
    echo ' The changes are applied and agree with the preceding dry-run, so all seems fine.'
    echo
    rm -f ${diff_olists}
   else
    echo
    echo -e "\e[1;33m Warning:\e[0m"' the ' ${diff_olists} ' file is not empty. So it seems that the dry-run before and the modification run thereafter differ.\e[1;33m Check for any interruption.\e[0m'
    echo
   fi


   # Final check: Check whether after modifying the errors, the dataser is now error free:
   ./cmor-fixer.py --dry --verbose --olist --npp ${number_of_cores} ${dir_with_cmorised_data} &> cmor-fixer-messages-4.log

   if [[ ! -e ${olist_4_filename} ]] ; then
    echo
    echo -e "\e[1;31m Error:\e[0m"' the file ' ${olist_4_filename} ' should have been produced (in the post checking phase).'
    echo
    exit 1
   fi

   if [[ ! -s ${olist_4_filename} ]]; then
    echo
    echo ' All files in the entire dataset are correct after correcting, so ending successful!'
    echo
   else
    echo
    echo -e "\e[1;33m Warning:\e[0m"' After correcting with cmor-fixer, it seems there are still errors in the dataset. Check the files by looking into ' ${olist_4_filename}
    echo
   fi

   # Run the script ./versions.sh for instance to set all version directory names to January 20 2020:
   echo
   echo ' The versions.sh script detects the following versions in the final corrected dataset:'
   ./versions.sh -l ${dir_with_cmorised_data}
  #echo ' In order to set one new version (recommended), for instance to February 20 2020, the versions.sh script can be run now by:'
  #echo ' ./versions.sh -v v20200220 -m CMIP6/'
   echo


else
    echo
    echo '  This scripts requires two arguments:'
    echo '   The first  argument: is the number of cores (one node can be used).'
    echo '   The second argument: is the path of the directory which contains the cmorised data.'
    echo '  For instance:'
    echo '  ' $0 1 CMIP6/
    echo
fi
