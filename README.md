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
sftp -P 22345 benjaminp@fs0.irc.ugent.be
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

> [!TIP]
> Tier2 KU Leuven require to be part of a group with credit to run something, so lp_hack_bio_im is the name of our group. See your group here : https://account.vscentrum.be/django/group/





