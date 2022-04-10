# sample=test
# bam=/hwfssz1/ST_HEALTH/P20Z10200N0015/HanDongMing/MCD/megabolt/DT2010063086-1/DT2010063086-1.bwa.sortdup.bqsr.bam
# outdir=/hwfssz1/ST_HEALTH/P20Z10200N0015/chenxuan/wxd_work/test/wangmengyao/output
bamUtil=/hwfssz1/ST_HEALTH/P20Z10200N0015/chenxuan/wxd_work/software/bamUtil/bin/bam
samtools=/hwfssz1/ST_HEALTH/P20Z10200N0015/chenxuan/wxd_work/software/samtools/samtools

sample=$1
bam=$2
outdir=$3
region=$4


mkdir -p $outdir
# region=`sed ':a;N;$!ba;s/\n/ /g' /hwfssz1/ST_HEALTH/P20Z10200N0015/chenxuan/wxd_work/test/wangmengyao/input/new_region.list`
$samtools view -@ 4 -b $bam $region | $samtools view -@ 4 -b -F 0x4 - | $samtools sort --thread 4 -O BAM - > $outdir/$sample.tag.extract.bam
$samtools index $outdir/$sample.tag.extract.bam
$bamUtil bam2FastQ --in $outdir/$sample.tag.extract.bam --gzip --firstOut $outdir/$sample.tag.extract_1.fq.gz --secondOut $outdir/$sample.tag.extract_2.fq.gz --unpairedOut $outdir/$sample.tag.extract.unpaired.fq.gz &> /dev/null

$samtools view -H $bam |grep SN: |awk 'gsub("@SQ\t","")'|awk 'gsub("SN:","")'|awk 'gsub("LN:","")'|awk '$2<6000000'|grep -v chrM|awk '{print $1":0-"$2}' |grep -v chrEBV|grep -v chrX|grep -v chrY|grep -v chr15|grep -v chr17 |grep -v chr5 |grep -v chr8 |grep -v chr1_ |grep -v chr3 |grep -v chr4 |grep -v chr9|grep -v chr11|grep -v chr13 |grep -v chr18|grep -v chr12|grep -v chr10 >$outdir/other.locus.txt
region=`sed ':a;N;$!ba;s/\n/ /g' $outdir/other.locus.txt`
$samtools view -@ 4 -b $bam $region | $samtools view -@ 4 -b -F 0x4 - | $samtools sort --thread 4 -O BAM - > $outdir/$sample.other.extract.bam
$samtools index $outdir/$sample.other.extract.bam
$bamUtil bam2FastQ --in $outdir/$sample.other.extract.bam --gzip --firstOut $outdir/$sample.other.extract_1.fq.gz --secondOut $outdir/$sample.other.extract_2.fq.gz --unpairedOut $outdir/$sample.other.extract.unpaired.fq.gz &> /dev/null

$samtools view -@ 4 -hb -u -f 12 -F 256 $bam | $samtools sort --thread 4 -n - >$outdir/$sample.unmapped.bam
$samtools fastq -1 $outdir/$sample\_unmapped_1.fastq.gz -2 $outdir/$sample\_unmapped_2.fastq.gz $outdir/$sample.unmapped.bam

zcat $outdir/$sample.tag.extract_1.fq.gz $outdir/$sample.other.extract_1.fq.gz $outdir/$sample\_unmapped_1.fastq.gz |gzip > $outdir/$sample.complex.r1.fq.gz
zcat $outdir/$sample.tag.extract_2.fq.gz $outdir/$sample.other.extract_2.fq.gz $outdir/$sample\_unmapped_2.fastq.gz |gzip > $outdir/$sample.complex.r2.fq.gz

rm -rf $outdir/$sample.tag.extract.bam $outdir/$sample.tag.extract.bam.bai $outdir/$sample.other.extract.bam $outdir/$sample.other.extract.bam.bai $outdir/$sample.unmapped.bam $outdir/$sample.unmapped.bam.bai

rm -rf $outdir/$sample.tag.extract*
rm -rf $outdir/$sample.other.extract*
rm -rf $outdir/$sample\_unmapped*
