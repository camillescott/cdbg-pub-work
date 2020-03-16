import pandas as pd

data = pd.read_csv('runs_subsample_500.csv')\
         .set_index('run_accession')\
         .head(50)\
         .to_dict(orient='index')

def get_curl_ftp_url(accession):
    ''' Get a curl-compatiable URL from the given accession.
    A paired sample will be compressed down to
    a single URL using {1,2}.fastq.
    '''
    url = data[accession]['fastq_ftp']
    if ';' in url:
        url, _, r = url.partition(';')
        url = url.replace('_1.fastq', '_{1,2}.fastq')
    return url


rule goetia_solid_cdbg_stream:
    output:
        'outputs/stream/{accession}/cdbg/goetia.cdbg.stats.json',
        'outputs/stream/{accession}/cdbg/goetia.cdbg.unitigs.bp.json'
    benchmark:
        'benchmarks/stream/{accession}/cdbg/benchmark.tsv'
    log:
        'logs/stream/{accession}/cdbg/log.txt'
    threads: 1
    params:
        url = lambda wildcards: get_curl_ftp_url(wildcards.accession)
    shell:
        'curl -sL {params.url} '
        '| goetia solid-filter -i /dev/stdin --pairing-mode single -K 31 -x 1e9 -o /dev/stdout '
        '| goetia cdbg -K 31 --storage SparseppSetStorage '
        '--results-dir outputs/stream/{wildcards.accession}/cdbg/ '
        '--track-cdbg-stats --pairing-mode single -i /dev/stdin '
        '--names {wildcards.accession} --track-cdbg-unitig-bp'

rule goetia_solid_cdbg_stream_all:
    input:
        expand('outputs/stream/{accession}/cdbg/goetia.cdbg.stats.json',
               accession=list(data.keys()))
