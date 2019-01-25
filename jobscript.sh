#!/bin/sh
# properties = {properties}

# Make sure the conda install is on the path
__conda_setup="$(CONDA_REPORT_ERRORS=false '/mnt/research/ged/camille/anaconda/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/mnt/research/ged/camille/anaconda/etc/profile.d/conda.sh" ]; then
        . "/mnt/research/ged/camille/anaconda/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/mnt/research/ged/camille/anaconda/bin:$PATH"
    fi
fi
unset __conda_setup

# unload the system python to avoid wonkiness
module unload python

# activate the boink environment
source activate boink

{exec_job}

cat $1
