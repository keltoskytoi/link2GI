
#'@title Search for valid Win SAGA installation(s)
#'@name searchSAGA4W
#'@description  Search for valid SAGA installation(s) on a given Windows drive 
#'@param DL drive letter default is "C:"
#'@return a dataframe with the SAGA root folder, the version name and the installation type
#'@author Chris Reudenbach
#'@export searchSAGA4W
#'
#'@examples
#' \dontrun{
#'#### Examples how to use searchSAGA4W 
#'
#' # get all valid SAGA installation folders and params
#' sagaParams<- searchSAGA4W()
#' }

searchSAGA4W <- function(DL = "C:"){
  # check if running on a HRZMR Pool PC
  sagaPath <- checkPCRZP("saga")  
  if (is.null(sagaPath)) {
    # trys to find a osgeo4w installation on the whole C: disk returns root directory and version name
    # recursive dir for saga_cmd.exe returns all version of otb bat files
    cat("\nsearching for SAGA installations - this may take a while\n")
    cat("Alternatively you can provide a path like: C:\\OSGeo4W64\\bin\\\n")
    cat("You can also provide a installation type like: 'osgeo4w64'\n")
    
    # for a straightforward use of a correct codetable using the cmd command "dir" is used
    rawSAGA <- system(paste0("cmd.exe /c dir /B /S ",DL,"\\","saga_cmd.exe"),intern = TRUE)
    
    # trys to identify valid SAGA GIS installation(s) & version number(s)
    sagaPath <- lapply(seq(length(rawSAGA)), function(i){
      cmdfileLines <- rawSAGA[i]
      installerType <- ""
      # if the the tag "OSGEO4W" exists set installationType
      if (length(unique(grep(paste("OSGeo4W64", collapse = "|"), rawSAGA[i], value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("OSGeo4W64", collapse = "|"), rawSAGA[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "saga_cmd.exe", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "osgeo4w64SAGA"
      }    
      
      # if the the tag "OSGEO4W" exists set installationType
      else if (length(unique(grep(paste("OSGeo4W", collapse = "|"), rawSAGA[i], value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("OSGeo4W", collapse = "|"), rawSAGA[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "saga_cmd.exe", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "osgeo4wSAGA"
      }
      # if the the tag "QGIS" exists set installationType
      else if (length(unique(grep(paste("QGIS", collapse = "|"), rawSAGA[i], value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("QGIS", collapse = "|"), rawSAGA[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "saga_cmd.exe", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "qgisSAGA"
      }
      else{
        rootDir <- substr(rawSAGA[i],1, gregexpr(pattern = "saga_cmd.exe", rawSAGA[i])[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "userSAGA"
      }
      
      # put the result in a data frame
      data.frame(binDir = rootDir, baseDir = installDir, installationType = installerType,stringsAsFactors = FALSE)
      
    }) # end lapply
    
    # bind df 
    sagaPath <- do.call("rbind", sagaPath)
    
  }
  
  return(sagaPath)
}

#'@title Initialize the enviroment variables on a Windows OS
#'@name getGrassParams4W
#'@description Initialize the enviroment variables on a Windows OS for using 
#'  GRASS via \link{rgrass7}
#'@details The concept is very straightforward but for an all days usage pretty
#'  helpful. You need to provide a GDAL conform raster file, a \link{raster}
#'  object. This settings will be used to initialize a temporary but static
#'  \href{https://CRAN.R-project.org/package=rgrass7}{rgrass7} environment. During the rsession you will have full access to
#'  GRASS7 via the wrapper packages. .
#'@param DL raster or sp object
#'@param setDefaultGrass default = NULL wil force a search for GRASS You may
#'  provide a valid combination as c("C:\\OSGeo4W64","grass-7.0.5","osgeo4w")
#'@return getGrassParams4W initializes the usage of GRASS7.
#'@export getGrassParams4W
#'  
#'@examples
#' \dontrun{
#' # automatic retrieval of valid GRASS environment settings 
#' # if more than one is found the user has to choose.
#' getGrassParams4W()
#' 
#' # typical standalone installation
#' getGrassParams4W(c("C:\\Program Files\\GRASS GIS 7.0.5","GRASS GIS 7.0.5","NSIS"))
#' 
#' # typical OSGeo4W64 installation
#' getGrassParams4W(c("C:\\OSGeo4W64","grass-7.0.5","osgeo4W"))
#' }

getGrassParams4W <- function(setDefaultGrass=NULL, DL="C:"){
  
  # (R) set pathes  of GRASS  binaries depending on OS WINDOWS
  if (is.null(setDefaultGrass)) {
    
    # if no path is provided  we have to search
    grassParams <- searchOSgeo4WGrass(DL = DL)
    
    # if just one valid installation was found take it
    if (nrow(grassParams) == 1) {  
      grass.gis.base <- setGrassEnv4W(grassRoot = setDefaultGrass[1], 
                                      grassVersion = setDefaultGrass[2], 
                                      installationType = setDefaultGrass[3])
      
      # if more than one valid installation was found you have to choose 
    } else if (nrow(grassParams) > 1) {
      cat("You have more than one valid GRASS version\n")
      print(grassParams)
      cat("\n")
      ver <- as.numeric(readline(prompt = "Please choose one:  "))
      grass.gis.base <- setGrassEnv4W(grassRoot = grassParams$instDir[[ver]],
                                    grassVersion = grassParams$version[[ver]], 
                                    installationType = grassParams$installationType[[ver]] )
    }
    
    # if a setDefaultGrass was provided take this 
  } else {
    grass.gis.base <- setGrassEnv4W(grassRoot = setDefaultGrass[1],
                                    grassVersion = setDefaultGrass[2], 
                                    installationType = setDefaultGrass[3])  
  }
  return(grass.gis.base)
}



#'@title Search for valid OSGeo4W GRASS installation(s) on a given Windows drive 
#'@name searchOSgeo4WGrass
#'@title Search for valid OSGeo4W GRASS installation(s) on a given Windows drive 
#'@description  Provides an  estimation of valid GRASS installation(s) on your Windows system. There is a major difference between osgeo4W and standalone installations. The functions trys to find all valid installations by analysing the calling batch scripts.
#'@param DL drive letter to be searched, default is "C:"
#'@return dataframe with the GRASS root dir, version name and installation type code word
#'@author Chris Reudenbach
#'@export searchOSgeo4WGrass
#'
#'@examples
#' \dontrun{
#' # get all valid GRASS installation folders and params on WindowsOS
#' grassParam<- searchOSgeo4WGrass()
#' }

searchOSgeo4WGrass <- function(DL = "C:"){
  # trys to find a osgeo4w installation on the whole C: disk returns root directory and version name
  # recursive dir for grass*.bat returns all version of grass bat files
  rawGRASS <- system(paste0("cmd.exe /c dir /B /S ", DL, "\\grass*.bat"), intern = T)
  
  # trys to identify valid grass installation(s) & version number(s)
  grassInstallations <- lapply(seq(length(rawGRASS)), function(i){
    # convert codetable according to cmd.exe using type
    batchfileLines <- system(paste0("cmd.exe /c TYPE \"", rawGRASS[i], "\""), 
                             ignore.stdout = TRUE, intern = T)
    osgeo4w <- FALSE
    standAlone <- FALSE
    rootDir <- ''
    
    # if the the tag "OSGEO4W" exists set installationType
    if (length(unique(grep(paste("OSGEO4W", collapse = "|"), batchfileLines, value = TRUE))) > 0) {
      osgeo4w <- TRUE
      standAlone <- FALSE
    }
    # if the the tag "NSIS installer" exists set installationType
    if (length(unique(grep(paste("NSIS installer", collapse = "|"), batchfileLines, value = TRUE))) > 0) {
      osgeo4w <- FALSE
      standAlone <- TRUE
    }
    
    ### if installationType is osgeo4w
    if (osgeo4w) {
      # grep line with root directory and extract the substring defining GISBASE
      rootDir <- unique(grep(paste("SET OSGEO4W_ROOT=", collapse = "|"), batchfileLines, value = TRUE))
      if (length(rootDir) > 0) rootDir <- substr(rootDir, gregexpr(pattern = "=", rootDir)[[1]][1] + 1, nchar(rootDir))
      
      # grep line with the version name and extract it
      verChar <- unique(grep(paste("\\benv.bat\\b", collapse = "|"), batchfileLines,value = TRUE))
      if (length(rootDir) > 0) {
        verChar <- substr(verChar, gregexpr(pattern = "\\grass-", verChar)[[1]][1], nchar(verChar))
        verChar <- substr(verChar, 1, gregexpr(pattern = "\\\\", verChar)[[1]][1] - 1)
      }
      installerType <- "osgeo4W"
    }
    
    ### if installatationtype is standalone
    if (standAlone) {
      # grep line containing GISBASE and extract the substring 
      rootDir <- unique(grep(paste("set GISBASE=", collapse = "|"), batchfileLines, value = TRUE))
      if (length(rootDir) > 0) rootDir <- substr(rootDir, gregexpr(pattern = "=", rootDir)[[1]][1] + 1, nchar(rootDir))
      verChar <- rootDir
      if (length(rootDir) > 0) {
        verChar <- substr(verChar, gregexpr(pattern = "GRASS", verChar)[[1]][1], nchar(verChar))
      }
      installerType <- "NSIS"
    }
    
    # check if the the folder really exists
    if (length(rootDir) > 0) {
      if (!file.exists(file.path(rootDir))) {
        exist <- FALSE
      } else {
        exist <- TRUE
      } 
    } else {
      exist <- FALSE
    }
    
    # put the existing GISBASE directory, version number  and installation type in a data frame
    if (length(rootDir) > 0 & exist) {
      data.frame(instDir = rootDir, version = verChar, installationType = installerType,stringsAsFactors = FALSE)
    }
  }) # end lapply
  
  # bind the df lines
  grassInstallations <- do.call("rbind", grassInstallations)
  
  return(grassInstallations)
}

#'@title Initialize and set up \link{rgrass7}  for Linux
#'@name getGrassParams4X
#'@description Initialize and set up \link{rgrass7}  for Linux
#'@details During the rsession you will have full access to GRASS7 GIS via the \link{rgrass7} wrappe. Additionally you may use also use the CLI calls of GRASS7.
#'@param setDefaultGrass default = NULL wil force a search for GRASS You may provide a valid combination as c("C:\\OSGeo4W64","grass-7.0.5","osgeo4w")
#'@param MP mount point to be searched. default is "usr"
#'@return getGrassParams4X initializes the usage of GRASS7.
#'@export getGrassParams4X
#'
#'@examples
#' \dontrun{
#' # automatic retrieval of the GRASS7 enviroment settings
#' getGrassParams4X()
#' 
#' # typical standalone installation
#' getGrassParams4X("/usr/bin/grass72")
#' 
#' # typical user defined installation (compiled sources)
#' getGrassParams4X("/usr/local/bin/grass72")
#' }

getGrassParams4X <- function(setDefaultGrass=NULL, MP = "/usr"){
  
  # (R) set pathes  of GRASS  binaries depending on OS WINDOWS
  if (is.null(setDefaultGrass)) {
    
    # if no path is provided  we have to search
    grassParams <- searchGRASSX(MP = MP)
    
    # if just one valid installation was found take it
    if (nrow(grassParams) == 1) {  
      grass.gis.base <- grassParams$instDir
      
      # if more than one valid installation was found you have to choose 
    } else if (nrow(grassParams) > 1) {
      cat("You have more than one valid GRASS version\n")
      print(grassParams)
      cat("\n")
      ver <- as.numeric(readline(prompt = "Please choose one:  "))
      grass.gis.base <- grassParams$instDir[[ver]]
    }
    
    # if a setDefaultGrass was provided take this 
  } else {
    grass.gis.base <- setDefaultGrass
  }
  return(grass.gis.base)
}

#'@title Search for valid GRASS installations at a given Linux mount point
#'@name searchGRASSX
#'@description Search for valid GRASS installations at a given Linux mount point
#'@param MP default is /usr
#'@return dataframe containing GRASS binary dir(s), version name(s) and installation type code(s)
#'@author Chris Reudenbach
#'@export searchGRASSX
#'
#'@examples
#' \dontrun{
#' # get all valid GRASS installation folders in the /usr directory (typical location)
#' grassParam<- searchGRASSX("~/")
#' 
#' # get all valid GRASS installation folders in the home directory
#' grassParam<- searchGRASSX("~/")
#' }

searchGRASSX <- function(MP = "/usr"){
  rawGRASS <- system2("find", paste(MP," ! -readable -prune -o -type f -executable -iname 'grass??' -print"),stdout = TRUE)
  if (length(rawGRASS) > 0) {
    grassInstallations <- lapply(seq(length(rawGRASS)), function(i){
      # grep line containing GISBASE and extract the substring 
      rootDir <- grep(readLines(rawGRASS),pattern = 'isbase = "',value = TRUE)
      rootDir <- substr(rootDir, gregexpr(pattern = '"', rootDir)[[1]][1] + 1, nchar(rootDir) - 1)
      verChar <- grep(readLines(rawGRASS),pattern = 'grass_version = "',value = TRUE)
      verChar <- substr(verChar, gregexpr(pattern = '"', verChar)[[1]][1] + 1, nchar(verChar) - 1)
      cmd <- grep(readLines(rawGRASS),pattern = 'cmd_name = "',value = TRUE)
      cmd <- substr(cmd, gregexpr(pattern = '"', cmd)[[1]][1] + 1, nchar(cmd) - 1)
      
      # put it in data frame
      data.frame(instDir = rootDir, version = verChar, cmd = cmd , stringsAsFactors = FALSE)
    }) # end lapply
    
    # bind the df lines
    grassInstallations <- do.call("rbind", grassInstallations)
    return(grassInstallations)
  } else {
    warning(paste("Did not find any valid GRASS installation at mount point",MP))
    return(grassInstallations <- NULL)
  }
}



#'@title Initializes and set up  access to GRASS7 via the \link{rgrass7} wrapper or command line packages
#'@name setGrassEnv4W
#'@description  Initializes and set up  access to GRASS7 via the \link{rgrass7} wrapper or command line packages
#'@param grassRoot  grass root directory i.e. "C:\\OSGEO4~1",
#'@param grassVersion grass version name i.e. "grass-7.0.5"
#'@param installationType two options "osgeo4w" and "NSIS"
#'@param jpgmem jpeg2000 memory allocation size. Default is 1000000
#'@return set all enviroment variables and additionally returns the GISBASE 
#'@author Chris Reudenbach
#'@export setGrassEnv4W
#'
#'@examples
#' \dontrun{
#' # get all valid GRASS installation folders and params
#' grassParam<- setGrassEnv4W()
#' }

setGrassEnv4W <- function(grassRoot="C:\\OSGEO4~1",
                          grassVersion = "grass-7.0.5",
                          installationType = "osgeo4w",
                          jpgmem = 1000000){
  if (!exists(.GiEnv)) .GiEnv <- globalenv()  
  #.GRASS_CACHE <- new.env(FALSE parent=globalenv())
  if (installationType == "osgeo4w") {
    Sys.setenv(OSGEO4W_ROOT = grassRoot)
    # define GISBASE
    grass.gis.base <- paste0(grassRoot,"\\apps\\grass\\",grassVersion)
    Sys.setenv(GISBASE = grass.gis.base,envir = .GiEnv)
    assign("SYS", "WinNat", envir = .GiEnv)
    assign("addEXE", ".exe", envir = .GiEnv)
    assign("WN_bat", "", envir = .GiEnv)
    assign("legacyExec", "windows", envir = .GiEnv)
    
    
    Sys.setenv(GRASS_PYTHON = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\bin\\python.exe"),envir = .GiEnv)
    Sys.setenv(PYTHONHOME = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\apps\\Python27"),envir = .GiEnv)
    Sys.setenv(PYTHONPATH = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\apps\\grass\\",grassVersion,"\\etc\\python"),envir = .GiEnv)
    Sys.setenv(GRASS_PROJSHARE = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\proj"),envir = .GiEnv)
    Sys.setenv(PROJ_LIB = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\proj"),envir = .GiEnv)
    Sys.setenv(GDAL_DATA = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\gdal"),envir = .GiEnv)
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
    Sys.setenv(FONTCONFIG_FILE = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\etc\\fonts.conf"),envir = .GiEnv)
    Sys.setenv(JPEGMEM = jpgmem,envir = .GiEnv)
    Sys.setenv(FONTCONFIG_FILE = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\bin\\gdalplugins"),envir = .GiEnv)
    Sys.setenv(GISRC = paste(Sys.getenv("HOME"), "\\.grassrc7",  sep = ""),envir = .GiEnv)
    
    # set path variable
    Sys.setenv(PATH = paste0(grass.gis.base,";",
                           grassRoot,"\\apps\\Python27\\lib\\site-packages\\numpy\\core",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\bin",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\lib",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\etc",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\etc\\python",";",
                           grassRoot,"\\apps\\Python27\\Scripts",";",
                           grassRoot,"\\bin",";",
                           grassRoot,"\\apps",";",
                           paste0(Sys.getenv("WINDIR"),"/WBem"),";",
                           Sys.getenv("PATH")),envir = .GiEnv)
    
    # get list of all tools
    system(paste0(grassRoot,"/bin/o-help.bat"))
    
  } 
  # for the NSIS windows installer versions
  else {
    
    Sys.setenv(GRASS_ROOT = grassRoot)
    # define GISBASE
    grass.gis.base <- grassRoot
    Sys.setenv(GISBASE = grass.gis.base,envir = .GiEnv)
    assign("SYS", "WinNat", envir = .GiEnv)
    assign("addEXE", ".exe", envir = .GiEnv)
    assign("WN_bat", "", envir = .GiEnv)
    assign("legacyExec", "windows", envir = .GiEnv)
    
    
    Sys.setenv(GRASS_PYTHON = paste0(Sys.getenv("GRASS_ROOT"),"\\bin\\python.exe"),envir = .GiEnv)
    Sys.setenv(PYTHONHOME = paste0(Sys.getenv("GRASS_ROOT"),"\\apps\\Python27"),envir = .GiEnv)
    Sys.setenv(PYTHONPATH = paste0(Sys.getenv("GRASS_ROOT"),"\\apps\\grass\\",grassVersion,"\\etc\\python"),envir = .GiEnv)
    Sys.setenv(GRASS_PROJSHARE = paste0(Sys.getenv("GRASS_ROOT"),"\\share\\proj"),envir = .GiEnv)
    Sys.setenv(PROJ_LIB = paste0(Sys.getenv("GRASS_ROOT"),"\\share\\proj"),envir = .GiEnv)
    Sys.setenv(GDAL_DATA = paste0(Sys.getenv("GRASS_ROOT"),"\\share\\gdal"),envir = .GiEnv)
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("GRASS_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
    Sys.setenv(FONTCONFIG_FILE = paste0(Sys.getenv("GRASS_ROOT"),"\\etc\\fonts.conf"),envir = .GiEnv)
    Sys.setenv(JPEGMEM = jpgmem,envir = .GiEnv)
    Sys.setenv(FONTCONFIG_FILE = paste0(Sys.getenv("GRASS_ROOT"),"\\bin\\gdalplugins"),envir = .GiEnv)
    Sys.setenv(GISRC = paste(Sys.getenv("HOME"), "\\.grassrc7",  sep = ""),envir = .GiEnv)
    
    # set path variable
    Sys.setenv(PATH = paste0(grass.gis.base,";",
                           grassRoot,"\\apps\\Python27\\lib\\site-packages\\numpy\\core",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\bin",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\lib",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\etc",";",
                           grassRoot,"\\apps\\grass\\",grassVersion,"\\etc\\python",";",
                           grassRoot,"\\apps\\Python27\\Scripts",";",
                           grassRoot,"\\bin",";",
                           grassRoot,"\\apps",";",
                           paste0(Sys.getenv("WINDIR"),"/WBem"),";",
                           Sys.getenv("PATH")),envir = .GiEnv)
    
  }
  
  return(grass.gis.base)
}


#'@title  Initializes and set up  access to the OTB command line interface 
#'@name setOTBEnv
#'@description  Initializes and set up  access to the OTB command line interface  
#'
#'@param binPathOtb  string contains path to otb binaries
#'@param rootPathOtb string contains the full string to call otb launcher
#'
#'@return 
#' add otb pathes to the enviroment and creates global variables otbCmd
#' @export setOTBEnv 
#'
#'@examples
#' \dontrun{
#'## call it for a default OSGeo4W64 oinstallation of SAGA
#'setOTBEnv()
#'}

setOTBEnv <- function(binPathOtb = NULL, rootPathOtb = NULL){
  # check if running on a HRZMR Pool PC
  binPathOtb <- checkPCRZP("otb")   
  if (substr(Sys.getenv("COMPUTERNAME"),1,5) == "PCRZP") {
    binPathOtb <- shQuote("C:\\Program Files\\QGIS 2.14\\bin")
    installationRoot <- shQuote("C:\\Program Files\\QGIS 2.14")
    
    if (!exists(.GiEnv)) .GiEnv <- globalenv()  
    
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
  } else {
    # (R) set pathes  of otb modules and binaries depending on OS  
    if (Sys.info()["sysname"] == "Windows") {
      makGlobalVar("otbPath", binPathOtb)
      add2Path(binPathOtb)
      Sys.setenv(OSGEO4W_ROOT = installationRoot)
      Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
    } else {
      makGlobalVar("otbPath", "(usr/bin/")
    }
  }
  return(binPathOtb)
}

#'@title Search for valid OTB installations on a Windows OS
#'@name searchOSgeo4WOTB
#'@description  Search for valid OTB installations on your Windows system
#'@param DL drive letter default is "C:"
#'@return a dataframe with the OTB root dir the Version name and the installation type
#'@author Chris Reudenbach
#'@export searchOSgeo4WOTB
#'
#'@examples
#' \dontrun{
#'#### Examples how to use RSAGA and OTB bindings from R
#'
#' # get all valid OTB installation folders and params
#' otbParam<- searchOSgeo4WOTB()
#' }

searchOSgeo4WOTB <- function(DL = "C:") {
  if (!exists(.GiEnv)) .GiEnv <- globalenv()  
  if (substr(Sys.getenv("COMPUTERNAME"),1,5) == "PCRZP") {
    defaultOtb <- shQuote("C:\\Program Files\\QGIS 2.14\\bin")
    otbInstallations <- data.frame(instDir = shQuote("C:\\Program Files\\QGIS 2.14\\bin"), installationType = "osgeo4wOTB",stringsAsFactors = FALSE)
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
  } else {
    # trys to find a osgeo4w installation on the whole C: disk returns root directory and version name
    # recursive dir for otb*.bat returns all version of otb bat files
    cat("\nsearching for OTB installations - this may take a while\n")
    cat("Alternatively you can provide a path like: C:\\OSGeo4W64\\bin\\\n")
    cat("You can also provide a installation type like: 'osgeo4w64OTB'\n")
    rawOTB <- system(paste0("cmd.exe /c dir /B /S ",DL,"\\","otbcli.bat"),intern = TRUE)
    
    # trys to identify valid otb installations and their version numbers
    otbInstallations <- lapply(seq(length(rawOTB)), function(i){
      # convert codetable according to cmd.exe using type
      batchfileLines <- rawOTB[i]
      installerType <- ""
      # if the the tag "OSGEO4W" exists set installationType
      if (length(unique(grep(paste("OSGeo4W64", collapse = "|"), rawOTB[i], value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("OSGeo4W64", collapse = "|"), rawOTB[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "otbcli.bat", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "osgeo4w64OTB"
      }    
      
      # if the the tag "OSGEO4W" exists set installationType
      else if (length(unique(grep(paste("OSGeo4W", collapse = "|"), rawOTB[i], value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("OSGeo4W", collapse = "|"), rawOTB[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "otbcli.bat", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "osgeo4wOTB"
      }
      # if the the tag "QGIS" exists set installationType
      else if (length(unique(grep(paste("QGIS", collapse = "|"), batchfileLines, value = TRUE))) > 0) {
        rootDir <- unique(grep(paste("QGIS", collapse = "|"), rawOTB[i], value = TRUE))
        rootDir <- substr(rootDir,1, gregexpr(pattern = "otbcli.bat", rootDir)[[1]][1] - 1)
        installDir <- substr(rootDir,1, gregexpr(pattern = "bin", rootDir)[[1]][1] - 2)
        installerType <- "qgisOTB"
      }
      # put the existing GISBASE directory, version number  and installation type in a data frame
      data.frame(binDir = rootDir, baseDir = installDir, installationType = installerType, stringsAsFactors = FALSE)
    }) # end lapply
    # bind the df lines
    otbInstallations <- do.call("rbind", otbInstallations)
  }
  return(otbInstallations)
}



#'@title Checks if x is a raster or sp object
#'@name getClass
#'@description  Checks if x is a raster or sp object
#'@param obj R raster* or sp object
#'@author Chris Reudenbach
#'@examples
#' \dontrun{
#' # add path
#' getClass(x)
#' }
#'@export getClass
getClass <- function(obj) {
  if (class(obj) %in% c("RasterLayer", "RasterStack",
                        "RasterBrick", "Satellite",
                        "SpatialGridDataFrame",
                        "SpatialPixelsDataFrame")) {"rst"} 
  else if (class(obj) %in% c("SpatialPointsDataFrame", "SpatialPoints",
                             "SpatialPolygonsDataFrame",
                             "SpatialPolygons",
                             "SpatialLinesDataFrame",
                             "SpatialLines")) {"vec"}
}

#'@title Checks if the computer belongs to the Marburg Universitys computer domain
#'@name checkPCRZP
#'@description  Checks if the computer belongs to the Marburg Universitys computer pools
#'@param cliCode code of the sofware currently "saga" and "otb" are supported
#'@param prefixPC name of PC
#'@author CR
#'@examples
#' \dontrun{
#' # add path
#' checkPCRZP("saga",prefixPC="PCRZP")
#' }
#'@export checkPCRZP
checkPCRZP <- function(cliCode=NULL, prefixPC="PCRZP") {
  if (!exists(.GiEnv)) .GiEnv <- globalenv()  
  if (substr(Sys.getenv("COMPUTERNAME"),1,5) == substr(prefixPC,1,5)) {
    if (cliCode == "saga") { 
      defaultSAGA <- shQuote(c("C:\\Program Files\\QGIS 2.14\\apps\\saga","C:\\Program Files\\QGIS 2.14\\apps\\saga\\modules"))
      return(defaultSAGA)
    } else {
      return(defaultSAGA = NULL)  
    }
  } else if (cliCode == "otb") {
    defaultOtb <- shQuote("C:\\Program Files\\QGIS 2.14\\bin")
    installationRoot <- shQuote("C:\\Program Files\\QGIS 2.14")
    Sys.setenv(GEOTIFF_CSV = paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"),envir = .GiEnv)
    otbInstallations <- data.frame(instDir = shQuote("C:\\Program Files\\QGIS 2.14\\bin"), installationType = "osgeo4wOTB", stringsAsFactors = FALSE)
    return(otbInstallations)
  }
  
  
}

#'@title Adds a defined variable and value to the global search path
#'@name add2Path
#'@description  Adds a variable to the global search path of the current environment
#'@param newPath the path that is added
#'@author Chris Reudenbach
#'@examples
#' \dontrun{
#' # add path
#' addPath("pathtosomewhere")
#' }
#'@export add2Path
#'
add2Path <- function(newPath) {
  exist <- FALSE
  if (Sys.info()["sysname"] == "Windows") {
    del <- ";"  
  } else {
    del <- ":"  
  } 
  p <- Sys.getenv("PATH")
  if (substr(p, 1,nchar(newPath)) == newPath) {
    exist <- TRUE
  }
  # if not exist append path to systempath
  if (!exist) {
    Sys.setenv(PATH = paste0(newPath,del,Sys.getenv("PATH")))
  }
}

#'@title Generates a variable with a certain value in the R environment
#'@name makGlobalVar
#' @description  Generates a variable with a certain value in the R environment
#' @param name character string name of the variable
#' @param value character string value of the variable
#'@export makGlobalVar 
#'@examples
#' \dontrun{
#'
#' # creates the global var \code{pathToData} with the value \code{~/home/data}
#' makGlobalVar("pathToData","~/home/data") 
#' 
#' }
#' 
makGlobalVar <- function(name,value) {
  if (!exists(.GiEnv)) .GiEnv <- globalenv()  
  if (exists(name, envir = .GiEnv)) {
    #warning(paste0("The variable '", name,"' already exist in .GlobalEnv"))
    assign(name, value, envir = .GiEnv, inherits = TRUE)
    #cat("add variable ",name,"=",value," to global .GiEnv\n")
  } else {
    assign(name, value, envir = .GiEnv, inherits = TRUE)
    #cat("add variable ",name,"=",value," to global .GiEnv\n")
  } 
}