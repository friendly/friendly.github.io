# Reproduces the structural steps behind Jarl Van Eycke's 2020/2021 solution
# of Michael Florent van Langren's cipher from La Verdadera Longitud (1644, p.8).
# Source data: cipher-transcription.txt, from the supplementary materials for
# Friendly, Valero-Mora & Ibanez Ulargui (2010), The American Statistician.
#
# Van Eycke's own account is second-hand throughout (relayed via Klaus Schmeh's
# Cipherbrain blog, itself a paraphrase of a description Van Eycke emailed him)
# -- the steps below are our own reconstruction from that description, run
# against the real ciphertext.

# ---- 1. The "words" are a decoy --------------------------------------------
# Token lengths are suspiciously uniform -- too tight a spread for genuine
# word boundaries in any European language.

cipher_raw <- readLines(here::here("blog/drafts/vanLangren", "cipher-transcription.txt"),
                        encoding = "UTF-8") |> paste(collapse = " ")
tokens <- strsplit(cipher_raw, "[ \t]+")[[1]]
tokens <- tokens[tokens != ""]
tab <- table(nchar(tokens))
m <- rbind(nchar = as.integer(names(tab)), freq = as.integer(tab))
colnames(m) <- rep("", ncol(m))
m
cat("Total tokens:", sum(tab), "\n")           # sum(m) would be wrong: it adds both rows
prop_4_8 <- sum(tab[names(tab) %in% as.character(4:8)]) / sum(tab)
cat(sprintf("Proportion with 4-6 characters: %.1f%%\n", 100 * prop_4_8))

# ---- 2. Strip spaces and decoy capitals ------------------------------------
# Capitals scattered through the text carry no information; removing them
# (along with the fake word-spacing) leaves one unbroken run of lowercase
# letters, long-s (ſ), and digits.

nospace <- gsub("[ \t]+", "", cipher_raw)
nocaps <- gsub("[A-Z]", "", nospace)
substr(nospace, 1, 60)
substr(nocaps, 1, 60)

# ---- 3. Split into three interleaved streams -------------------------------
# Taking every third character (positions 1,4,7,... / 2,5,8,... / 3,6,9,...)
# starts producing letter patterns that look far more like language.

chars <- strsplit(nocaps, "")[[1]]
n <- length(chars)
stream1 <- paste(chars[seq(1, n, by = 3)], collapse = "")
stream2 <- paste(chars[seq(2, n, by = 3)], collapse = "")
stream3 <- paste(chars[seq(3, n, by = 3)], collapse = "")
substr(stream1, 1, 60)

# ---- 4. Undo the digit substitution ----------------------------------------
# Final layer is a simple key: 1=a, 2=b, ... 9=i. Concatenate the three
# streams in order and substitute.

plain_raw <- paste0(stream1, stream2, stream3)
digit_map <- setNames(letters[1:9], as.character(1:9))
plain_chars <- strsplit(plain_raw, "")[[1]]
subbed <- vapply(plain_chars, function(ch) {
  if (ch %in% names(digit_map)) digit_map[[ch]] else ch
}, character(1))
plain_final <- gsub("ſ", "s", paste(subbed, collapse = ""))

# Excerpt further into the message (not the very start) -- lands on the
# "Michael Florent van Langren says: make two copper vessels..." reveal,
# matching the English translation already quoted in the post.
excerpt <- substr(plain_final, 533, 940)
for (s in seq(1, nchar(excerpt), by = 68)) {
  cat(substr(excerpt, s, min(s + 67, nchar(excerpt))), "\n")
}

# Full reconstruction, for reference (rougher toward the end -- likely a
# transcription slip somewhere in the 2010 cipher.txt):
# cat(plain_final, "\n")
