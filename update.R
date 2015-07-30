stopifnot(Sys.info()["sysname"] == "Darwin")

library(miniCRAN)
options(repos = "http://cran.csie.ntu.edu.tw")
pkgs <- c("rappdirs")
download <- TRUE
pkgs.candidate <- pkgDep(pkgs)
for(type in c("source", "win.binary", "mac.binary", "mac.binary.mavericks")) {
  for(r.version in list(
    "3.1.1" = list(major="3", minor="1.1"), 
    "3.1.2" = list(major="3", minor="1.2"), 
    "3.2.1" = list(major="3", minor ="2.1"),
    "3.2.2" = list(major="3", minor ="2.2"))) {
    tmp <- R.version
    tmp$major <- r.version$major
    tmp$minor <- r.version$minor
    pkgs.current <- try(pkgAvail("gh-pages", type = type, Rversion = paste(tmp$major, tmp$minor, sep = ".")), silent = TRUE)
    if (class(pkgs.current) == "try-error") {
      pkgs.downloads <- pkgs.candidate
    } else {
      pkgs.avail <- available.packages(contrib.url(getOption("repos"), type = type))
      pkgs.existed <- intersect(pkgs.candidate, rownames(pkgs.current))
      pkgs.downloads <- c(
        setdiff(pkgs.candidate, rownames(pkgs.current))#,
        #pkgs.existed[which(package_version(pkgs.current[pkgs.existed, "Version"]) < package_version(pkgs.avail[pkgs.existed, "Version"]))])  
      )
    }
    makeRepo(pkgs.downloads, path = "gh-pages", download = download, type = type, Rversion = tmp)
  }
}

DSC2015R.version <- "0.2.1"
system("R CMD build DSC2015Tutorial/DSC2015R")
system(sprintf("R CMD INSTALL -l /tmp --build DSC2015R_%s.tar.gz", DSC2015R.version))
system(sprintf("7z a DSC2015R_%s.zip /tmp/DSC2015R", DSC2015R.version))
system('find "gh-pages" -name "*DSC2015R*" -exec rm {} \\;')
# system("R CMD build swirl")
# system("R CMD INSTALL -l /tmp --build swirl_2.3.1.tar.gz")
# system("7z a swirl_2.3.1.zip /tmp/swirl")
# system('find "gh-pages" -name "*swirl*" -exec rm {} \\;')
for(pkg in c(sprintf("DSC2015R_%s", DSC2015R.version))) {
  file.copy(sprintf("%s.tar.gz", pkg), "gh-pages/src/contrib/")
  file.copy(sprintf("%s.tgz", pkg), "gh-pages/bin/macosx/contrib/3.1")
  file.copy(sprintf("%s.tgz", pkg), "gh-pages/bin/macosx/contrib/3.2")
  file.copy(sprintf("%s.tgz", pkg), "gh-pages/bin/macosx/mavericks/contrib/3.1")
  file.copy(sprintf("%s.tgz", pkg), "gh-pages/bin/macosx/mavericks/contrib/3.2")
  file.copy(sprintf("%s.zip", pkg), "gh-pages/bin/windows/contrib/3.1")
  file.copy(sprintf("%s.zip", pkg), "gh-pages/bin/windows/contrib/3.2")  
}

current.wd <- getwd()
path.list <- c(
  "gh-pages/src/contrib",
  "gh-pages/bin/macosx/contrib/3.1",
  "gh-pages/bin/macosx/contrib/3.2",
  "gh-pages/bin/macosx/mavericks/contrib/3.1",
  "gh-pages/bin/macosx/mavericks/contrib/3.2",
  "gh-pages/bin/windows/contrib/3.1",
  "gh-pages/bin/windows/contrib/3.2"
  )
type.list <- c(
  "source",
  "mac.binary",
  "mac.binary",
  "mac.binary",
  "mac.binary",
  "win.binary",
  "win.binary"
  )
for(i in seq_along(path.list)) {
  print(path.list[i])
  setwd(path.list[i])
  tools::write_PACKAGES(dir = ".", type = type.list[i])
  setwd(current.wd)
}
  
