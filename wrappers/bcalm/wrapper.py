__author__ = "Camille Scott"
__copyright__ = "Copyright 2019, Camille Scott"
__email__ = "cswel@ucdavis.edu"
__license__ = "MIT"


import os
from snakemake.shell import shell
import tempfile


reads_file = tempfile.NamedTemporaryFile(mode='w', delete=False)
reads_file.write('\n'.join((os.path.abspath(fn) for fn in snakemake.input)))
reads_fn = reads_file.name
reads_file.close()

opts = ['-in', reads_fn,
        '-out', snakemake.output,
        '-max-memory', (int(snakemake.resources.get('mem', 8)) - 1) * 1000,
        '-abundance-min', snakemake.params.get('abundance_min', 1),
        '-kmer-size', snakemake.params.get('ksize', 31)]
opts = ' '.join((str(opt) for opt in opts))

log = snakemake.log_fmt_shell(stdout=True, stderr=True)

shell('bcalm -nb-cores {snakemake.threads} {opts} {log}')
reads_file.close()
