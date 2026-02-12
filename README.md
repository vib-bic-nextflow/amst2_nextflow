# AMST2 Nextflow

## Tranfer the data

"I have a new dataset, located in `O:\microscopy\service\user_micro\2026\Anneke_BIC\Datasets for Registration\EM_436_S4_BPA_Run020226`"

on the server, it means : `/microscopy/service/user_micro/2026/Anneke_BIC/Datasets for RegistrationEM_436_S4_BPA_Run020226`

### Using scp

#### Connect using putty to the server
##### Tier 2 KU Leuven:
- Connect : vsc33625@login.hpc.kuleuven.be
- Port : 22
Tier2 require a firewall connection, just enter your credential

- Go to the scratch
```bash
cd $VSC_SCRATCH
```
- Check you quota
```bash
myquota
file system $VSC_DATA
    Blocks: 46504M of 76800M
    Files: 487k of 10000k
file system $VSC_HOME
    Blocks: 560M of 3072M
    Files: 10813 of 100k
file system $VSC_SCRATCH
    Blocks: 332k of 1T
file system stg_00128
    Blocks: 24.04G of 2T
    Files: 2292 of 300000
```
- Using sftp, download teh dataset to the scratch
```bash
cd $VSC_SCRATCH
mkdir anneke
cd anneke
sftp -P 22345 username@fs0.irc.ugent.be
cd /microscopy/service/user_micro/2026/Anneke_BIC/Datasets\ for\ Registration
get -r EM_436_S4_BPA_Run020226
exit
```
- Modify your bashrc
```bash
cd $VSC_HOME
# or
cd
# paste in your bashrc
vim .bashrc
export NXF_HOME="$VSC_SCRATCH/.nextflow"
export NXF_WORK="$VSC_SCRATCH/work"
 
# Needed for running Apptainer containers
export APPTAINER_CACHEDIR=$VSC_SCRATCH/.apptainer/cache
export APPTAINER_TMPDIR=$VSC_SCRATCH/.apptainer/tmp
export NXF_CONDA_CACHEDIR=$VSC_DATA/miniconda3/envs

export SBATCH_ACCOUNT='lp_hack_bio_im'
export SLURM_ACCOUNT='lp_hack_bio_im'
```
```bash
source .bashrc
```

- Set the intitutional nf-core config
```bash
cd $VSC_DATA
# create a directory
mkdir nextflow_config
cd nextflow_config
```
```bash
wget -o vsc_kul.config https://github.com/vib-bic-projects/2025_11_Irene/blob/main/lsmquant/vsc_kul_adapted.config
```

Do this until amst2 is containerized
- Install conda if not already installed

- Install a container for amst2
```bash
conda create -n amst2-env -c bioconda -c conda-forge --override-channels python=3.11 nibabel opencv zarr=2 vigra pandas 
source activate amst2-env
pip install SimpleITK-SimpleElastix transforms3d ruamel.yaml
pip install https://github.com/jhennies/squirrel/archive/refs/tags/0.3.15.tar.gz
pip install https://github.com/jhennies/AMST2/archive/refs/tags/0.3.14.tar.gz
```

- Clone the AMST2  repository
```bash
cd $VSC_SCRATCH
git clone https://github.com/vib-bic-nextflow/amst2_nextflow.git
```

#### Set the nextflow.config

```bash

conda env list
# conda environments:
#
base                     /data/leuven/336/vsc33625/miniconda3
amst2-env             *  /data/leuven/336/vsc33625/miniconda3/envs/amst2-env

cd amst2_nextflow

vim nextflow.config
(...)
 conda_tier2{
  process.executor= "slurm"
  conda.enabled = true
  singularity.enabled= false
  docker.enabled=false
  process.conda='/data/leuven/336/vscxxxxxx/miniconda3/envs/amst2-env'
}
(...)
```
### Build the squirrel container:

```bash
cd $VSC_SCRATCH
mkdir containers
touch containers/squirrel.def
vi containers/squirrel.def
```
```
Bootstrap: docker
From: continuumio/miniconda3

%files

%runscript
exec "$@"

%environment
CONDA_BIN_PATH="/opt/conda/bin"
export PATH="$CONDA_BIN_PATH:$PATH"
export PATH="/opt/conda/envs/squirrelenv/bin:$PATH"

%post
apt-get update -y
apt install -y build-essential
export PATH="/opt/conda/bin:$PATH"
conda create --name squirrelenv -c bioconda -c conda-forge --override-channels python=3.11 nibabel opencv zarr=2 vigra pandas
pip install --upgrade pip
/opt/conda/envs/squirrelenv/bin/pip install SimpleITK-SimpleElastix transforms3d ruamel.yaml
/opt/conda/envs/squirrelenv/bin/pip install  https://github.com/jhennies/squirrel/archive/refs/tags/0.3.15.tar.gz
```
Submit the build as a slurm job
```bash
sbatch apptainer_squirrel.slurm
```
Montitor the building
```bash
squeue

saact
```


see [container](https://github.com/vib-bic-admin/vsc-hpc-bic/blob/main/scripts/apptainer_build_tier2kul.slurm)

### How to run the nextflow

```
cd $VSC_SCRATCH
module load Nextflow
# how to run
nextflow run amst2_nextflow -c $VSC_DATA/vsc_kuleuven.config -profile vsc_kul_uhasselt,genius,conda_tier2 --input /scratch/leuven/336/vsc33625/anneke/EM_436_S4_BPA_Run020226 --outdir /scratch/leuven/336/vsc33625/anneke/output
# how to restart
nextflow run amst2_nextflow -c $VSC_DATA/vsc_kuleuven.config -profile vsc_kul_uhasselt,genius,conda_tier2 --input /scratch/leuven/336/vsc33625/anneke/EM_436_S4_BPA_Run020226 --outdir /scratch/leuven/336/vsc33625/anneke/output -resume
```




> [!TIP]
> Tier2 KU Leuven require to be part of a group with credit to run something, so lp_hack_bio_im is the name of our group. See your group here : https://account.vscentrum.be/django/group/





