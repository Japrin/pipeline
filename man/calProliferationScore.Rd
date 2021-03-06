% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sc.utils.R
\name{calProliferationScore}
\alias{calProliferationScore}
\title{calculate the proliferation score}
\usage{
calProliferationScore(
  obj,
  gene.prol,
  assay.name = "norm_exprs",
  out.prefix = NULL,
  method = "mean"
)
}
\arguments{
\item{obj}{object of \code{SingleCellExperiment}}

\item{gene.prol}{character vector; genes to use.}

\item{assay.name}{character vector; which assay to use. (default: "norm_exprs").}

\item{out.prefix}{character; output prefix. (default: NULL)}

\item{method}{character; method to use. (default: "mean").}
}
\value{
a list
}
\description{
calculate the proliferation score
}
\details{
calculate the proliferation score.
}
