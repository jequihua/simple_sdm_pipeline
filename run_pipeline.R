
# Load packages, custom fuctions and plan
source("packages.R")
source("functions.R")
source("plan.R")

# Configure pipeline for run.
config <- drake_config(plan)

# Visualize pipeline as a graph.
vis_drake_graph(config)

# Run pipeline.
make(plan)

