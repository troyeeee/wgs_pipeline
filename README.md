# preprocessing pipeline for WGS data 

# Enviroments:

修改scripts/esv_pipe/main.sh 和 scripts/complex/extract_complex_reads.sh 里面的软件local路径;
需要的软件：
- bamUtil: `https://genome.sph.umich.edu/wiki/BamUtil`
- samtools
- Svaba: `conda install -c bioconda svaba`
- Manta :  `conda install -c bioconda manta`
- Bcftools
- LumpySv: `conda install -c bioconda lumpy-sv`
- SvTyper: `conda install -c bioconda svtyper`
- SURVIVOR: `https://github.com/panguangze/SURVIVOR`（一定要这个版本）
- EXTRACT_HAIR: `https://github.com/panguangze/extractHairs ` （一定要 no_blast_v 分支）
- DELLY: `https://github.com/panguangze/delly` (一定要这个版本)

# Usage:

`python main.py --help`

