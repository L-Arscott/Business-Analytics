library(RMySQL)
library(gsubfn)
library(stringr)
library(lubridate)

## Obtain data
# Uses MySQL, replaced with simple file reader below
#.get_data <- function() {
#  my_password <- readLines("password.txt", n = 1)
#  
#  conn <- dbConnect(
#    MySQL(),
#    dbname = "dataiku_ta",
#    host = "localhost",
#    user = "root",
#    password = my_password
#  )
#  
#  query1 <- "SELECT *
#  FROM accounts_agents"
#  query2 <- "SELECT *
#  FROM contracts"
#  
#  agents_df <- dbGetQuery(conn, query1)
#  contracts_df <- dbGetQuery(conn, query2)
#  
#  list(agents_df, contracts_df)
#}


# Alternate version using read.csv
.get_data <- function() {
  agents_df <- read.csv("accounts_agents.csv")
  contracts_df <- read.csv("contracts.csv")
  
  list(agents_df, contracts_df)
}


## Merge agents_df and contracts_df
.merge_agents_contracts <- function(agents_df, contracts_df) {
  # Extract agent ID from contractID in contracts_df
  split_contractID <- str_split(contracts_df$contractID, "-")
  middle_part <- sapply(split_contractID, function(x) x[2])
  last_part <- sapply(split_contractID, function(x) as.numeric(x[3]))
  contracts_df_extracted_id <- data.frame(contracts_df,
                                          accountID = middle_part,
                                          repeatCustomer = last_part)
  
  # Merge agents_df with contracts_df_extracted_id based on contractID
  merged_df_result <- merge(contracts_df_extracted_id, agents_df,
                            by = "accountID", all.x = TRUE)
  
  merged_df_result
}


## Format result
.format_merged_and_add_cols <- function(merged_df) {
  # Format dates
  merged_df$closingDate <- as.Date(merged_df$closingDate)
  merged_df$paymentDate <- as.Date(merged_df$paymentDate)
  
  # Add contract closing year
  merged_df$closingYear <- year(merged_df$closingDate)
  
  # Add days from contract closing to payment column
  merged_df$paymentDelay <- merged_df$paymentDate - merged_df$closingDate
  
  # Add days from contract closing to present (2018-12-11) column
  merged_df$closingToPresent <- as.Date("2018-12-11") - merged_df$closingDate
  
  # Remove spaces from region
  merged_df$region <- gsub(" ", "", merged_df$region)
  
  merged_df
}


## Put everything together
get_merged_formatted_data <- function() {
  list[agents, contracts] <- .get_data()
  merged <- .merge_agents_contracts(agents, contracts)
  merged_formatted <- .format_merged_and_add_cols(merged)
  
  merged_formatted
}


## Split paid and unpaid contracts
split_paid_unpaid <- function(contract_data) {
  df_not_na <- subset(contract_data, !is.na(paymentDelay))
  df_na <- subset(contract_data, is.na(paymentDelay))
  
  list(df_not_na, df_na)
}
