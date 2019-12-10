# cmor-fixer
On-site fixer script for cmorized data

Python code to fix the incorrect longitude eastward shift of half a grid cell by ece2cmor, see [ece2cmor issue 553](https://github.com/EC-Earth/ece2cmor3/issues/553).

## Required python packages:

* netCDF4
* numpy

## Installation:


#### Installation & running with miniconda3:
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

##### Running the cmor-fixer inside the conda environment:

```shell
 conda activate cmorfixer
  ./cmor-fixer.py -h
  ./cmor-fixer.py --verbose --dry /lustre2/projects/model_testing/reerink/cmorised-results/cmor-cmip-test-all-11/t002/ifs/001/CMIP6/

 conda deactivate
```
