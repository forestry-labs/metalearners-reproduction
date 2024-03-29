library(ggplot2)
library(dplyr)
library(reshape)
library(ggrepel)
library(viridis)


experiments <- c("beta_confounded",
                 "complex_linear",
                 "global_linear",
                 "piecewise_linear",
                 "unbalanced_treatment",
                 "complex_nonlinear")

for (experiment in experiments ) {
  results <- data.frame()
  for (file_i in dir("results", pattern = experiment)) {
    results_i <- read.csv(file = paste0("results/", file_i))
    results <- rbind(results, results_i)
  }

  results %>%
    group_by(N) %>%
    summarise(XRF = mean(XRF),
              XBART = mean(XBART),
              SRF = mean(SRF),
              SBART = mean(SBART),
              TRF = mean(TRF),
              TBART = mean(TBART)) %>%
    as.data.frame() -> results

  min <- min(results %>%
               melt(id = "N") %>%
               select(value))

  max <- max(results %>%
               melt(id = "N") %>%
               select(value))

  results %>%
    melt(id = "N") %>%
    filter(substr(variable, 2,5) == "BART") %>%
    dplyr::rename(Estimator = variable) %>%
    dplyr::mutate(Estimator = plyr::revalue(Estimator, c("XBART" = "X Learner (BART)",
                                                         "SBART" = "S Learner (BART)",
                                                         "TBART" = "T Learner (BART)"))) %>%
    ggplot(aes(x = N, y = value, color = Estimator))+
    geom_line()+
    geom_point()+
    scale_y_log10(limits = c(min, max))+
    theme_bw()+
    scale_color_viridis_d()+
    labs(x = "Training Size", y = "MSE")

  ggsave(filename = paste0("figures/",exp_name,"_BART.pdf"), height = 6, width = 6)

  results %>%
    melt(id = "N") %>%
    filter(substr(variable, 2,5) != "BART") %>%
    dplyr::rename(Estimator = variable) %>%
    dplyr::mutate(Estimator = plyr::revalue(Estimator, c("XRF" = "X Learner (RF)",
                                                         "SRF" = "S Learner (RF)",
                                                         "TRF" = "T Learner (RF)"))) %>%
    ggplot(aes(x = N, y = value, color = Estimator))+
    geom_line()+
    geom_point()+
    scale_y_log10(limits = c(min, max))+
    theme_bw()+
    scale_color_viridis_d()+
    labs(x = "Training Size", y = "MSE")

  ggsave(filename = paste0("figures/",exp_name,"_RF.pdf"), height = 6, width = 6)
  print(exp_name)
}
