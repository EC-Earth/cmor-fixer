#!/usr/bin/env bash

# ./developer-scripts/produce-and-compare-vertices-files.sh

# Checksums can be checked without an .sha1 file directly by:
#  cd ../data-vertices/data-vertices-from-smhi
#  echo 'b29771500d8ce051eb521e8dc28bdff8f9f5a609  t621_1m_20150101_20151231_opa_grid_T_2D.nc'| sha1sum -c -
#  echo '52abc7c7a5a1006285a8531ad93db8c7e9e62cb1  t621_1m_20150101_20151231_opa_grid_U_3D.nc'| sha1sum -c -
#  echo '684f72c0ee17ab91ce6f7e8101f6c8754cc9e520  t621_1m_20150101_20151231_opa_grid_V_3D.nc'| sha1sum -c -
#  echo '77a491804dff0cc9173865b0afd2a6d6af79ef8f  t621_1m_20150101_20151231_opa_grid_W_3D.nc'| sha1sum -c -
#  echo 'c1d46080685f092364797ef691317db2ebf3eb7d  HC02_1m_20090101_20091231_grid_T.nc'| sha1sum -c -
#  echo '0a38144405a7b6ef54f17fa5ebcb26a3895b72d2  HC02_1m_20090101_20091231_grid_U.nc'| sha1sum -c -
#  echo '70fbf287d5f2c2d9f6d629865add7fcc341349b9  HC02_1m_20090101_20091231_grid_V.nc'| sha1sum -c -
# #echo 'b02ace8a8aaee93e29da08647ebfe7a99afbda59  HC02_1m_20090101_20091231_grid_W.nc'| sha1sum -c -
#
# Or with the .sha1 file by:
#  sha1sum -c this-dir.sha1

if [ "$#" -eq 1 ]; then

    orca_grid=$1

    if [ "${orca_grid}" = "ORCA1" ] || [ "${orca_grid}" = "ORCA025" ]; then
        echo ' Producing the' ${orca_grid} 'files.'
    else
        echo -e "\e[1;31m Error:\e[0m"' The ' ${orca_grid} 'is not available, use:'
        echo '  ' $0 'ORCA1'
        echo '  ' $0 'ORCA025'
        exit 1
    fi

    rm -rf ../nemo-vertices/compare-vertices-${orca_grid}
    mkdir -p ../nemo-vertices/compare-vertices-${orca_grid}
    cd ../nemo-vertices/compare-vertices-${orca_grid}

    if [ "${orca_grid}" = "ORCA1" ]; then
      nemo_raw_output_t_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/t621_1m_20150101_20151231_opa_grid_T_2D.nc
      nemo_raw_output_u_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/t621_1m_20150101_20151231_opa_grid_U_3D.nc
      nemo_raw_output_v_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/t621_1m_20150101_20151231_opa_grid_V_3D.nc
     #nemo_raw_output_w_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/t621_1m_20150101_20151231_opa_grid_W_3D.nc

      incorrect_cmorised_t_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-original/Omon/hfds/gn/v20200506/hfds_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
      incorrect_cmorised_u_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-original/Omon/uo/gn/v20200506/uo_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
      incorrect_cmorised_v_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-original/Omon/vo/gn/v20200506/vo_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
     #incorrect_cmorised_w_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-original/Omon/wo/gn/v20200506/wo_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc

      corrected_cmorised_t_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-bup-1/Omon/hfds/gn/v20200506/hfds_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
      corrected_cmorised_u_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-bup-1/Omon/uo/gn/v20200506/uo_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
      corrected_cmorised_v_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t004-01-bup-1/Omon/vo/gn/v20200506/vo_Omon_EC-Earth3_piControl_r1i1p1f1_gn_199001-199012.nc
    fi

    if [ "${orca_grid}" = "ORCA025" ]; then
      nemo_raw_output_t_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/HC02_1m_20090101_20091231_grid_T.nc
      nemo_raw_output_u_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/HC02_1m_20090101_20091231_grid_U.nc
      nemo_raw_output_v_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/HC02_1m_20090101_20091231_grid_V.nc
     #nemo_raw_output_w_grid_file=${HOME}/cmorize/cmor-fixer/data-vertices/data-vertices-from-smhi/HC02_1m_20090101_20091231_grid_W.nc

      incorrect_cmorised_t_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-original/Omon/hfds/gn/????/hfds_Omon_EC-Earth3_piControl_????_gn_????.nc
      incorrect_cmorised_u_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-original/Omon/uo/gn/????/uo_Omon_EC-Earth3_piControl_????_gn_????.nc
      incorrect_cmorised_v_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-original/Omon/vo/gn/????/vo_Omon_EC-Earth3_piControl_????_gn_????.nc
     #incorrect_cmorised_w_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-original/Omon/wo/gn/????/wo_Omon_EC-Earth3_piControl_????_gn_????.nc

      corrected_cmorised_t_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-bup-1/Omon/hfds/gn/????/hfds_Omon_EC-Earth3_piControl_????_gn_????.nc
      corrected_cmorised_u_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-bup-1/Omon/uo/gn/????/uo_Omon_EC-Earth3_piControl_????_gn_????.nc
      corrected_cmorised_v_grid_file=${HOME}/cmorize/cmor-fixer/cmor-cmip-test-all-t00?-bup-1/Omon/vo/gn/????/vo_Omon_EC-Earth3_piControl_????_gn_????.nc
    fi

    # t_grid as from NEMO directly:
    ncks -O -v tos               ${nemo_raw_output_t_grid_file} -o tos-${orca_grid}-t-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_t_grid_file} -o bounds-nav-lon-${orca_grid}-t-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_t_grid_file} -o bounds-nav-lat-${orca_grid}-t-grid-nemo.nc

    # u_grid as from NEMO directly:
    ncks -O -v uo                 ${nemo_raw_output_u_grid_file} -o uo-${orca_grid}-u-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_u_grid_file} -o bounds-nav-lon-${orca_grid}-u-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_u_grid_file} -o bounds-nav-lat-${orca_grid}-u-grid-nemo.nc

    # v_grid as from NEMO directly:
    ncks -O -v vo                 ${nemo_raw_output_v_grid_file} -o vo-${orca_grid}-v-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_v_grid_file} -o bounds-nav-lon-${orca_grid}-v-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_v_grid_file} -o bounds-nav-lat-${orca_grid}-v-grid-nemo.nc

    # w_grid as from NEMO directly:
   #ncks -O -v wmo                ${nemo_raw_output_w_grid_file} -o wmo-${orca_grid}-w-grid-nemo.nc
   #ncks -O -v bounds_nav_lon     ${nemo_raw_output_w_grid_file} -o bounds-nav-lon-${orca_grid}-w-grid-nemo.nc
   #ncks -O -v bounds_nav_lat     ${nemo_raw_output_w_grid_file} -o bounds-nav-lat-${orca_grid}-w-grid-nemo.nc


    # Create the vertices-only netcdf file for the t_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-${orca_grid}-t-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-${orca_grid}-t-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-${orca_grid}-t-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-${orca_grid}-t-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the u_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-${orca_grid}-u-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-${orca_grid}-u-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-${orca_grid}-u-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-${orca_grid}-u-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the v_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-${orca_grid}-v-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-${orca_grid}-v-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-${orca_grid}-v-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-${orca_grid}-v-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the w_grid as based on the NEMO file:
   #ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-${orca_grid}-w-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-${orca_grid}-w-grid.nc
   #ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-${orca_grid}-w-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-${orca_grid}-w-grid.nc ; rm -f output.nc;


    if [ "${orca_grid}" = "ORCA025" ]; then
      echo -e "\e[1;31m Error:\e[0m"' The ' ${orca_grid} 'option is under construction, so only a part of the' $0 'script is executed.'
      echo ' The produced files can be found in the directory: ../nemo-vertices/compare-vertices'-${orca_grid}
      exit 1
    fi

    # t_grid:
    ncks -O -v hfds               ${incorrect_cmorised_t_grid_file} -o hfds-${orca_grid}-t-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_t_grid_file} -o vertices-longitude-${orca_grid}-t-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_t_grid_file} -o vertices-latitude-${orca_grid}-t-grid-incorrect-cmorised.nc

    # u_grid:
    ncks -O -v uo                 ${incorrect_cmorised_u_grid_file} -o uo-${orca_grid}-u-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_u_grid_file} -o vertices-longitude-${orca_grid}-u-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_u_grid_file} -o vertices-latitude-${orca_grid}-u-grid-incorrect-cmorised.nc

    # v_grid:
    ncks -O -v vo                 ${incorrect_cmorised_v_grid_file} -o vo-${orca_grid}-v-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_v_grid_file} -o vertices-longitude-${orca_grid}-v-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_v_grid_file} -o vertices-latitude-${orca_grid}-v-grid-incorrect-cmorised.nc

    # w_grid:
   #ncks -O -v wo                 ${incorrect_cmorised_w_grid_file} -o wo-${orca_grid}-w-grid-incorrect-cmorised.nc
   #ncks -O -v vertices_longitude ${incorrect_cmorised_w_grid_file} -o vertices-longitude-${orca_grid}-w-grid-incorrect-cmorised.nc
   #ncks -O -v vertices_latitude  ${incorrect_cmorised_w_grid_file} -o vertices-latitude-${orca_grid}-w-grid-incorrect-cmorised.nc


    # Create the vertices-only netcdf files which are based on the corrected cmorised files:
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_t_grid_file} -o corrected-cmorised-vertices-${orca_grid}-t-grid.nc
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_u_grid_file} -o corrected-cmorised-vertices-${orca_grid}-u-grid.nc
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_v_grid_file} -o corrected-cmorised-vertices-${orca_grid}-v-grid.nc


   # Conclusion:
   #  the current cmorised t_grid & u_grid differ
   #  the current cmorised t_grid & v_grid differ
   #  the current cmorised u_grid & v_grid differ
   #  the current cmorised t_grid & w_grid are identical
   #  the nemo based       t_grid & u_grid differ
   #  the nemo based       t_grid & v_grid differ
   #  the nemo based       u_grid & v_grid differ
   #  the nemo based       t_grid & w_grid are identical


    # Create the (non-corrected) cmorised-vertices files:
    rsync -a vertices-longitude-${orca_grid}-t-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-t-grid.nc; ncks -A -v vertices_latitude vertices-latitude-${orca_grid}-t-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-t-grid.nc
    rsync -a vertices-longitude-${orca_grid}-u-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-u-grid.nc; ncks -A -v vertices_latitude vertices-latitude-${orca_grid}-u-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-u-grid.nc
    rsync -a vertices-longitude-${orca_grid}-v-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc; ncks -A -v vertices_latitude vertices-latitude-${orca_grid}-v-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc


   # Compare the various staggered grids for the (non-corrected) cmorised files:
    ncdiff -Oh incorrect-cmorised-vertices-${orca_grid}-t-grid.nc incorrect-cmorised-vertices-${orca_grid}-u-grid.nc diff-cmorised-vertices-${orca_grid}-t-u-grid.nc;
    ncdiff -Oh incorrect-cmorised-vertices-${orca_grid}-t-grid.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc diff-cmorised-vertices-${orca_grid}-t-v-grid.nc;
    ncdiff -Oh incorrect-cmorised-vertices-${orca_grid}-u-grid.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc diff-cmorised-vertices-${orca_grid}-u-v-grid.nc;

   # Compare the various staggered grids for the nemo files:
    ncdiff -Oh nemo-vertices-${orca_grid}-t-grid.nc nemo-vertices-${orca_grid}-u-grid.nc diff-nemo-vertices-${orca_grid}-t-u-grid.nc;
    ncdiff -Oh nemo-vertices-${orca_grid}-t-grid.nc nemo-vertices-${orca_grid}-v-grid.nc diff-nemo-vertices-${orca_grid}-t-v-grid.nc;
    ncdiff -Oh nemo-vertices-${orca_grid}-u-grid.nc nemo-vertices-${orca_grid}-v-grid.nc diff-nemo-vertices-${orca_grid}-u-v-grid.nc;

   # Compare the various staggered grids for the corrected cmorised files:
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-t-grid.nc corrected-cmorised-vertices-${orca_grid}-u-grid.nc diff-corrected-cmorised-vertices-${orca_grid}-t-u-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-t-grid.nc corrected-cmorised-vertices-${orca_grid}-v-grid.nc diff-corrected-cmorised-vertices-${orca_grid}-t-v-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-u-grid.nc corrected-cmorised-vertices-${orca_grid}-v-grid.nc diff-corrected-cmorised-vertices-${orca_grid}-u-v-grid.nc;


   # Compare corrected cmorised with (non-corrected) cmorised files:
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-t-grid.nc incorrect-cmorised-vertices-${orca_grid}-t-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-${orca_grid}-t-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-u-grid.nc incorrect-cmorised-vertices-${orca_grid}-u-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-${orca_grid}-u-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-${orca_grid}-v-grid.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-${orca_grid}-v-grid.nc;

   # Create three links for cmor-fixer tests:
   cd ../
   if [ ! -f incorrect-cmorised-vertices-${orca_grid}-t-grid.nc ]; then ln -s compare-vertices-${orca_grid}/incorrect-cmorised-vertices-${orca_grid}-t-grid.nc incorrect-cmorised-vertices-${orca_grid}-t-grid.nc; fi
   if [ ! -f incorrect-cmorised-vertices-${orca_grid}-u-grid.nc ]; then ln -s compare-vertices-${orca_grid}/incorrect-cmorised-vertices-${orca_grid}-u-grid.nc incorrect-cmorised-vertices-${orca_grid}-u-grid.nc; fi
   if [ ! -f incorrect-cmorised-vertices-${orca_grid}-v-grid.nc ]; then ln -s compare-vertices-${orca_grid}/incorrect-cmorised-vertices-${orca_grid}-v-grid.nc incorrect-cmorised-vertices-${orca_grid}-v-grid.nc; fi

   echo
   echo ' The script' $0 'has finished. The produced files can be found in the directory: ../nemo-vertices/compare-vertices'-${orca_grid}
   echo

else
    echo
    echo '  This script requires one argument, the ORCA resolution:'
    echo '  ' $0 'ORCA1'
    echo '  ' $0 'ORCA025'
    echo
fi


# For figuring out how to output the NEMO vertices in the NEMO raw output a search on "bounds_lon_2d" in:
#  ${HOME}/ec-earth-3/trunk/sources/xios-2.5/doc/XIOS_user_guide.pdf
#  ${HOME}/ec-earth-3/trunk/sources/xios-2.5/doc/XIOS_reference_guide.pdf
# Shows that the vertices are optional XIOS arguments:
#  cd ${HOME}/ec-earth-3/trunk/
#  gall 'CALL.xios_set_domain_attr'|grep bounds_lon_2d
# Gives:
#  sources/xios-2.5/src/test/test_new_features.f90:158:  CALL xios_set_domain_attr("domain_A",bounds_lon_2d=bnds_lon,bounds_lat_2d=bnds_lat, nvertex=4, type='curvilinear')
#
# Note that it seems that at SMHI they get the vertices in the raw NEMO output when they activate land removal (they do this by hand and not with ELPIN).


# Creating test data in order to test during development:
#  for i in {1..9}; do rsync -a cmor-cmip-test-all-t004-01-original/ cmor-cmip-test-all-t004-01-bup-$i; done

# Running the cmor-fixer in order to test during development:
#  activatecmorfixer
#  rm -f list-of-modified-files* ;./cmor-fixer.py --verbose --olist --npp 1 --dry cmor-cmip-test-all-t004-01-bup-1/
