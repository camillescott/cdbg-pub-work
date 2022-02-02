import pandas as pd

data = pd.read_csv('runs_10m_to_50m_reads_500.csv')\
         .set_index('run_accession')\
         .head(10)\
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


def get_stream_url_subst(accession):
    url = data[accession]['fastq_ftp']
    if ';' in url:
        l, _, r = url.partition(';')
        return f'<(curl -sL {l.strip(";")}) <(curl -sL {r.strip(";")})'
    return f'<(curl -sL {url})'


def get_mode(accession):
    return 'split' if ';' in data[accession]['fastq_ftp'] else 'single'


rule goetia_solid_cdbg_stream:
    output:
        'outputs/stream/{accession}/solid-cdbg/goetia.cdbg.stats.json',
        'outputs/stream/{accession}/solid-cdbg/goetia.cdbg.unitigs.bp.json'
    benchmark:
        'benchmarks/stream/{accession}/solid-cdbg/benchmark.tsv'
    log:
        'logs/stream/{accession}/solid-cdbg/log.txt'
    threads: 1
    params:
        subst = lambda wildcards: get_stream_url_subst(wildcards.accession),
        mode = lambda wildcards: get_mode(wildcards.accession)
    shell:
        'goetia solid-filter -i {params.subst} --solid-threshold 1.0 '
        '--pairing-mode {params.mode} -K 31 -x 1e9 -o /dev/stdout '
        '| goetia cdbg -K 31 --storage SparseppSetStorage '
        '--results-dir outputs/stream/{wildcards.accession}/solid-cdbg/ '
        '--track-cdbg-stats --pairing-mode single -i /dev/stdin '
        '--names {wildcards.accession} --track-cdbg-unitig-bp'

rule goetia_solid_cdbg_stream_all:
    input:
        expand('outputs/stream/{accession}/solid-cdbg/goetia.cdbg.stats.json',
               accession=list(data.keys()))


rule goetia_solid_sourmash_stream:
    output:
        'outputs/stream/{accession}/solid-sourmash/stream.sig'
    benchmark:
        'benchmarks/stream/{accession}/solid-sourmash/benchmark.tsv'
    log:
        'logs/stream/{accession}/solid-sourmash/log.txt'
    threads: 1
    params:
        subst = lambda wildcards: get_stream_url_subst(wildcards.accession),
        mode = lambda wildcards: get_mode(wildcards.accession)
    shell:
        'mkdir -p outputs/stream/{wildcards.accession}/solid-sourmash/ && '
        'goetia solid-filter -i {params.subst} --solid-threshold 1.0 '
        '--pairing-mode {params.mode} -K 31 -x 2e8 -N 4 -o /dev/stdout '
        '| goetia sourmash -N 5000 --pairing-mode single -i /dev/stdin '
        '--names {wildcards.accession} --save-sig {output} --save-stream'


rule goetia_solid_sourmash_stream_all:
    input:
        expand('outputs/stream/{accession}/solid-sourmash/stream.sig',
               accession=list(data.keys()))


rule goetia_sourmash_stream:
    output:
        'outputs/stream/{accession}/sourmash/stream.sig'
    benchmark:
        'benchmarks/stream/{accession}/sourmash/benchmark.tsv'
    log:
        'logs/stream/{accession}/sourmash/log.txt'
    threads: 1
    params:
        subst = lambda wildcards: get_stream_url_subst(wildcards.accession),
        mode = lambda wildcards: get_mode(wildcards.accession)
    shell:
        'mkdir -p outputs/stream/{wildcards.accession}/sourmash/ && '
        'goetia sourmash -N 5000 --pairing-mode {params.mode} -i {params.subst} '
        '--names {wildcards.accession} --save-sig {output} --save-stream'


rule goetia_sourmash_stream_all:
    input:
        expand('outputs/stream/{accession}/sourmash/stream.sig',
               accession=list(data.keys()))
