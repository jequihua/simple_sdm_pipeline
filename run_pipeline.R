
# Load packages, custom fuctions and plan
source("packages.R")
source("functions.R")
source("plan.R")

# Configure pipeline for run
config <- drake_config(plan)

# Visualize pipeline as a graph.
vis_drake_graph(config, width = "100%", height = "500px")

library(networkD3)
sankey_drake_graph(config)

# Run pipeline.
make(plan, cache_log_file = "cache_log.txt")

# Debugging helpers
deps_code(analisis)

plan$command[[1]]

# see the dependencies that drake has already detected
deps_target("analisis", config)

tracked(config)
missed(config)
outdated(config)

