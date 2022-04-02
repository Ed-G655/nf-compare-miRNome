
################## BASE IMAGE ######################
FROM rocker/tidyverse
################## METADATA ######################
LABEL base_image="rocker/tidyverse"
LABEL version="0"
LABEL software="nf-compare-miRNome"
LABEL software.version="0.2"
LABEL about.summary="Nextflow pipeline to extract and create miRNA and 3'UTR consensus sequences for analysis \n with targetscan and miRmap"
LABEL about.home="https://github.com/Ed-G655/nf-miRNA-SNPs-classify.nf.git"
LABEL about.documentation="https://github.com/Ed-G655/nf-miRNA-SNPs-classify.nf.git"
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Jose Eduardo Garcia Lopez <jeduardogl655@gmail.com>

################## INSTALLATION ######################

# install pipeline requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  curl \
  bedops \
  git \
  gcc-multilib \
  apt-utils \
  curl \
  perl \
  zip \
  unzip \
  expat \
  libexpat-dev \
  libtbb-dev \
  autoconf \
  automake \
  make \
  gcc \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  libcurl4-gnutls-dev \
  libssl-dev \
  libncurses5-dev

RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 -O samtools.tar.bz2
RUN tar -xjvf samtools.tar.bz2
RUN cd samtools-1.3.1 && make && make prefix=/usr/local/bin install
RUN ln -s /usr/local/bin/bin/samtools /usr/bin/samtools

RUN wget https://github.com/samtools/bcftools/releases/download/1.3.1/bcftools-1.3.1.tar.bz2 -O bcftools.tar.bz2
RUN tar -xjvf bcftools.tar.bz2
RUN cd bcftools-1.3.1 && make && make prefix=/usr/local/bin install
RUN ln -s /usr/local/bin/bin/bcftools /usr/bin/bcftools

RUN apt-get install --yes cpanminus

RUN apt-get install --yes libxml-libxml-perl \
                          libxml-dom-xpath-perl \
                          libxml-libxml-simple-perl \
                          libxml-dom-perl

# install python3 and pip
RUN apt-get install -y --no-install-recommends \
      python3.5 \
      python3-pip \
      && apt-get clean && \
      rm -rf /var/lib/apt/lists/*

# install python dependecies
RUN pip install numpy
RUN pip install biopython
RUN pip install mirmap


# install R packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  && install2.r --error \
    vroom \
    cowplot \
    eulerr \
    ggvenn

## TargetScan Executables
RUN curl --output ./targetscan_70.zip https://www.targetscan.org/vert_80/vert_80_data_download/targetscan_70.zip
RUN unzip targetscan_70.zip
RUN chmod 777 targetscan_70.pl && ln -s targetscan_70.pl /bin
