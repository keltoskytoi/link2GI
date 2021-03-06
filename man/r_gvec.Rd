% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/r_gvec.R
\name{r_gvec}
\alias{r_gvec}
\title{Read GRASS 7 vector into  sf object}
\usage{
r_gvec(x, obj_name, gisdbase, location, gisdbase_exist = TRUE)
}
\arguments{
\item{x}{\code{\link{sf}} object corresponding to the settings of the corresponding GRASS container}

\item{obj_name}{name of GRASS layer}

\item{gisdbase}{GRASS gisDbase folder}

\item{location}{GRASS location name containing \code{obj_name)}}
}
\description{
Read GRASS 7 vector into  sf object
}
\examples{
\dontrun{
## example 
# get meuse data as sf object
require(sf)
meuse_sf = st_as_sf(meuse, 
                   coords = c("x", "y"), 
                   crs = 28992, 
                   agr = "constant")
    

# write data to GRASS and create gisdbase
w_gvec(x = meuse_sf,
          obj_name = "meuse_R-G",
          gisdbase = "~/temp3",
          location = "project1")
 
# read from existing GRASS          
r_gvec(x = meuse_sf,
          obj_name = "meuse_R-G",
          gisdbase = "~/temp3",
          location = "project1")
}
}
\author{
Chris Reudenbach
}
