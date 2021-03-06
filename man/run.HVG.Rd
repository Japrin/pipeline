% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sc.utils.R
\name{run.HVG}
\alias{run.HVG}
\title{Wraper for highly variable genes finding}
\usage{
run.HVG(seu, gene.exclude.df, n.top = 1500, measurement = "counts")
}
\arguments{
\item{seu}{object of \code{Seurat}}

\item{gene.exclude.df}{data.frame; gene blak list. Required column: seu.id.}

\item{n.top}{integer; number of top genes. (default: 1500)}

\item{measurement}{character; "counts", "TPM" or "cpm". (default: "counts")}
}
\value{
a Seurat object
}
\description{
Wraper for highly variable genes finding
}
