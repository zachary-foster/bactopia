FROM nfcore/base

LABEL version="1.5.1"
LABEL authors="robert.petit@emory.edu"
LABEL description="Container image for Bactopia"

RUN conda create -n bactopia -c conda-forge -c bioconda bactopia=1.5.1 && conda clean -a

ENV PATH /opt/conda/envs/bactopia/bin:$PATH
