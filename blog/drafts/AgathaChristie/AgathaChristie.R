# AgathaChristie.R
# Reproduce and extend Lutz (2026), "Statistical sleuths versus AI: Unmasking the killer
# in Agatha Christie novels", Significance 23(6), 10-15.
# Data: https://github.com/SharonLutz/Stats-vs-AI-whodunnit
#
# Run standalone (Rscript AgathaChristie.R) to print results and write figures to figs/,
# or let AgathaChristie.qmd read the labeled chunks below with knitr::read_chunk().

## ---- setup ----
library(survival)   # clogit()
library(pROC)       # auc()
library(vcd)        # mosaic(), doubledecker()
library(vcdExtra)

dat <- read.csv("AgathaChristie_MissMarple_MainCharacters_v2.csv",
                fileEncoding = "UTF-8-BOM")
dat$Title <- factor(dat$Title)
dat$Novel <- factor(gsub("_", " ", dat$Title))

preds    <- c("Female", "Employed", "Related", "Financial")
ai_preds <- c("AIch1passage", "AIch1web", "AIch20p")
labels   <- c(Female = "Female", Employed = "Employed", Related = "Related to victim",
              Financial = "Financial gain", AIch1passage = "AI: Ch.1 pasted",
              AIch1web = "AI: Ch.1 from web", AIch20p = "AI: ~20% pasted")

# factor copies for tables & plots
fac <- dat
for (v in c("Killer", preds, ai_preds))
  fac[[v]] <- factor(dat[[v]], levels = 0:1, labels = c("No", "Yes"))

# draw to the knitr device inside Quarto, otherwise save a PNG in figs/
in_knitr <- isTRUE(getOption("knitr.in.progress"))
if (!in_knitr) dir.create("figs", showWarnings = FALSE)
savefig <- function(name, expr, width = 7, height = 6) {
  if (!in_knitr) {
    png(file.path("figs", paste0(name, ".png")), width = width, height = height,
        units = "in", res = 150)
    on.exit(dev.off())
  }
  expr
  invisible()
}

aucval <- function(fit) as.numeric(auc(dat$Killer, fitted(fit), quiet = TRUE))

## ---- describe ----
cat(nrow(dat), "characters,", sum(dat$Killer), "killers,", nlevels(dat$Title), "novels\n")
round(100 * colMeans(dat[, c("Killer", preds, ai_preds)]), 1)
ftable(xtabs(~ Related + Financial + Killer, fac))
# Lutz: Pearson chi-square for Related x Financial = 58.3 -- that's the Yates-corrected value
# (uncorrected: 63.8). Either way, expected counts are small; the OR is the better summary.
chisq.test(xtabs(~ Related + Financial, fac))
oddsratio(xtabs(~ Related + Financial, fac), log = FALSE)

## ---- lutz-table1 ----
# Lutz's Table 1 "odds ratios" are reproduced exactly by exp(coef) from a *linear*
# probability model (gaussian glm), not from logistic regression.
lutz <- t(sapply(c(preds, ai_preds), function(v) {
  fit <- glm(reformulate(v, "Killer"), family = gaussian, data = dat)
  ci  <- exp(confint.default(fit)[2, ])
  c(OR = exp(coef(fit)[[2]]), lower = ci[[1]], upper = ci[[2]],
    p = summary(fit)$coefficients[2, 4], AUC = aucval(fit))
}))
rownames(lutz) <- labels[rownames(lutz)]
round(lutz[order(lutz[, "AUC"]), ], 3)

## ---- lutz-multi ----
# Lutz's four multivariable models (AUC only is reported; AUC is the same for logit or LPM
# only when the fitted values have the same ordering, so use the logistic fits)
lutz_models <- list(
  "Related + Gain"            = Killer ~ Related + Financial,
  "Related + Gain + AI ch1"   = Killer ~ Related + Financial + AIch1passage,
  "Related + Gain + AI web"   = Killer ~ Related + Financial + AIch1web,
  "Related + Gain + AI 20%"   = Killer ~ Related + Financial + AIch20p)
lutz_fits <- lapply(lutz_models, glm, family = binomial, data = dat)
round(sapply(lutz_fits, aucval), 3)   # Lutz: 0.89, 0.89, 0.97, 0.92

## ---- uni-logit ----
# Correct univariate logistic odds ratios (profile-likelihood CIs)
uni <- t(sapply(c(preds, ai_preds), function(v) {
  fit <- glm(reformulate(v, "Killer"), family = binomial, data = dat)
  ci  <- exp(suppressMessages(confint(fit))[2, ])
  c(OR = exp(coef(fit)[[2]]), lower = ci[[1]], upper = ci[[2]],
    p = summary(fit)$coefficients[2, 4], AUC = aucval(fit))
}))
rownames(uni) <- labels[rownames(uni)]
compare <- cbind(Lutz_OR = lutz[, "OR"], uni)
round(compare[order(compare[, "AUC"]), ], 3)

## ---- full-logit ----
# All the non-AI predictors together; LR test for dropping each one
full <- glm(Killer ~ Female + Employed + Related + Financial, family = binomial, data = dat)
summary(full)
drop1(full, test = "LRT")

## ---- full-interaction ----
# Does the effect of financial gain depend on being related?
full_int <- update(full, . ~ . + Related:Financial)
anova(full, full_int, test = "LRT")

## ---- ai-add ----
# reduced model: Related + Financial (joint test of dropping Female and Employed),
# then add each AI predictor
base <- glm(Killer ~ Related + Financial, family = binomial, data = dat)
anova(base, full, test = "LRT")
ai_add <- t(sapply(ai_preds, function(v) {
  fit <- update(base, reformulate(c("Related", "Financial", v), "Killer"))
  lr  <- anova(base, fit, test = "LRT")
  c(OR_AI = exp(coef(fit)[[v]]), LR_chisq = lr$Deviance[2], p = lr$`Pr(>Chi)`[2],
    AUC = aucval(fit))
}))
rownames(ai_add) <- labels[rownames(ai_add)]
round(ai_add, 3)

## ---- clogit ----
# Conditional logit: each novel is a matched set, so the killer is compared only with the
# other suspects in the same book. The novel-level baseline (number of characters, number of
# killers) drops out.
#
# Financial gain is *separated* within novels: in every novel where some non-killer gains
# financially, the killer gains too. So its conditional OR is infinite (clogit warns "beta may
# be infinite"). Wald tests and CIs are then useless, but likelihood-ratio tests are fine,
# so we report LR tests throughout.
within <- do.call(rbind, lapply(split(dat, dat$Novel), function(x)
  c(characters = nrow(x), killers = sum(x$Killer),
    killer_gains = sum(x$Financial[x$Killer == 1]),
    others_gain  = sum(x$Financial[x$Killer == 0]))))
within

clfit <- function(f) suppressWarnings(clogit(f, data = dat))
# LR test against the null conditional model (loglik[1] is the loglik at beta = 0)
cl_lr <- function(fit) {
  chi <- 2 * diff(fit$loglik)
  c(LR_chisq = chi, p = pchisq(chi, length(coef(fit)), lower.tail = FALSE))
}
cl_uni <- t(sapply(c(preds, ai_preds), function(v) {
  fit <- clfit(reformulate(c(v, "strata(Title)"), "Killer"))
  or  <- exp(coef(fit))[[1]]
  c(OR = if (or > 1e6) Inf else or, cl_lr(fit))
}))
rownames(cl_uni) <- labels[rownames(cl_uni)]
round(cbind(cl_uni, glm_OR = uni[, "OR"]), 3)

# all non-AI predictors: LR test for dropping each term
cl_full <- clfit(Killer ~ Female + Employed + Related + Financial + strata(Title))
cl_drop1 <- function(fit, terms) {
  t(sapply(terms, function(v) {
    red <- clfit(reformulate(c(setdiff(terms, v), "strata(Title)"), "Killer"))
    chi <- 2 * (fit$loglik[2] - red$loglik[2])
    c(LR_chisq = chi, p = pchisq(chi, 1, lower.tail = FALSE))
  }))
}
round(cl_drop1(cl_full, preds), 4)
cl_base <- clfit(Killer ~ Related + Financial + strata(Title))
cl_ai <- lapply(ai_preds, function(v)
  clfit(reformulate(c("Related", "Financial", v, "strata(Title)"), "Killer")))
names(cl_ai) <- ai_preds
# LR test for adding each AI predictor to Related + Financial
round(t(sapply(cl_ai, function(fit) {
  lr <- anova(cl_base, fit)
  c(OR_AI = exp(coef(fit))[[3]], LR_chisq = lr$Chisq[2], p = lr$`Pr(>|Chi|)`[2])
})), 3)

## ---- accuse ----
# "Whom would Miss Marple accuse?" In each novel, accuse the character(s) with the highest
# linear predictor. With binary predictors there are ties, so score each novel as the
# expected hit rate of accusing one of the top-ranked suspects at random:
#   (killers among the top set) / (size of top set).
# Chance = (killers in novel) / (characters in novel).
accuse <- function(score) {
  by_novel <- split(data.frame(k = dat$Killer, s = round(score, 8)), dat$Title)
  mean(sapply(by_novel, function(x) { top <- x$s == max(x$s); sum(x$k[top]) / sum(top) }))
}
chance <- mean(tapply(dat$Killer, dat$Title, mean))
scores <- c(
  list(Chance = rep(0, nrow(dat))),
  lapply(setNames(ai_preds, labels[ai_preds]), function(v) dat[[v]]),
  list("Related"                   = dat$Related,
       "Financial"                 = dat$Financial,
       "Related + Financial"       = predict(cl_base, type = "lp"),
       "All non-AI (clogit)"       = predict(cl_full, type = "lp"),
       "Rel + Fin + AI ch1 pasted" = predict(cl_ai$AIch1passage, type = "lp"),
       "Rel + Fin + AI ch1 web"    = predict(cl_ai$AIch1web, type = "lp"),
       "Rel + Fin + AI 20%"        = predict(cl_ai$AIch20p, type = "lp")))
hit <- sapply(scores, accuse)
round(sort(hit), 3)

## ---- cv ----
# Leave-one-novel-out cross-validation: fit each model to 11 novels, score the characters of
# the 12th, repeat for all 12. This mimics predicting the killer in a novel you haven't read.
# Reports in-sample vs. CV AUC (glm; AUC is pooled over all 166 characters) and in-sample vs.
# CV accusation hit rate (glm and clogit; within-novel ranking).
cv_models <- list(
  "AI ch1 pasted"             = ~ AIch1passage,
  "AI ch1 web"                = ~ AIch1web,
  "AI 20%"                    = ~ AIch20p,
  "Related + Financial"       = ~ Related + Financial,
  "All non-AI"                = ~ Female + Employed + Related + Financial,
  "Rel + Fin + AI ch1 pasted" = ~ Related + Financial + AIch1passage,
  "Rel + Fin + AI ch1 web"    = ~ Related + Financial + AIch1web,
  "Rel + Fin + AI 20%"        = ~ Related + Financial + AIch20p)

# held-out scores: for each novel, predict from a fit to the other novels
lono <- function(rhs, type = c("glm", "clogit")) {
  type  <- match.arg(type)
  terms <- attr(terms(rhs), "term.labels")
  score <- numeric(nrow(dat))
  for (novel in levels(dat$Title)) {
    test  <- dat$Title == novel
    train <- dat[!test, ]
    if (type == "glm") {
      fit <- suppressWarnings(glm(reformulate(terms, "Killer"), binomial, data = train))
      # Slopes only: the fold's intercept is lower exactly when a killer is held out (fewer
      # killers in training), which would bias the *pooled* CV AUC downward. Ranking within
      # a novel is unaffected either way.
      b <- coef(fit)[-1]
      score[test] <- as.matrix(dat[test, names(b), drop = FALSE]) %*% b
    } else {
      fit <- suppressWarnings(clogit(reformulate(c(terms, "strata(Title)"), "Killer"),
                                     data = train))
      b <- coef(fit)
      b[is.na(b)] <- 0
      score[test] <- as.matrix(dat[test, names(b), drop = FALSE]) %*% b
    }
  }
  score
}
auc_of <- function(s) as.numeric(auc(dat$Killer, s, quiet = TRUE))
in_glm <- function(rhs) fitted(glm(reformulate(attr(terms(rhs), "term.labels"), "Killer"),
                                   binomial, data = dat))
in_cl  <- function(rhs) predict(clfit(reformulate(c(attr(terms(rhs), "term.labels"),
                                                    "strata(Title)"), "Killer")), type = "lp")

cv <- t(sapply(cv_models, function(rhs) {
  s_glm <- lono(rhs, "glm")
  s_cl  <- lono(rhs, "clogit")
  c(AUC_in       = auc_of(in_glm(rhs)), AUC_cv     = auc_of(s_glm),
    hit_glm_in   = accuse(in_glm(rhs)), hit_glm_cv = accuse(s_glm),
    hit_cl_in    = accuse(in_cl(rhs)),  hit_cl_cv  = accuse(s_cl))
}))
round(cv, 3)
cat("Chance hit rate:", round(chance, 3), "\n")

## ---- fig-fourfold ----
# Fourfold displays: Killer vs. each predictor. Area of each quarter circle ~ frequency,
# standardized to equal margins; confidence rings that don't overlap => OR != 1.
# ggfourfold: stack the predictors into long form (one row per character x predictor) and
# facet by predictor. Shading intensity marks ORs significant after Holm adjustment.
# theme_fourfold() has no axis titles, so the levels must say what they are: the predictor
# (No/Yes, left/right) is named in the facet title, Killer is Innocent/Killer (top/bottom).
library(ggplot2)
library(ggfourfold)
ff_vars <- c(preds, ai_preds)
ff_lab  <- sprintf("%s\nOR = %.1f", labels[ff_vars], uni[labels[ff_vars], "OR"])
ff_long <- do.call(rbind, lapply(seq_along(ff_vars), function(i)
  data.frame(Variable = ff_lab[i], Predictor = fac[[ff_vars[i]]],
             Killer = factor(fac$Killer, labels = c("Innocent", "Killer")))))
ff_long$Variable <- factor(ff_long$Variable, levels = ff_lab)
savefig("fourfold", {
  print(
    ggplot(ff_long, aes(x = Predictor, y = Killer)) +
      geom_fourfold() +
      facet_wrap(vars(Variable), nrow = 2) +
      theme_fourfold()
  )
}, width = 10, height = 6)

## ---- fig-effects ----
# Effect plot for the four-predictor model: fitted P(Killer) at each level of one predictor,
# averaging over the others in proportion to their distribution (effects::Effect()).
# Refit with factors so each effect has two levels, not a line from 0 to 1.
# (ggeffects::predict_response() instead fixes the other factors at their reference level,
# i.e. a character who is none of the four.) Drawn with ggplot on a logit scale, so all four
# panels share one scale; the dashed line is the overall proportion of killers.
library(effects)
library(ggplot2)
full_f <- glm(Killer ~ Female + Employed + Related + Financial, family = binomial, data = fac)
eff <- do.call(rbind, lapply(preds, function(v) {
  d <- as.data.frame(Effect(v, full_f))
  data.frame(Predictor = labels[[v]], Level = d[[v]],
             fit = d$fit, lower = d$lower, upper = d$upper)
}))
eff$Predictor <- factor(eff$Predictor, levels = labels[preds])
savefig("effects-full", {
  p_breaks <- c(.005, .01, .02, .05, .1, .2, .5, .8)
  print(
    ggplot(eff, aes(Level, fit)) +
      geom_hline(yintercept = mean(dat$Killer), linetype = "dashed", colour = "grey50") +
      geom_line(aes(group = 1), colour = "#B2182B") +
      geom_pointrange(aes(ymin = lower, ymax = upper), colour = "#B2182B") +
      facet_wrap(vars(Predictor), nrow = 1) +
      scale_y_continuous(transform = "logit", breaks = p_breaks, labels = as.character(p_breaks)) +
      labs(x = NULL, y = "Probability of being the killer") +
      theme_bw(base_size = 13)
  )
}, width = 9, height = 4)

## ---- fig-mosaic ----
# Mosaic: Related x Financial, shaded by residuals from the model that Killer is
# independent of [Related, Financial]
savefig("mosaic-rel-fin", {
  mosaic(~ Related + Financial + Killer, data = fac,
         expected = ~ Related * Financial + Killer,
         shade = TRUE, legend = TRUE, labeling = labeling_values,
         main = "Killer | Related x Financial")
})

## ---- fig-doubledecker ----
# Doubledecker: proportion of killers (dark) in each combination of the predictors
dd <- with(fac, data.frame(Killer, Related, Gain = Financial,
                           AI.web = AIch1web, AI.ch1 = AIch1passage))
savefig("doubledecker-ai-web", {
  doubledecker(Killer ~ Related + Gain + AI.web, data = dd,
               gp = gpar(fill = c("grey90", "#B2182B")),
               margins = c(2, 6, 4, 1),
               main = "Proportion of killers by Related, Gain, AI (ch.1 web)")
}, width = 9, height = 5)
savefig("doubledecker-ai-pasted", {
  doubledecker(Killer ~ Related + Gain + AI.ch1, data = dd,
               gp = gpar(fill = c("grey90", "#B2182B")),
               margins = c(2, 6, 4, 1),
               main = "Proportion of killers by Related, Gain, AI (ch.1 pasted)")
}, width = 9, height = 5)
