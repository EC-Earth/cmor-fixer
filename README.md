# cmor-fixer
On-site fixer script for cmorized data

Python code to fix the incorrect longitude eastward shift of half a grid cell by ece2cmor, see [ece2cmor issue 553](https://github.com/EC-Earth/ece2cmor3/issues/553).

## Required python packages:

* netCDF4
* numpy

## 1. Installation


#### Installation with miniconda3:
The Miniconda python distribution should be installed. With miniconda all the packages can be installed within one go by the package manager `conda`. This applies also to systems where one is not allowed to install complementary python packages to the default python distribution.

##### If Miniconda3 is not yet installed:

Download [miniconda](https://repo.continuum.io/miniconda/) (e.g. take the latest miniconda version for python 3) by using `wget` and install with `bash`:
 ```shell
 mkdir -p Downloads; cd Downloads/
 wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
 bash Miniconda3-latest-Linux-x86_64.sh -b -u -p /$HOME/miniconda3  #  for instance on your laptop
 bash Miniconda3-latest-Linux-x86_64.sh -b -u -p /$PERM/miniconda3  #  for instance on cca, because on $PERM the disk space is sufficient, which is on cca not the case for $HOME.

 ```
One could consider to add the following variable definition and alias in the `.bashrc` file:
 ```shell
 miniconda3path=${HOME}/miniconda3/                                 #  for instance on your laptop
 miniconda3path=${PERM}/miniconda3/                                 #  for instance on cca
 
 alias activateminiconda3='source ${miniconda3path}/etc/profile.d/conda.sh'
 ```

##### Download cmor-fixer by a git checkout

For example we create the directoy ${HOME}/cmorize/ for the cmor-fixer:

```shell
git clone https://github.com/EC-Earth/cmor-fixer.git
```

##### Creating a conda environment and installing cmor-fixer therein:
In the cmor-fixer git checkout directory, type
```shell
activateminiconda3                         # The alias as defined above
conda update -y -n base -c defaults conda  # for updating conda itself
cd cmor-fixer
conda env create -f environment.yml        # for linux & mac os
```

## 2. Run cmor-fixer

### Test cmor-fixer

##### Running the cmor-fixer inside the conda environment:
```shell

 # Activate the cmor-fixer conda environment:
 activateminiconda3                        # The alias as defined above
 conda activate cmorfixer
 
 # The help of cmor-fixer list its argument options:
 ./cmor-fixer.py -h
 
 # A dry-run example which, due to the --forceid option, will give a new tracking id to any file
 # encountered including files with correct lon data:
 ./cmor-fixer.py --verbose --forceid --olist --npp 1 --dry CMIP6/
 
 conda deactivate
```

### Apply cmor-fixer at the ESGF node to data which has been published at the ESGF node


##### Option 1: Running the cmor-fixer inside the conda environment:

```shell

 # Activate the cmor-fixer conda environment:
 activateminiconda3                        # The alias as defined above
 conda activate cmorfixer

 # An example in which cmor fixer is applying the lon & lon_bnds fix to the data:
 ./cmor-fixer.py --verbose --forceid --olist --npp 1 CMIP6/
 
 conda deactivate
```

##### Option 2: Alternatively, use the `cmor-fixer-save-mode-wrapper.sh` script:

The `cmor-fixer-save-mode-wrapper.sh` script will only apply changes if at least one file with one error is detected in the entire dataset. In case an error is detected and the script will continue to apply changes, additional checks will be applied to check for interuptions during running the script.
```
 # Activate the cmor-fixer conda environment:
 activateminiconda3                        # The alias as defined above
 conda activate cmorfixer
 
 ./cmor-fixer-save-mode-wrapper.sh 1 CMIP6/
 
 conda deactivate
```

##### Option 3: Use a submit script:

The `submit-cmor-fixer.sh` script is an `sbatch` template for a submit script which needs adjustments of all the paths and possibly adjustent of the cmor-fixer arguments depending on the preferences of the user. The script can be called (it activates the cmor environment itself at the compute node) by:
```shell
sbatch submit-cmor-fixer.sh
```

### Apply cmor-fixer to data which has not been published before

```shell

 # Activate the cmor-fixer conda environment:
 activateminiconda3                        # The alias as defined above
 conda activate cmorfixer

 # An example in which cmor fixer is applying the lon & lon_bnds fix to the data:
 ./cmor-fixer.py --verbose --keepid --olist --npp 1 CMIP6/
 
 conda deactivate
```

## 3. Adjust the version directory name

##### Adjust the version directory name after the cmor-fixer.py script has been applied

First run the `version.sh` script, for its help use:
```shell
./versions.sh -h
```
In order to see whether there is more than one version in your data:
```shell
./versions.sh -l CMIP6/
```
If so (this happens when during running the script the date changed because you crossed midnight), you need to set one version (you can choose what you want, but it should be a different and later date than the one which was previously published). One can set the date for instance to January 20 2020 by:
```shell
./versions.sh -v v20200120 -m CMIP6/
```

## 4. Some basic validation checks

#### Run the script which counts the number of files per year in your dataset:
```
./files-per-year.sh 1850 2014 CMIP6
```
#### Run `nctime` which checks whether the metadata doesn't show time gaps (due to glitches):
```
conda deactivate                     # Leaving the cmorfixer environment due to trouble with installing nctime
activateminiconda3                   # Only needed when not done before (doesn't harm to do it twice)
cd nctime/
./run-nctime-for-cmip6.sh CMIP6      # This will install nctime directly in the miniconda3 environment en run it
```

## 5. Check the longitude-shift fix itself

With 
```
ncdump -v lon some-cmorised-file.nc
ncdump -v lon_bnds some-cmorised-file.nc
```
one can easily see the `lon` & `lon_bnds` values.

#### The longitude values

Incorrect `lon` values start at `0.3515625` like: 
```
lon = 0.3515625, 1.0546875, 1.7578125, 2.4609375, 3.1640625, 3.8671875, 
```
while correct `lon` values start at `0` like:
```
lon = 0, 0.703125, 1.40625, 2.109375, 2.8125, 3.515625, 4.21875, 4.921875, 
```

#### The longitude boundaries values

Incorrect `lon_bnds` values start at `0, 0.703125` like: 
```
 lon_bnds =
  0, 0.703125,
  0.703125, 1.40625,
  1.40625, 2.109375,
  2.109375, 2.8125,
  2.8125, 3.515625,
  3.515625, 4.21875,
  4.21875, 4.921875,
  4.921875, 5.625,
  5.625, 6.328125,
```
while correct `lon_bnds` values start at `-0.3515625, 0.3515625` like:
```
 lon_bnds =
  -0.3515625, 0.3515625,
  0.3515625, 1.0546875,
  1.0546875, 1.7578125,
  1.7578125, 2.4609375,
  2.4609375, 3.1640625,
  3.1640625, 3.8671875,
  3.8671875, 4.5703125,
  4.5703125, 5.2734375,
  5.2734375, 5.9765625,
  5.9765625, 6.6796875,
```

#### Comparing the pre & post fixed file

Because the error and the fix are in the coordinate values itself, diffing the files well is slightly complicated. The best way to inspect the changes in a file after fixing is to make a `ncdump` of the file before fixing and a `ncdump` of the file after fixing and thereafter use `meld` to compare them (it takes a while before meld manages to load). You will then see that the `lon` and/or `lon_bnds` values are shifted half a gird cell westwards (lower), that the `tracking_id`is changed and that a message is added to the netcdf history attribute telling that @cmor-fixer@ has modified the file.
