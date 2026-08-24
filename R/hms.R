# Formats a difftime (used for the SQL "time" type) as "HH:MM:SS[.ffffff]"
# text for sending to Postgres. No separate R class is needed for this:
# TIME columns fetched from the database already come back as plain
# `difftime` objects, this helper is only used when *sending* R values to
# SQL (COPY, bind parameters, quoted literals).
format_hms <- function(x) {
  raw <- as.numeric(x, units = "secs")
  secs <- round(abs(raw), 6)
  sign <- ifelse(is.na(raw) | raw >= 0, "", "-")

  whole <- floor(secs)
  hh <- whole %/% 3600
  mm <- (whole %/% 60) %% 60
  ss <- whole %% 60

  frac <- round((secs - whole) * 1e6)
  frac_str <- rep_len("", length(secs))
  has_frac <- !is.na(frac) & frac > 0
  if (any(has_frac)) {
    frac_str[has_frac] <- sub("0+$", "", sprintf(".%06d", frac[has_frac]))
  }

  out <- sprintf("%s%02d:%02d:%02d%s", sign, hh, mm, ss, frac_str)
  out[is.na(raw)] <- NA_character_
  out
}
