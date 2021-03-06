% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sc.intClust.R
\name{make.geneTableLong}
\alias{make.geneTableLong}
\title{make a long type gene table, given a SingleCellExperiment object}
\usage{
make.geneTableLong(obj, out.prefix, th.adj.P = 0.01, th.dprime = 0.15)
}
\arguments{
\item{obj}{object of \code{SingleCellExperiment} class}

\item{out.prefix}{output prefix}

\item{th.adj.P}{double; threshold for adjusted p-value. (default: 0.01)}

\item{th.dprime}{double; threshold for dprime. (default: 0.15)}
}
\description{
make a long type gene table, given a SingleCellExperiment object
}
