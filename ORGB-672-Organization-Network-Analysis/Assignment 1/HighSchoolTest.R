library(tidygraph)
library(ggraph)
# annotate highschool graph example
# as a tidygraph
data(highschool)
graph <- as_tbl_graph(highschool)
graph %>%
  ggraph(layout="kk") +
  geom_edge_fan(arrow=arrow()) +
  geom_node_point() +
  theme_graph(foreground=NA)
