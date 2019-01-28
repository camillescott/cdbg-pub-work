snakemake --immediate-submit --notemp -p --verbose -j 64 --cluster '$PWD/slurm_scheduler.py {dependencies}' --cluster-config cluster.json --jobscript jobscript.sh --rerun-incomplete
