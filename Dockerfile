# -*- mode: ruby -*-
# vi: set ft=ruby :

# DEPRECIATED docker build -t amasing-binder .
# docker build -t amasing-binder-papermill .
# SAVE THE IMAGE
# docker save amasing-binder-papermill > amasing-binder-papermill.tar
# EXPORT CONTAINER
# docker export amasing-binder > amasing-binder.tar


FROM rocker/geospatial:3.5.2

ENV NB_USER rstudio
ENV NB_UID 1000
ENV VENV_DIR /srv/venv

# Set ENV for all programs...
ENV PATH ${VENV_DIR}/bin:$PATH
# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron

# The `rsession` binary that is called by nbrsessionproxy to start R doesn't seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && \
    apt-get -y install python3-venv python3-dev libgsl-dev && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a venv dir owned by unprivileged user & set up notebook in it
# This allows non-root to install python libraries if required
RUN mkdir -p ${VENV_DIR} && chown -R ${NB_USER} ${VENV_DIR}

USER ${NB_USER}


RUN python3 -m venv ${VENV_DIR} && \
    # Explicitly install a new enough version of pip
    pip3 install pip==9.0.1 && \
    pip3 install --no-cache-dir \
         nbrsessionproxy==0.6.1 && \
    jupyter serverextension enable --sys-prefix --py nbrsessionproxy && \
    jupyter nbextension install    --sys-prefix --py nbrsessionproxy && \
    jupyter nbextension enable     --sys-prefix --py nbrsessionproxy


RUN R --quiet -e "devtools::install_github('IRkernel/IRkernel')" && \
    R --quiet -e "IRkernel::installspec(prefix='${VENV_DIR}')" && \
    R --quiet -e "install.packages('devtools')" && \
    # python support in RMarkdown
    R --quiet -e "install.packages('reticulate')" && \
    # for plotting
    R --quiet -e "install.packages('ggplot2')" && \
    # for knitting
    R --quiet -e "install.packages(c('rmarkdown', 'caTools', 'bitops'))"  && \
    # dependencies=TRUE # used for modelling
    R --quiet -e "install.packages(c('DT', 'ROCR', 'caTools', 'lubridate', 'rjson', 'littler', 'docopt', 'formatR', 'remotes', 'selectr'))"

RUN R --quiet -e "install.packages(c('biomod2'), dependencies=TRUE )"

## Run an install.R script, if it exists.
#RUN if [ -f install.R ]; then R --quiet -f install.R; fi

RUN python3 -m venv ${VENV_DIR} && \
   pip3 install papermill

RUN R --quiet -e "devtools::install_github('nteract/papermillr')"

RUN pip3 install ipywidgets pandas && \
   jupyter nbextension enable --py widgetsnbextension 

CMD jupyter notebook --ip 0.0.0.0


## If extending this image, remember to switch back to USER root to apt-get
