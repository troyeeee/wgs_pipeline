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

## Note:
lumpy注意事项：
1. python 2.7 or newer, must have pysam, numpy installed.
2. conda 安装lumpy后需要修改
`anaconda3/envs/py27/bin/lumpyexpress`文件里的 524行， 在后面添加 `-e` 参数。
![image info](lumpy.png)
3. 然后lumpy 环境需要看这个配置文件, `anaconda3/envs/py27/bin/lumpyexpress.config`, 修改这个配置文件或者local环境变量。

svtyper:
1. Python 2.7 or newer

mantaSv:
1. Pyhton 2.7-2.9


 
