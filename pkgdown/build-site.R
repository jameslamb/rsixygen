print("get work directory")
getwd()
install.packages(c("devtools","pkgdown"), repos = "https://cran.rstudio.com", type = "both")

devtools::document()

if (!dir.exists("./docs")) {
  dir.create("./docs")
}
print("========================building pkgdown site====================================")
#options(pkgdown.internet=FALSE)
pkgdown::build_site()
