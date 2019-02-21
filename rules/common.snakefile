import glob
import os

BOINK_VERSION = subprocess.check_output('git ls-remote https://github.com/camillescott/boink.git refs/heads/master | cut -f 1', shell=True)


# Get the output fasta paths for the samples, filtering on
# type (transcriptome, genome, metagenome) if desired
def data(type_filter=None):
    paths = []
    for sample in config['samples'].keys():
        if type_filter is not None:
            if config['samples'][sample]['type'] != type_filter:
                continue
        paths.append('data/{sample}/left.fq'.format(
                     sample = sample))
        paths.append('data/{sample}/right.fq'.format(
                     sample = sample))
    return paths


def result_paths(analyses=list(config['analyses'].keys()),
                 types=['genome', 'transcriptome', 'metagenome']):
    paths = []
    root  = config['result_format']
    for sample in config['samples'].keys():
        if config['samples'][sample]['type'] not in types:
                continue
        for analysis in config['analyses'].keys():
            if analysis not in analyses:
                continue
            for ksize in config['samples'][sample]['ksizes']:
                name = config['analyses'][analysis]['result']
                paths.append(os.path.join(root, name).format(
                    sample   = sample,
                    ksize    = ksize,
                    analysis = analysis)
                )
    return paths


def get_sample(accession):
	return config['accessions'][accession]


def get_accession(sample):
	return config['samples'][sample]['accession']

