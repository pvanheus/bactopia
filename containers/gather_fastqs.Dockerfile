FROM nfcore/base:1.12.1

LABEL base.image="nfcore/base:1.12.1"
LABEL software="Bactopia - gather_fastqs"
LABEL software.version="1.5.6"
LABEL description="A flexible pipeline for complete analysis of bacterial genomes"
LABEL website="https://bactopia.github.io/"
LABEL license="https://github.com/bactopia/bactopia/blob/master/LICENSE"
LABEL maintainer="Robert A. Petit III"
LABEL maintainer.email="robert.petit@emory.edu"
LABEL conda.env="bactopia/conda/linux/gather_fastqs.yml"
LABEL conda.md5="1b36ee0296bd58e2bc5bd714d6e464ff"

COPY conda/linux/gather_fastqs.yml /
COPY bin/check-assembly-accession.py /
RUN conda env create -q -f gather_fastqs.yml && \
    conda clean -y -a && \
    /opt/conda/envs/bactopia-gather_fastqs/bin/python3 check-assembly-accession.py GCF_003431365 && \
    mv /root/.config /.config && \
    chmod -R 775 /.config && \
    ln -s /.config /root/.config

ENV PATH /opt/conda/envs/bactopia-gather_fastqs/bin:$PATH
