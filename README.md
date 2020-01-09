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
One could consider to add the following aliases in the `.bashrc` file:
 ```shell
 minconda3path=${HOME}/miniconda3/                                 #  for instance on your laptop
 minconda3path=${PERM}/miniconda3/                                 #  for instance on cca
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


##### Running the cmor-fixer inside the conda environment:

```shell

 # Activate the cmor-fixer conda environment:
 activateminiconda3                        # The alias as defined above
 conda activate cmorfixer

 # An example in which cmor fixer is applying the lon & lon_bnds fix to the data:
 ./cmor-fixer.py --verbose --forceid --olist --npp 1 --dry CMIP6/
 
 conda deactivate
```

The `submit-cmor-fixer.sh` script is an `sbatch` template for a submit script which needs adjustments of all the paths and possibly adjustent of the cmor-fixer arguments depending on the preferences of the user. The script can be called by:
```shell
sbatch submit-cmor-fixer.sh
```

### Apply cmor-fixer to unpublished data

...waiting for content...

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
