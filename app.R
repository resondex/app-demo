# =============================================================================
# Posit Connect Cloud — Network Drivers demo app
#
# Loads a pre-built Shiny app object (serialized via work::app_deliverable()
# at build time) and serves it. The `library()` calls below exist so
# rsconnect::writeManifest() can statically detect every runtime package
# this deploy needs. WITHOUT them, the .R file looks like a 2-line stub
# (readRDS + return) and the manifest captures only shiny's transitive
# deps, leaving the deserialized closures unable to find their work::*
# references at runtime.
#
# We DON'T `library(work)` here — work has ~60 Imports including heavy
# / cloud / scraping packages this app doesn't need at runtime. Instead
# we list only the runtime deps explicitly + ensure `work` itself is
# installed via requireNamespace. Connect Cloud's package install step
# then only fetches what's actually needed.
# =============================================================================

# ---- Shiny shell ----
library(shiny)
library(bslib)
library(shinyjs)
library(htmltools)
library(htmlwidgets)

# ---- Tables (impact + prio + membership reactables) ----
library(reactable)

# ---- Network maps + charts ----
library(visNetwork)
library(plotly)

# ---- Data wrangling (used by render fns inside the app object) ----
library(dplyr)
library(purrr)
library(tibble)
library(glue)
library(rlang)
library(magrittr)

# ---- Encoding / id helpers ----
library(jsonlite)
library(digest)
library(uuid)
library(base64enc)

# ---- BN classes (needed for deserialized bn.fit / grain objects to
# dispatch methods correctly even though the app runtime doesn't
# refit / re-query). requireNamespace registers S3 method tables
# without attaching the namespace to the search path. ----
requireNamespace("bnlearn", quietly = TRUE)
requireNamespace("gRain", quietly = TRUE)
requireNamespace("igraph", quietly = TRUE)

# ---- The work brand package itself. Used heavily inside the
# serialized app object (resondex_css, app_deliverable_*, etc.).
# requireNamespace (not library) keeps the deploy footprint minimal:
# only work's actual runtime deps get installed, not its full
# Suggests + dev-time tail. ----
requireNamespace("work", quietly = TRUE)

# ---- Load + serve ----
app <- readRDS("app_object.rds")
app
