if ( !isGeneric("w_gvec") ) {
  setGeneric("w_gvec", function(x, ...)
    standardGeneric("w_gvec"))
}

#' Write sf object to GRASS 7
#' @param x  \code{\link{sf}} object corresponding to the settings of the corresponding GRASS container
#' @param obj_name name of GRASS layer
#' @param gisdbase  GRASS gisDbase folder
#' @param location  GRASS location name containing \code{obj_name)}
#' @author Chris Reudenbach
#' 
#' @export w_gvec
#' @examples 
#'\dontrun{
#' ## example 
#' # get meuse data as sf object
#' require(sf)
#' require(sp)
#' data(meuse)
#' meuse_sf = st_as_sf(meuse, 
#'                    coords = c("x", "y"), 
#'                    crs = 28992, 
#'                    agr = "constant")
#'     
#' # write data to GRASS and create gisdbase
#' w_gvec(x = meuse_sf,
#'           obj_name = "meuse_R-G",
#'           gisdbase = "~/temp3",
#'           location = "project1")
#'  
#' # read from existing GRASS          
#' r_gvec(x = meuse_sf,
#'           obj_name = "meuse_R-G",
#'           gisdbase = "~/temp3",
#'           location = "project1")
#' }

w_gvec <- function(x, obj_name, gisdbase, location , gisdbase_exist=FALSE){
  
  if (gisdbase_exist)
    linkGRASS7(gisdbase = gisdbase, location = location, gisdbase_exist = TRUE)  
  else 
    linkGRASS7(x = x, gisdbase = gisdbase, location = location)  
  path <- Sys.getenv("GISDBASE")
  sq_name <- gsub(tolower(paste0(obj_name,".sqlite")),pattern = "\\-",replacement = "_")
  
  sf::st_write(x,file.path(path,sq_name),quiet = TRUE)
  
  ret <- try(rgrass7::execGRASS('v.import',  
                     flags  = c("overwrite", "quiet", "o"),
                     extent = "region",
                     input  = file.path(path,sq_name),
                     layer  = sq_name,
                     output = gsub(tolower(sq_name),pattern = "\\.",replacement = "_"),
                     ignore.stderr = TRUE,
                     intern = TRUE),silent = TRUE)

  if (class(ret) == "try-error")  return(cat("Data not found"))
}