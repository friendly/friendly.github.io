## ---- fig-cv-hits ----
library(ggplot2)

cv_labels <- c(
  "Related + Financial" = "Family ties + financial gain",
  "All non-AI" = "All four character traits",
  "Rel + Fin + AI ch1 web" = "Family ties + gain + web Chapter 1",
  "Rel + Fin + AI ch1 pasted" = "Family ties + gain + pasted Chapter 1",
  "Rel + Fin + AI 20%" = "Family ties + gain + pasted 20%-point chapter"
)
cv_hits <- data.frame(
  model = factor(unname(cv_labels), levels = rev(unname(cv_labels))),
  in_sample = cv[names(cv_labels), "hit_cl_in"],
  held_out = cv[names(cv_labels), "hit_cl_cv"]
)
sample_colors <- c("In-sample" = "#526777", "Held-out" = "#A32740")

savefig("cv-hit-rates", {
  print(
    ggplot(cv_hits, aes(y = model)) +
      geom_vline(xintercept = chance, linetype = "dashed", colour = "grey50") +
      geom_segment(aes(x = in_sample, xend = held_out, yend = model),
                   colour = "grey60", linewidth = 0.7) +
      geom_point(aes(x = in_sample, colour = "In-sample", shape = "In-sample"),
                 size = 4, stroke = 1) +
      geom_point(aes(x = held_out, colour = "Held-out", shape = "Held-out"), size = 2.5) +
      scale_colour_manual(values = sample_colors, breaks = names(sample_colors)) +
      scale_shape_manual(values = c("In-sample" = 1, "Held-out" = 16),
                         breaks = names(sample_colors)) +
      scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.2),
                         labels = scales::label_percent()) +
      labs(x = "Accusation hit rate", y = NULL, colour = NULL, shape = NULL) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "top", panel.grid.major.y = element_blank(),
            panel.grid.minor = element_blank())
  )
}, width = 8, height = 3.4)

## ---- tbl-ai-flags ----
no_coded_motive <- subset(dat, Related == 0 & Financial == 0)
ai_flag_counts <- function(predictor, flag) {
  suspects <- no_coded_motive$Killer[no_coded_motive[[predictor]] == flag]
  sprintf("%d/%d", sum(suspects), length(suspects))
}
flag_predictors <- c("AIch1web", "AIch1passage")
knitr::kable(data.frame(
  "AI input" = c("Web Chapter 1", "Pasted Chapter 1"),
  Flagged = vapply(flag_predictors, ai_flag_counts, character(1), flag = 1),
  Unflagged = vapply(flag_predictors, ai_flag_counts, character(1), flag = 0),
  check.names = FALSE
), align = "lcc", row.names = FALSE)
