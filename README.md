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


### Build the squirrel container:

```bash
cd $VSC_SCRATCH
mkdir containers
touch containers/squirrel.def
vi containers/squirrel.def
```
copy the content from https://github.com/vib-bic-nextflow/amst2_nextflow/blob/main/squirrel.def

Submit the build as a slurm job
```bash
sbatch apptainer_squirrel.slurm
```
Monitor the building
```bash
squeue

saact
```

### OLD WAY WITH CONDA (NOT WORKING ON TIER 2 KU LEUVEN)

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


see [container](https://github.com/vib-bic-admin/vsc-hpc-bic/blob/main/scripts/apptainer_build_tier2kul.slurm)

### How to run the nextflow

```
cd $VSC_SCRATCH
module load cluster/genius/batch
module load Nextflow
# how to run on Tier2
nextflow run amst2_nextflow -c $VSC_DATA/vsc_kuleuven.config -profile vsc_kul_uhasselt,genius,singularity_tier2 --input /scratch/leuven/336/vsc33625/anneke/EM_436_S4_BPA_Run020226 --outdir /scratch/leuven/336/vsc33625/anneke/output
# on Tier1
nextflow run amst2_nextflow -c $VSC_DATA/vsc_gent.config -profile vsc_gent,singularity_tier1 --input $VSC_SCRATCH_PROJECTS_BASE/2024_300/bpavie/anneke/EM_436_S4_BPA_Run020226 --outdir $VSC_SCRATCH_PROJECTS_BASE/2024_300/bpavie/anneke/output
# how to restart
nextflow run amst2_nextflow -c $VSC_DATA/vsc_kuleuven.config -profile vsc_kul_uhasselt,genius,singularity_tier2 --input /scratch/leuven/336/vsc33625/anneke/EM_436_S4_BPA_Run020226 --outdir /scratch/leuven/336/vsc33625/anneke/output -resume
```
#### Check the status after running

Go to https://ondemand.hpc.kuleuven.be and go to `Cluster > _Login Server Sheell Access`

<img width="240" height="87" alt="image" src="https://github.com/user-attachments/assets/e30345ae-3a1a-42c1-a608-50f110572f04" />

```bash
squeue
JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
58964780     batch nf-AMST2 vsc33625  R       9:13      1 r25i13n17

sacct
JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- -------- 
58964779     nf-AMST2_+      batch lp_hack_b+          2  COMPLETED      0:0 
58964779.ba+      batch            lp_hack_b+          2  COMPLETED      0:0 
58964779.ex+     extern            lp_hack_b+          2  COMPLETED      0:0 
58964780     nf-AMST2_+      batch lp_hack_b+          8    RUNNING      0:0 
58964780.ba+      batch            lp_hack_b+          8    RUNNING      0:0 
58964780.ex+     extern            lp_hack_b+          8    RUNNING      0:0
```

```bash
cd $VSC_SCRATCH/work/15/96619f751c5a3f7c87cc213d3da6ca/.command.log
```

> [!TIP]
> Sometimes it's failing
> ```bash
> [76/d3b572] NOTE: Process `apply_sbs_alignment` terminated with an error exit status (1) -- Execution is retried (1)
> [88/03777d] Re-submitted process > apply_sbs_alignment
> [88/03777d] NOTE: Process `apply_sbs_alignment` terminated with an error exit status (1) -- Execution is retried (2)
> ```
> And will retry with a maximum attend of 3 times.
> 
> Each time it retries, it will double the amount of memory allocated defined by its _process label_. The category of each _process label_ is defined in `amst2_nextflow/conf/base.config`. The process category is defined for each module (e.g. https://github.com/vib-bic-nextflow/amst2_nextflow/blob/main/modules/local/apply_multi_stack_alignment/sq_apply_multi_stack_alignment.nf , you can see by defau;lt it's using `label 'process_cpu_medium'`, which if we see the `base.config` is defined to use
> ```
> withLabel:process_cpu_medium { 
>        cpus        = { 8     * task.attempt }
>        memory      = { 16.GB * task.attempt }
>        time        = { 1.h   * task.attempt }
>    } 
> ```


> [!TIP]
> Tier2 KU Leuven require to be part of a group with credit to run something, so lp_hack_bio_im is the name of our group. See your group here : https://account.vscentrum.be/django/group/





