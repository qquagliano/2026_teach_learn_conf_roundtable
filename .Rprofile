# SECTION: Set up parallel processing
n <- base::max(parallel::detectCores() - 2L, 1L)

# SECTION: Set CRAN mirror to closest
r <- base::getOption("repos")
r["CRAN"] <- "https://cloud.r-project.org/" # Basic US repo

# SECTION: Set options
base::options(
  browser = "firefox",
  editor = "nvim",
  mc.cores = n,
  menu.graphics = FALSE, # Avoiding any sorts of menu graphics
  Ncpus = n,
  pdfviewer = "evince", # GNOME PDF viewer
  prompt = "> ",
  continue = "... ",
  repos = r,
  scipen = 10, # Never use scientific notation
  width = 80, # 80 character limit across
  radian.auto_match = FALSE,
  radian.indent_lines = FALSE,
  radian.color_scheme = "github-dark"
)

# SECTION: Hide workspace image prompt
.env <- base::new.env()
.env$q <- function(save = "no", ...) {
  base::quit(save = save, ...)
}
base::attach(
  .env,
  warn.conflicts = FALSE
)

# SECTION: Tab complete with libraries in R console
utils::rc.settings(ipck = TRUE)

# SECTION: Removing created variables for startup functions
base::rm(n, r)

# SECTION: Clear console to start
system("clear")

# SECTION: Renv setup
# renv::load(
#   paste0(
#     Sys.getenv("GIT_ROOT_DIR")
#   )
# )
