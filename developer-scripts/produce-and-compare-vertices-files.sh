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

if [ "$#" -eq 0 ]; then

    rm -rf ../nemo-vertices/compare-vertices
    mkdir -p ../nemo-vertices/compare-vertices
    cd ../nemo-vertices/compare-vertices

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


    # t_grid as from NEMO directly:
    ncks -O -v hfds               ${nemo_raw_output_t_grid_file} -o hfds-ORCA1-t-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_t_grid_file} -o bounds-nav-lon-ORCA1-t-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_t_grid_file} -o bounds-nav-lat-ORCA1-t-grid-nemo.nc

    # u_grid as from NEMO directly:
    ncks -O -v uo                 ${nemo_raw_output_u_grid_file} -o uo-ORCA1-u-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_u_grid_file} -o bounds-nav-lon-ORCA1-u-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_u_grid_file} -o bounds-nav-lat-ORCA1-u-grid-nemo.nc

    # v_grid as from NEMO directly:
    ncks -O -v vo                 ${nemo_raw_output_v_grid_file} -o vo-ORCA1-v-grid-nemo.nc
    ncks -O -v bounds_nav_lon     ${nemo_raw_output_v_grid_file} -o bounds-nav-lon-ORCA1-v-grid-nemo.nc
    ncks -O -v bounds_nav_lat     ${nemo_raw_output_v_grid_file} -o bounds-nav-lat-ORCA1-v-grid-nemo.nc

    # w_grid as from NEMO directly:
   #ncks -O -v wmo                ${nemo_raw_output_w_grid_file} -o wmo-ORCA1-w-grid-nemo.nc
   #ncks -O -v bounds_nav_lon     ${nemo_raw_output_w_grid_file} -o bounds-nav-lon-ORCA1-w-grid-nemo.nc
   #ncks -O -v bounds_nav_lat     ${nemo_raw_output_w_grid_file} -o bounds-nav-lat-ORCA1-w-grid-nemo.nc


    # Create the vertices-only netcdf file for the t_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-ORCA1-t-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-ORCA1-t-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-ORCA1-t-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-ORCA1-t-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the u_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-ORCA1-u-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-ORCA1-u-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-ORCA1-u-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-ORCA1-u-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the v_grid as based on the NEMO file:
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-ORCA1-v-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-ORCA1-v-grid.nc
    ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-ORCA1-v-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc ; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-ORCA1-v-grid.nc ; rm -f output.nc;

    # Create the vertices-only netcdf file for the w_grid as based on the NEMO file:
   #ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lon-ORCA1-w-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lon,vertices_longitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; mv -f output.nc nemo-vertices-ORCA1-w-grid.nc
   #ncatted -Oh -a name,global,d,, -a description,global,d,, -a title,global,d,, -a Conventions,global,d,, -a timeStamp,global,d,, -a uuid,global,d,, -a NCO,global,d,, -a history,global,d,, bounds-nav-lat-ORCA1-w-grid-nemo.nc -o output.nc; ncrename -Oh -v bounds_nav_lat,vertices_latitude output.nc; ncrename -Oh -d x,i output.nc; ncrename -Oh -d y,j output.nc; ncrename -Oh -d nvertex,vertices output.nc; ncks -Ah -v vertices_latitude output.nc nemo-vertices-ORCA1-w-grid.nc ; rm -f output.nc;


    # t_grid:
    ncks -O -v hfds               ${incorrect_cmorised_t_grid_file} -o hfds-ORCA1-t-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_t_grid_file} -o vertices-longitude-ORCA1-t-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_t_grid_file} -o vertices-latitude-ORCA1-t-grid-incorrect-cmorised.nc

    # u_grid:
    ncks -O -v uo                 ${incorrect_cmorised_u_grid_file} -o uo-ORCA1-u-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_u_grid_file} -o vertices-longitude-ORCA1-u-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_u_grid_file} -o vertices-latitude-ORCA1-u-grid-incorrect-cmorised.nc

    # v_grid:
    ncks -O -v vo                 ${incorrect_cmorised_v_grid_file} -o vo-ORCA1-v-grid-incorrect-cmorised.nc
    ncks -O -v vertices_longitude ${incorrect_cmorised_v_grid_file} -o vertices-longitude-ORCA1-v-grid-incorrect-cmorised.nc
    ncks -O -v vertices_latitude  ${incorrect_cmorised_v_grid_file} -o vertices-latitude-ORCA1-v-grid-incorrect-cmorised.nc

    # w_grid:
   #ncks -O -v wo                 ${incorrect_cmorised_w_grid_file} -o wo-ORCA1-w-grid-incorrect-cmorised.nc
   #ncks -O -v vertices_longitude ${incorrect_cmorised_w_grid_file} -o vertices-longitude-ORCA1-w-grid-incorrect-cmorised.nc
   #ncks -O -v vertices_latitude  ${incorrect_cmorised_w_grid_file} -o vertices-latitude-ORCA1-w-grid-incorrect-cmorised.nc


    # Create the vertices-only netcdf files which are based on the corrected cmorised files:
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_t_grid_file} -o corrected-cmorised-vertices-ORCA1-t-grid.nc
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_u_grid_file} -o corrected-cmorised-vertices-ORCA1-u-grid.nc
    ncks -O -v vertices_longitude,vertices_latitude ${corrected_cmorised_v_grid_file} -o corrected-cmorised-vertices-ORCA1-v-grid.nc


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
    rsync -a vertices-longitude-ORCA1-t-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-t-grid.nc; ncks -A -v vertices_latitude vertices-latitude-ORCA1-t-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-t-grid.nc
    rsync -a vertices-longitude-ORCA1-u-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-u-grid.nc; ncks -A -v vertices_latitude vertices-latitude-ORCA1-u-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-u-grid.nc
    rsync -a vertices-longitude-ORCA1-v-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc; ncks -A -v vertices_latitude vertices-latitude-ORCA1-v-grid-incorrect-cmorised.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc


   # Compare the various staggered grids for the (non-corrected) cmorised files:
    ncdiff -Oh incorrect-cmorised-vertices-ORCA1-t-grid.nc incorrect-cmorised-vertices-ORCA1-u-grid.nc diff-cmorised-vertices-ORCA1-t-u-grid.nc;
    ncdiff -Oh incorrect-cmorised-vertices-ORCA1-t-grid.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc diff-cmorised-vertices-ORCA1-t-v-grid.nc;
    ncdiff -Oh incorrect-cmorised-vertices-ORCA1-u-grid.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc diff-cmorised-vertices-ORCA1-u-v-grid.nc;
   #ncview diff-cmorised-vertices-ORCA1-t-u-grid.nc
   #ncview diff-cmorised-vertices-ORCA1-t-v-grid.nc
   #ncview diff-cmorised-vertices-ORCA1-u-v-grid.nc

   # Compare the various staggered grids for the nemo files:
    ncdiff -Oh nemo-vertices-ORCA1-t-grid.nc nemo-vertices-ORCA1-u-grid.nc diff-nemo-vertices-ORCA1-t-u-grid.nc;
    ncdiff -Oh nemo-vertices-ORCA1-t-grid.nc nemo-vertices-ORCA1-v-grid.nc diff-nemo-vertices-ORCA1-t-v-grid.nc;
    ncdiff -Oh nemo-vertices-ORCA1-u-grid.nc nemo-vertices-ORCA1-v-grid.nc diff-nemo-vertices-ORCA1-u-v-grid.nc;
   #ncview diff-nemo-vertices-ORCA1-t-u-grid.nc
   #ncview diff-nemo-vertices-ORCA1-t-v-grid.nc
   #ncview diff-nemo-vertices-ORCA1-u-v-grid.nc

   # Compare the various staggered grids for the corrected cmorised files:
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-t-grid.nc corrected-cmorised-vertices-ORCA1-u-grid.nc diff-corrected-cmorised-vertices-ORCA1-t-u-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-t-grid.nc corrected-cmorised-vertices-ORCA1-v-grid.nc diff-corrected-cmorised-vertices-ORCA1-t-v-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-u-grid.nc corrected-cmorised-vertices-ORCA1-v-grid.nc diff-corrected-cmorised-vertices-ORCA1-u-v-grid.nc;


   # Compare corrected cmorised with (non-corrected) cmorised files:
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-t-grid.nc incorrect-cmorised-vertices-ORCA1-t-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-t-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-u-grid.nc incorrect-cmorised-vertices-ORCA1-u-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-u-grid.nc;
    ncdiff -Oh corrected-cmorised-vertices-ORCA1-v-grid.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-v-grid.nc;

   #ncview diff-corrected-cmorised-vertices-ORCA1-t-u-grid.nc; ncview diff-corrected-cmorised-vertices-ORCA1-t-v-grid.nc; ncview diff-corrected-cmorised-vertices-ORCA1-u-v-grid.nc;
   #ncview diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-t-grid.nc; ncview diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-u-grid.nc; ncview diff-corrected-cmorised-incorrect-cmorised-vertices-ORCA1-v-grid.nc;

   # Create three links for cmor-fixer tests:
   cd ../
   if [ ! -f incorrect-cmorised-vertices-ORCA1-t-grid.nc ]; then ln -s compare-vertices/incorrect-cmorised-vertices-ORCA1-t-grid.nc incorrect-cmorised-vertices-ORCA1-t-grid.nc; fi
   if [ ! -f incorrect-cmorised-vertices-ORCA1-u-grid.nc ]; then ln -s compare-vertices/incorrect-cmorised-vertices-ORCA1-u-grid.nc incorrect-cmorised-vertices-ORCA1-u-grid.nc; fi
   if [ ! -f incorrect-cmorised-vertices-ORCA1-v-grid.nc ]; then ln -s compare-vertices/incorrect-cmorised-vertices-ORCA1-v-grid.nc incorrect-cmorised-vertices-ORCA1-v-grid.nc; fi

   echo
   echo ' The script' $0 'has finished. The produced files can be found in the directory: ../nemo-vertices/compare-vertices'
   echo

else
    echo
    echo '  This script requires no arguments, call example:'
    echo '  ' $0 
    echo
fi

#  vertices-longitude-ORCA1-t-grid-incorrect-cmorised.nc|grep -v -e history|grep -A 2 vertices_longitude
#  vertices-longitude-ORCA1-u-grid-incorrect-cmorised.nc|grep -v -e history|grep -A 2 vertices_longitude
#  vertices-longitude-ORCA1-v-grid-incorrect-cmorised.nc|grep -v -e history|grep -A 2 vertices_longitude

# # t_grid:
# vertices_longitude =
#  72, 73, 73, 72,
#  73, 74, 74, 73,
# # u_grid:
# vertices_longitude =
#  72.5, 73.5, 73.5, 72.5,
#  73.5, 74.5, 74.5, 73.5,
# # v_grid:
# vertices_longitude =
#  72, 73, 73, 72,
#  73, 74, 74, 73,


# From:
# cd ${HOME}/ec-earth-3/trunk/runtime/classic/ctrl
# gall lon|grep -v -e 'alone' -e ping -e long_name -e 'native regular 2x3 degree latxlon' -e "volc-long-eq"

# Identical:
# diff trunk/runtime/classic/ctrl/namelist.nemo-ORCA1L75-coupled.cfg.sh trunk-r6679/runtime/classic/ctrl/namelist.nemo-ORCA1L75-coupled.cfg.sh
# diff trunk/runtime/classic/ctrl/namelist.nemo-ORCA025L75-coupled.cfg.sh trunk-r6679/runtime/classic/ctrl/namelist.nemo-ORCA025L75-coupled.cfg.sh
# diff trunk/runtime/classic/ctrl/namelist.nemo.top.cfg.sh trunk-r6679/runtime/classic/ctrl/namelist.nemo.top.cfg.sh

# Not in trunk-r6679:
#  trunk/runtime/classic/ctrl/namelist.nemo-ORCA1L75-carboncycle.cfg.sh
#  trunk/runtime/classic/ctrl/namelist.osm.sh

# Not identical, but seems irrelevant:
# diff trunk/runtime/classic/ctrl/namelist.nemo.ref.sh trunk-r6679/runtime/classic/ctrl/namelist.nemo.ref.sh
# <    ln_dyn_trd  = .false.    ! (T) 3D momentum trend output
# ---
# >    ln_dyn_trd  = .TRUE.    ! (T) 3D momentum trend output
# <    ln_tra_trd  = .false.    ! (T) 3D tracer trend output
# ---
# >    ln_tra_trd  = .TRUE.    ! (T) 3D tracer trend output

# diff trunk/runtime/classic/ctrl/namelist.nemo.top.ref.sh trunk-r6679/runtime/classic/ctrl/namelist.nemo.top.ref.sh 
# <     trc_rst_ctl=1
# < elif has_config pisces:start_from_restart
# < then
# <     trc_restart=".TRUE."
# <     trc_rst_ctl=0
# <     trc_rst_ctl=0
# <    nn_rsttr      = $trc_rst_ctl !  restart control = 0 initial time step is not compared to the restart file value
# ---
# >    nn_rsttr      =   0       !  restart control = 0 initial time step is not compared to the restart file value



# I have also added the file_def and field_def files that have been used in that experiment. 
# These files are directly taken from the trunk (r6679), no modifications.
# I used the trunk because I wanted start the experiments quickly and didn't want wait for the tagged version.

# Is there any other XIOS control file (namelist?) that could be different?

# op ${HOME}/ec-earth-3/trunk/sources/xios-2.5/doc/XIOS_user_guide.pdf
# op ${HOME}/ec-earth-3/trunk/sources/xios-2.5/doc/XIOS_reference_guide.pdf

# cd ${HOME}/ec-earth-3/trunk/
# gall 'CALL.xios_set_domain_attr'|grep bounds_lon_2d
# sources/xios-2.5/src/test/test_new_features.f90:158:  CALL xios_set_domain_attr("domain_A",bounds_lon_2d=bnds_lon,bounds_lat_2d=bnds_lat, nvertex=4, type='curvilinear')



# Creating test data:
# for i in {1..9}; do echo rsync -a cmor-cmip-test-all-t004-01-original/ cmor-cmip-test-all-t004-01-bup-$i; done
# for i in {1..9}; do      rsync -a cmor-cmip-test-all-t004-01-original/ cmor-cmip-test-all-t004-01-bup-$i; done

# Ruuning cmor-fixer:
# activatecmorfixer
# rm -f list-of-modified-files* ;./cmor-fixer.py --verbose --olist --npp 1 --dry cmor-cmip-test-all-t004-01-bup-1/
