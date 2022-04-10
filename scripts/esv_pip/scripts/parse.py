import argparse
import pysam
def main():
    parser = argparse.ArgumentParser("parse")
    parser.add_argument('-v', required=True)
    parser.add_argument('-b', required=False)
    parser.add_argument('-o', required=True)
    parser.add_argument('--lumpy', action='store_true')
    parser.add_argument('--manta', action='store_true')
    args = parser.parse_args()
    evidences = {}
    in_vcf = open(args.v)
    out_vcf = open(args.o,"w")
    if args.lumpy:
        evids = []
        tag = True
        ev_tag = True
        for line in in_vcf.readlines():
            if line.startswith("#"):
                out_vcf.write(line)
                if tag and line.startswith("##INFO"):
                    tag = False
                    out_vcf.write('##INFO=<ID=READNAMES,Number=1,Type=String,Description="Support reads name">\n')
                continue
            elif "Evidence" in line:
                tmp = line.split("\t")
                evids.append(tmp[2])
            else:
                tmp = line.split("\t")
                tmp[7] = tmp[7]+";READNAMES="+",".join(evids)
                out_vcf.write("\t".join(tmp))
                evids = []
    elif args.manta:
        samfile = pysam.AlignmentFile(args.b, "rb")
        for read in samfile.fetch():
            evidence_tag = read.get_tags()[-1][-1]
            bnd_id = evidence_tag.split("|")[0]
            if bnd_id in evidences.keys():
                evidences[bnd_id].append(read.query_name)
            else:
                evidences[bnd_id] = [read.query_name]
            # print(read.get_tags()[-1][-1])
    # print(evidences)
        tag = True
        for line in in_vcf.readlines():
            if line.startswith("#"):
                out_vcf.write(line)
                if tag and line.startswith("##INFO"):
                    tag = False
                    out_vcf.write('##INFO=<ID=READNAMES,Number=1,Type=String,Description="Support reads name">\n')
                continue
            tmp = line.split("\t")
            bnd_id = tmp[2]

            if bnd_id in evidences.keys():
                tmp[7] = tmp[7]+";READNAMES="+",".join(evidences[bnd_id])
                out_vcf.write("\t".join(tmp))

if __name__ == '__main__':
    main()
    