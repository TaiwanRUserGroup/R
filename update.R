library(miniCRAN)
options(repos = "http://cran.csie.ntu.edu.tw")
pkgs <- c("swirl", "dplyr", "ggplot2")
download <- TRUE
pkgs.candidate <- pkgDep(pkgs)
for(type in c("source", "win.binary", "mac.binary")) {
  for(r.version in list(
    "3.1.1" = list(major="3", minor="1.1"), 
    "3.1.2" = list(major="3", minor="1.2"), 
    "3.2.1" = list(major="3", minor ="2.1"),
    "3.2.2" = list(major="3", minor ="2.2"))) {
    tmp <- R.version
    tmp$major <- r.version$major
    tmp$minor <- r.version$minor
    pkgs.current <- pkgAvail(".", type = type, Rversion = paste(tmp$major, tmp$minor, sep = "."))
    pkgs.avail <- available.packages(contrib.url(getOption("repos"), type = type))
    pkgs.existed <- intersect(pkgs.candidate, rownames(pkgs.current))
    pkgs.downloads <- c(
      setdiff(pkgs.candidate, rownames(pkgs.current)),
      pkgs.existed[which(package_version(pkgs.current[pkgs.existed, "Version"]) < package_version(pkgs.avail[pkgs.existed, "Version"]))])
    makeRepo(pkgs.downloads, path = ".", download = download, type = type, Rversion = tmp)
  }
}

system("R CMD INSTALL -l /tmp swirl")
system("R CMD build swirl")
system("7z a swirl_2.3.1.zip /tmp/swirl")
file.copy("swirl_2.3.1.tar.gz", "src/contrib/")
file.copy("swirl_2.3.1.tgz", "bin/macosx/contrib/3.1")
file.copy("swirl_2.3.1.tgz", "bin/macosx/contrib/3.2")
file.copy("swirl_2.3.1.zip", "bin/windows/contrib/3.1")
file.copy("swirl_2.3.1.zip", "bin/windows/contrib/3.2")

current.wd <- getwd()
path.list <- c(
  "src/contrib",
  "bin/macosx/contrib/3.1",
  "bin/macosx/contrib/3.2",
  "bin/windows/contrib/3.1",
  "bin/windows/contrib/3.2"
  )
type.list <- c(
  "source",
  "mac.binary",
  "mac.binary",
  "win.binary",
  "win.binary"
  )
for(i in seq_along(path.list)) {
  setwd(path.list[i])
  tools::write_PACKAGES(dir = ".", type = type.list[i])
  setwd(current.wd)
}
  