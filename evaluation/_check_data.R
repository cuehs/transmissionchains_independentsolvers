#sanity checks
movement %>% filter(type== "par") %>% na.omit()%>%
  group_by(landscapeId,strength) %>% filter(step == 1) %>%
  summarise(error = mutation(position)) %>% arrange(-error) %>% pull(error) %>% max()
