library(ggplot2)
source("obtain_data_and_format.R")

our_data <- get_merged_formatted_data()
list[paid, unpaid] <- split_paid_unpaid(our_data)


### Misc ###########################################

## Hist: payment completion delay
payment_delay_hist <- function(contract_data) {
  hist(as.numeric(contract_data$paymentDelay), breaks = 20,
       main = "Payment Completion Delay", xlab = "Days elapsed",
       xlim = c(0, 200))
  
  nums <- as.numeric(contract_data$paymentDelay)
  int_only <- nums[!is.na(nums)]
  
  print(sum(int_only < 63) / 5838)
}

payment_delay_hist(our_data)
print(mean(paid$paymentDelay))


## Correlation between size and delay
cor(paid$contractSize, as.numeric(paid$paymentDelay))


### Size ###########################################

## Average paid contract size with payment delay > threshold
paid_size_print <- function(contract_data, threshold) {
  late_df <- subset(contract_data, paymentDelay > threshold)
  print(mean(late_df$contractSize))
}

paid_size_print(paid, 120)


## Average size for unpaid contracts closed more than threshold days ago
size_print <- function(contract_data, threshold) {
  late_df <- subset(contract_data, closingToPresent > threshold)
  print(mean(late_df$contractSize))
}

size_print(unpaid, 0)


## Obtain average contract size by region with payment delay > threshold
get_year_region_late <- function(contract_data, threshold) {
  year_region_plot_df <- data.frame(year = numeric(),
                                    mean_size = numeric(),
                                    region = character())
  
  # Mean of ALL data
  for (possible_year in 2016:2018) {
    df_year <- subset(contract_data,
                      closingYear == possible_year &
                        paymentDelay > threshold)
    
    size <- mean(as.numeric(df_year$contractSize))
    year_region_plot_df <- rbind(
      year_region_plot_df,
      data.frame(
        year = possible_year,
        region = "mean",
        mean_size = size
      )
    )
  }
  
  # By region and year
  for (possible_region in unique(contract_data$region)) {
    for (possible_year in 2016:2018) {
      df_region_year <- subset(
        contract_data,
        closingYear == possible_year &
          region == possible_region &
          paymentDelay > threshold
      )
      
      size <- mean(as.numeric(df_region_year$contractSize))
      year_region_plot_df <- rbind(
        year_region_plot_df,
        data.frame(
          year = possible_year,
          region = possible_region,
          mean_size = size
        )
      )
      print(size)
    }
  }
  year_region_plot_df
}


## Plot average contract size by region with payment delay > threshold
year_region_plot <- function(year_region_plot_df) {
  ggplot(year_region_plot_df,
         aes(
           x = year,
           y = mean_size,
           color = region,
           group = region
         )) +
    geom_point() +
    geom_line() +
    labs(x = "Year", y = "Ratio") +
    scale_x_continuous(
      breaks = unique(year_region_plot_df$year),
      limits = c(
        min(year_region_plot_df$year),
        max(year_region_plot_df$year)
      ),
      minor_breaks = NULL
    ) +
    #scale_y_continuous(limits = c(0.8, 2)) +
    ggtitle("Ratio: Mean Late Contract Size to Mean Contract Size, \n by Region, by Year") +
    geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
    theme(plot.title = element_text(hjust = 0.5))
}


# Plot on time data and late data
on_time <- get_year_region_late(paid, 0)
late <- get_year_region_late(paid, 120)
year_region_plot(on_time)
year_region_plot(late)


# Plot ratio
dif <- late
dif$mean_size <- late$mean_size / on_time$mean_size
year_region_plot(dif)


#### Partners #####################################

# Among paid contracts with payment delay > threshold,
# how high is partner involvement ?
paid_partner_ratio <- function(contract_data, threshold) {
  late_df <- subset(contract_data, paymentDelay > threshold)
  print(late_df)
  print(sum(late_df$partnerInvolved == "Yes") / nrow(late_df))
  print(nrow(late_df))
}

paid_partner_ratio(paid, 120)


# Among unpaid contracts closed more than threshold days ago,
# how high is partner involvement ?
unpaid_partner_ratio <- function(contract_data, threshold) {
  late_df <- subset(contract_data, closingToPresent > threshold)
  print(sum(late_df$partnerInvolved == "Yes") / nrow(late_df))
  print(nrow(late_df))
}

unpaid_partner_ratio(unpaid, 120)


# Among all contracts closed within threshold days ago,
# how high is partner involvement ?
partner_ratio <- function(contract_data, threshold) {
  late_df <- subset(contract_data, closingToPresent < threshold)
  print(sum(late_df$partnerInvolved == "Yes") / nrow(late_df))
  print(nrow(late_df))
}

partner_ratio(our_data, 200)


# Size partner correlation
size_partner_cor <- function(contract_data) {
  print(cor(contract_data$contractSize, contract_data$partnerInvolved == "Yes"))
}

size_partner_cor(paid)


## Histogram: unpaid delay distribution
payment_delay_hist <- function(contract_data, threshold) {
  subset_df <- subset(contract_data, closingToPresent > threshold)
  hist(as.numeric(subset_df$closingToPresent), breaks = 20,
       main = "Payment Completion Delay", xlab = "Days elapsed",
       xlim = c(0, 200))
  
  nums <- as.numeric(contract_data$paymentDelay)
  int_only <- nums[!is.na(nums)]
  
  print(sum(int_only < 63) / 5838)
}

payment_delay_hist(unpaid, 90)


## Plot partner involvement by delay against percentage of contracts that
## reach the delay
plot_partner_ratio <- function(contract_data) {
  x = c(0, 90, 120)
  y1 = numeric()
  y2 = numeric()
  for (pt in x) {
    late_df <- subset(contract_data, paymentDelay > pt)
    y1 = c(y1, nrow(late_df) / nrow(contract_data))
    late_partner_df <- subset(contract_data, paymentDelay > pt & partnerInvolved == "Yes")
    y2 = c(y2, nrow(late_partner_df) / nrow(contract_data))
  }
  
  print(y2/y1)
  print(y1)
  
  our_df <- data.frame(x = x, y1 = y1, y2 = y2)
  
  ggplot(our_df) +
    geom_point(aes(x = x, y = y1), color = "blue") +
    geom_line(aes(x = x, y = y1), color = "blue") +
    geom_point(aes(x = x, y = y2), color = "red") +
    geom_line(aes(x = x, y = y2), color = "red") +
    geom_line(aes(x = x, y = y2/y1), color = "black") +
    geom_ribbon(aes(x = x, ymin = 0, ymax = y1), fill = "lightblue", alpha = 0.5) +
    geom_ribbon(aes(x = x, ymin = y1, ymax = y2), fill = "pink", alpha = 0.5) +
    labs(x = "x", y = "y") +
    theme_minimal()
}

plot_partner_ratio(paid)


## Pie chart
# Create a vector with the data percentages
data <- c(55.5, 44.5)

# Create labels for the sectors
labels <- c("", "")
labels2 <- c("No partner involved", "Partner Involved")

# Define a softer color palette
library(RColorBrewer)
colors <- brewer.pal(length(data), "Greys")

# Create the pie chart
pie(data, labels = labels, col = colors)

# Add a legend
legend("topright", legend = labels2, fill = colors)


### Loyalty #######################################

delay_by_visit <- function(contract_data) {
  # Acquire data
  x = unique(contract_data$repeatCustomer)
  y = numeric()
  for (visit in x){
    visit_df <- subset(contract_data, repeatCustomer == visit)
    y = c(y, mean(visit_df$paymentDelay))
    
  }
  our_df <- data.frame(x = x, y = y)
  print(our_df)
  
  # Plot
  ggplot(our_df) +
    geom_point(aes(x = x, y = y), color = "black") +
    geom_smooth(aes(x = x, y = y), method = "lm", se = FALSE, color = "blue") + 
    labs(x = "Interaction number", y = "Payment delay (days)",
         title = "Payment Delay by Engagement Level: New vs. Repeat Business") +
    theme(plot.title = element_text(hjust = 0.5)) + 
    coord_cartesian(ylim = c(75, 100))
}

delay_by_visit(paid)


#### Logistic Regression ##########################

# Copy data
lr_data <- our_data

# Format data
lr_data$paymentDelay <- lr_data$paymentDelay > 100  # Render delay binary
lr_data$partnerInvolved <- lr_data$partnerInvolved == "Yes"

# Encoding the region column using dummy variable encoding
encoded_df <- model.matrix(~ region - 1, data = lr_data)
lr_data <- cbind(lr_data, encoded_df)

# Fit a logistic regression model
model <- glm(paymentDelay ~ contractSize + contractLength + partnerInvolved +
               regionAfrica + regionEMEA + regionAPAC + regionNorthAmerica +
               regionLatinAmerica + closingYear + repeatCustomer,
             data = lr_data, family = binomial)

# View the model summary
summary(model)
