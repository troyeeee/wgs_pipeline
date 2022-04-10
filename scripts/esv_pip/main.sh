#!/bin/bash
SVABA=svaba
CONFIGMANTA=/home/grads/gzpan2/apps/miniconda3/envs/cityu2/bin/configManta.py
SAMTOOLS=samtools
BCFTOOLS=bcftools
LUMPY_EXPRESS=/home/grads/gzpan2/apps/lumpy-sv/bin/lumpyexpress
SVTYPER=/home/grads/gzpan2/apps/miniconda3/envs/cityu2/bin/svtyper
# SCRIPTS=/home/grads/gzpan2/apps/esv_pipe/scripts
SURVIVOR=/home/grads/gzpan2/apps/SURVIVOR/Debug/SURVIVOR
EXTRACT_HAIR=/home/grads/gzpan2/clion/extractHairs/build/ExtractHAIRs
ESplitReads_BwaMem=/home/grads/gzpan2/apps/lumpy-sv/scripts/extractSplitReads_BwaMem
DELLY=/home/grads/gzpan2/apps/delly/bin/delly
#GRIDSS=/home/grads/gzpan2/apps/miniconda3/envs/cityu2/share/gridss-2.8.0-0/gridss.jar
bam=$1
ref=$2
out_dir=$3
threads=$4
SUR_SAMPLE=$5
SCRIPTS=$6
if [ ! -d $out_dir ]; then
  mkdir $out_dir
fi
if [ ! -d $out_dir/svaba ]; then
  mkdir $out_dir/svaba
fi
if [ ! -d $out_dir/manta ]; then
  mkdir $out_dir/manta
fi
if [ ! -d $out_dir/lumpy ]; then
  mkdir $out_dir/lumpy
fi
# if [ ! -d $out_dir/gridss ]; then
#   mkdir $out_dir/gridss
# fi
if [ ! -d $out_dir/delly ]; then
  mkdir $out_dir/delly
fi
# svaba
$SVABA run -t $bam -G $ref -a $out_dir/svaba/svaba --read-tracking --germline -p $threads
cp $out_dir/svaba/svaba.svaba.sv.vcf  $out_dir/svaba/svaba.svtyper.sv.vcf
python3 $SCRIPTS/adjust_svtyper_genotypes.py $out_dir/svaba/svaba.svtyper.sv.vcf > $out_dir/svaba/svaba.adjusted.vcf
# manta
$CONFIGMANTA --bam $bam --referenceFasta $ref --runDir $out_dir/manta --generateEvidenceBam
$out_dir/manta/runWorkflow.py -m local -j $threads -g 100
gunzip $out_dir/manta/results/variants/diploidSV.vcf.gz
cp $out_dir/manta/results/variants/diploidSV.vcf  $out_dir/manta/manta.svtyper.vcf
python3 $SCRIPTS/parse.py -v $out_dir/manta/manta.svtyper.vcf -b $out_dir/manta/results/evidence/evidence_0.test.s.ngs.bam -o $out_dir/manta/manta.evidence.vcf
python3 $SCRIPTS/adjust_svtyper_genotypes.py $out_dir/manta/manta.evidence.vcf > $out_dir/manta/manta.adjusted.vcf
# lumpy
$SAMTOOLS view -uF 0x0002 $bam | $SAMTOOLS view -uF 0x100 - | $SAMTOOLS view -uF 0x0004 - | $SAMTOOLS view -uF 0x0008 - | $SAMTOOLS view -bF 0x0400 - | $SAMTOOLS sort - -o $out_dir/lumpy/lumpy.discordant.sort.bam
$SAMTOOLS view -h $bam | $ESplitReads_BwaMem -i stdin | $SAMTOOLS view -Sb - | $SAMTOOLS sort - -o $out_dir/lumpy/lumpy.sr.sort.bam
$LUMPY_EXPRESS -B $bam -S $out_dir/lumpy/lumpy.sr.sort.bam -D $out_dir/lumpy/lumpy.discordant.sort.bam -o $out_dir/lumpy/lumpy.vcf
$SVTYPER -B $bam -i $out_dir/lumpy/lumpy.vcf > $out_dir/lumpy/lumpy.svtyper.vcf
python3 $SCRIPTS/parse.py -v $out_dir/lumpy/lumpy.svtyper.vcf -b $out_dir/lumpy/results/evidence/evidence_0.test.s.ngs.bam -o $out_dir/lumpy/lumpy.evidence.vcf
python3 $SCRIPTS/adjust_svtyper_genotypes.py $out_dir/lumpy/lumpy.evidence.vcf > $out_dir/lumpy/lumpy.adjusted.vcf

#delly
$DELLY call -g $ref -o $out_dir/delly/delly.bcf  $bam
$BCFTOOLS view $out_dir/delly/delly.bcf > $out_dir/delly/delly.vcf
$SVTYPER -B $bam -i $out_dir/delly/delly.vcf > $out_dir/delly/delly.svtyper.vcf
python3 $SCRIPTS/adjust_svtyper_genotypes.py $out_dir/delly/delly.svtyper.vcf > $out_dir/delly/delly.adjusted.vcf
# generate input for survivor
touch $out_dir/sur.input
echo "$out_dir/manta/manta.adjusted.vcf" >> $out_dir/sur.input
echo "$out_dir/svaba/svaba.adjusted.vcf" >> $out_dir/sur.input
echo "$out_dir/lumpy/lumpy.adjusted.vcf" >> $out_dir/sur.input
echo "$out_dir/delly/delly.adjusted.vcf" >> $out_dir/sur.input

#sur
$SURVIVOR merge $out_dir/sur.input 1000 1 1 0 0 10 $out_dir/survivor.output.vcf
bcftools sort $out_dir/survivor.output.vcf -o $out_dir/survivor.sort.vcf
python2 $SCRIPTS/combine_combined.py $out_dir/survivor.sort.vcf $SUR_SAMPLE $out_dir/survivor_inputs $SCRIPTS/all.phred.txt > $out_dir/combined.genotyped.vcf
bgzip $out_dir/combined.genotyped.vcf
tabix $out_dir/combined.genotyped.vcf.gz
$EXTRACT_HAIR --bam $bam --vcf $out_dir/combined.genotyped.vcf.gz --out $out_dir/ext.lst --breakends 1 --mate_at_same 1 --support_read_tag READNAMES
# gridss
#java -cp $GRIDSS gridss.CallVariants -r $ref O=$out_dir/gridss/gridss.vcf.gz --threads $threads $bam

#GRIDSS_JAR=/home/grads/gzpan2/apps/miniconda3/envs/cityu2/share/gridss-2.8.0-0/gridss.jar
#java -ea -Xmx31g \
##-Dsamjdk.create_index=true \
#-Dsamjdk.use_async_io_read_samtools=true \
#-Dsamjdk.use_async_io_write_samtools=true \
#-Dsamjdk.use_async_io_write_tribble=true \
#-Dgridss.gridss.output_to_temp_file=true \
#-cp $GRIDSS_JAR gridss.CallVariants \
#TMP_DIR=./tmp \
#WORKING_DIR=. \
#REFERENCE_SEQUENCE="$ref" \
#INPUT="$bam" \
#OUTPUT="$out_dir/grids/grids.vcf.gz" \
#ASSEMBLY="$out_dir/grids/grids.assembly.bam" \
#THREADS=$threads \
#2>&1 | tee -a gridss.$HOSTNAME.$$.log
