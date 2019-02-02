### install regular packages

install.packages("devtools")
install.packages("reticulate") # python support in RMarkdown
install.packages("ggplot2") # for plotting
install.packages(c("rmarkdown", "caTools", "bitops")) # for knitting
install.packages(c('DT', 'ROCR', 'caTools', 'lubridate', 'rjson', 'littler', 'docopt', 'formatR', 'remotes', 'selectr'))   # dependencies=TRUE # used for modelling
install.packages(c("biomod2"), dependencies=TRUE )

### install GitHub packages (tag = commit, branch or release tag)

# devtools::install_github("user/repo", ref = "tag")

### install bioconductor packages
# install.packages("BiocManager")
# BiocManager::install("package")
