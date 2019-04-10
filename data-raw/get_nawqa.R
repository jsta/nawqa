library(readxl)
library(magrittr)
library(readr)
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
library(rvest)
library(stringr)

get_if_not_exists <-
function(url, destfile, overwrite){
  if(!file.exists(destfile) | overwrite){
    download.file(url, destfile)
  }else{
    message(paste0("A local copy of ", url, " already exists on disk"))
  }
}

base_url <- "https://pubs.usgs.gov/ds/2005/152/"

# get xls paths
xls_paths <- read_html("https://pubs.usgs.gov/ds/2005/152/htdocs/data_report_data.htm") %>%
  html_nodes("a") %>%
  html_attr("href")

xls_paths <- dplyr::filter(
    data.frame(xls_paths = xls_paths, stringsAsFactors = FALSE),
    str_detect(xls_paths, regex("XLS", ignore_case = TRUE))) %>%
  mutate(xls_paths = str_remove(xls_paths, "../")) %>%
  mutate(local_paths = str_replace(xls_paths, "data", "data-raw")) %>%
  mutate(xls_paths = paste0(base_url, xls_paths))

# download xls files
lapply(seq_len(nrow(xls_paths)), function(i)
  get_if_not_exists(xls_paths[i, "xls_paths"], xls_paths[i, "local_paths"],
                          overwrite = FALSE))

# parse xls files
summary_data <- readxl::read_xls("data-raw/Cycle_I_sw_nuts_summary_data.xls")

uesthis::use_data(summary_data, overwrite = TRUE)
