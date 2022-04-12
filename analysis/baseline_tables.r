# Awaiting tableone package to be added
library(tableone)
# Read in data
# 2019
data_2019 <- read.csv("output/measures/tables/input_tables_2019-01-01.csv")

# categorise age variable
data_2019$age_cat <- cut(data_2019$age, c(18, 40, 60, 80, 120))

tab_one_2019 <- CreateTableOne(vars = c("age_cat", "sex", "ethnicity", "imd"), data = data_2019, factorVars = c("age_cat", "sex", "ethnicity", "imd"))
tab_one_2019_export <- print(tab_one_2019, showAllLevels = TRUE)
write.csv(tab_one_2019_export, file = "output/measures/tables/table_2019")

# 2020
data_2020 <- read.csv("output/measures/tables/input_tables_2020-01-01.csv")

# categorise age variable
data_2019$age_cat <- cut(data_2020$age, c(18, 40, 60, 80, 120))

tab_one_2020 <- CreateTableOne(vars = c("age_cat", "sex", "ethnicity", "imd"), data = data_2020, factorVars = c("age_cat", "sex", "ethnicity", "imd"))
tab_one_2020_export <- print(tab_one_2020, showAllLevels = TRUE)
write.csv(tab_one_2020_export, file = "output/measures/tables/table_2020")

# 2021
data_2021 <- read.csv("output/measures/tables/input_tables_2021-01-01.csv")

# categorise age variable
data_2021$age_cat <- cut(data_2021$age, c(18, 40, 60, 80, 120))

tab_one_2021 <- CreateTableOne(vars = c("age_cat", "sex", "ethnicity", "imd"), data = data_2021, factorVars = c("age_cat", "sex", "ethnicity", "imd"))
tab_one_2021_export <- print(tab_one_2021, showAllLevels = TRUE)
write.csv(tab_one_2021_export, file = "output/measures/tables/table_2021")