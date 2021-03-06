% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/initControls.R
\name{getparams_GRASS4X}
\alias{getparams_GRASS4X}
\title{Get 'GRASS GIS' and \code{rgrass7} parameters on 'Linux' OS}
\usage{
getparams_GRASS4X(set_default_GRASS7 = NULL, MP = "/usr",
  ver_select = FALSE)
}
\arguments{
\item{set_default_GRASS7}{default = NULL will force a search for 'GRASS GIS' You may provide a valid combination as c("C:/OSGeo4W64","grass-7.0.5","osgeo4w")}

\item{MP}{mount point to be searched. default is "usr"}

\item{ver_select}{if TRUE you must interactivley selcect between alternative installations}
}
\description{
Initialize and set up \link{rgrass7}  for 'Linux'
}
\details{
During the rsession you will have full access to GRASS7 GIS via the \link{rgrass7} wrappe. Additionally you may use also use the API calls of GRASS7 via the command line.
}
\examples{
\dontrun{
# automatic retrieval of the GRASS7 enviroment settings
getparams_GRASS4X()

# typical stand_alone installation
getparams_GRASS4X("/usr/bin/grass72")

# typical user defined installation (compiled sources)
getparams_GRASS4X("/usr/local/bin/grass72")
}
}
