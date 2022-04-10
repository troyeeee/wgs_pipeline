import argparse
import os

def parse_user_input():
    parser = argparse.ArgumentParser(
        description='WGS data preprocessing pipeline'
    )
    parser.add_argument('-b','--bam',
     help='Bam file of single sample',
     required=True, type=str
    )
    # parser.add_argument('-v','--snp',
    #     help='Unphased SNP VCF file (only contain snp, no sv or cnv)',
    #     required=True, type=str
    # )
    parser.add_argument('-o','--out',
        help='Folder for preprocessing out files',
        required=True, type=str
    )
    parser.add_argument('-r', '--ref',
     help='Reference genome file (fasta file). Hg38 is recommended',
     required=True, type=str
    )

    parser.add_argument('-t','--threads',
        help='Number of processes to use',
        required=False, type=int, default=16
    )

    parser.add_argument('-n','--name',
        help='Sample name used in vcf file !',
        required=False, type=str
    )
    parser.add_argument('-rg','--region',
        help='Complex region file for extracting reads',
        required=False, type=str
    )
    return parser.parse_args()

def main():
    # Get command line args
    args = parse_user_input()
    bam_file = args.bam
    # snp_vcf = args.snp
    sample_nmae = args.name
    ref = args.ref
    region_file = args.region
    out_dir = args.out
    threads = args.threads
    sv_out_dir = out_dir + "/sv_out"
    sv_scripts = "scripts/esv_pip/scripts"
    complex_out_dir = out_dir + "/complex_out"

    # sv pipeline
    os.system("scripts/esv_pip/main.sh {} {} {} {} {} {}".format(bam_file, ref, sv_out_dir, threads, sample_nmae, sv_scripts))

    # complex regions pipeline
    os.system("scripts/complex/extract_complex_reads.sh {} {} {} {}".format(sample_nmae, ref, complex_out_dir, region_file))


if __name__ == '__main__':
    main()
    




