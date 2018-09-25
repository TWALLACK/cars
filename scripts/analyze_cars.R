# Script to analyze car data obtained from the Massachusetts Registry of Motor Vehicles.

# Import libraries
library(dplyr)
library(tidyverse)
library(readr)
library(ggplot2)
library(sf)


# Imort tab delimited text file
cars <- read_tsv("data/total active passenger plates for each county and town broken down by ma... (1).csv")

# clean up file
names(cars) <- c("county","city","manufacturer","model","total")
cars$city <- gsub("E BROOKFIELD","EAST BROOKFIELD",cars$city)
cars$city <- gsub("W BRIDGEWATER","WEST BRIDGEWATER",cars$city)


# Create unique identifier for each make and model of car - smashing together two separate columns into one
cars$model <- str_squish(paste(cars$manufacturer," ",cars$model)) 


# Calculate the total number of cars statewide  - 4,571,544
state_total = formatC(sum(cars$total),format="d",big.mark=",")
state_total

# caclulate the statewide totals by model
statewide_model_totals <- group_by(cars,model) %>%  
  summarize(total=sum(total),percent=sum(total)/sum(cars$total)*100) %>% 
  mutate(rank = order(order(total, decreasing=TRUE))) %>% 
  arrange(rank)

# caclulate the statewide totals by make
statewide_make_totals <- group_by(cars,manufacturer) %>%  
  summarize(total=sum(total),percent=sum(total)/sum(cars$total)*100) %>% 
  mutate(rank = order(order(total, decreasing=TRUE))) %>% 
  arrange(rank)

# Export statewide totals
write.csv(statewide_make_totals, file = "output/statewide_make_totals.csv",row.names=F)
write.csv(statewide_model_totals, file = "output/statewide_model_totals.csv",row.names=F)


# Calculate the total number of cars in each city
car_city <- group_by(cars,city) 
city_totals <- summarize(car_city,city_total=sum(total)) 

# Calculate the total number of auto makes by city
make <- group_by(cars,county,city,manufacturer)
make2 <- summarize(make,make_total=sum(total))

# Then join the two tables to calculate the percentage of car makes in each city
cars_make <- left_join(city_totals, make2, by = "city" )
cars_make$make_percent <- round((cars_make$make_total / cars_make$city_total *100),digits=2)
#cars_make$make_percent< - round(cars_make$make_percent, digits=2)

# Rename car make columns and save file
cars_make<- select(cars_make,county,city,manufacturer,total=make_total,percent=make_percent,city_total)
write.csv(cars_make, file = "output/make_popular.csv",row.names=F)

# Calculate the percentage of car models in each city
car_model <- left_join(city_totals, cars, by = "city" )
car_model$percent <- car_model$total / car_model$city_total *100
car_model$percent<- round(car_model$percent, digits=2)

# Rename columns of model file and save file
car_model <-select(car_model,county,city,model,total,percent,city_total) #,city_total
write.csv(car_model, file = "output/car_model.csv",row.names=F)


# Calculate the rankings
# --- First gave the most popular car and the top 10 cars in each city
top_model<- car_model %>% group_by(city) %>% top_n(1, total)
top_ten<- car_model %>% group_by(city) %>% top_n(10, total)

# Then rank most popular models in each city 
top_ten<- top_ten %>%
  group_by(city) %>%
  mutate(rank = order(order(total, decreasing=TRUE)))
top_ten<- top_ten %>% arrange(city,desc(total))

# Then come up with the full ranking of all models in every city
rank_models<- car_model %>%
  group_by(city) %>%
  mutate(rank = order(order(total, decreasing=TRUE)))
rank_models<- rank_models %>% arrange(city,desc(total))

# Export model files
write.csv(top_model, file = "output/top_car.csv",row.names=F)
write.csv(top_ten, file = "output/top_ten_cars.csv",row.names=F)
write.csv(rank_models, file = "output/rank_models.csv",row.names=F)

# Calculate the most popular car makes by city
top_make<- cars_make %>% group_by(city) %>% top_n(1, total)
top_ten_make<- cars_make %>% group_by(city) %>% top_n(10, total)
top_ten_make<- top_ten_make %>%
  group_by(city) %>%
  mutate(rank = order(order(total, decreasing=TRUE)))
top_ten_make<- top_ten_make %>% arrange(city,desc(total))


# Then come up with the full ranking of all makes in every city
rank_make<- cars_make %>%
  group_by(city) %>%
  mutate(rank = order(order(total, decreasing=TRUE)))
rank_make<- rank_make %>% arrange(city,desc(total))


# Then export the make files
       
write.csv(top_make, file = "output/top_make.csv",row.names=F)
write.csv(top_ten_make, file = "output/top_10_make.csv",row.names=F)
write.csv(rank_make, file = "output/rank_make.csv",row.names=F)




# Find the top car in Nantucket (Jeep Wrangler)
top_ten_nantucket <- filter(top_ten, city == "NANTUCKET" & rank == 1)
top_ten_nantucket$model

# Find the top town for Mercedes (Weston)
top_town_mercedes <- filter(rank_make, manufacturer == "MERZ") %>% arrange(rank) %>% head(1)
top_town_mercedes$city

# Find the top 10 cars in Boston (Accord and Camry are #1 and #2 respectively)
top_ten_boston <- filter(top_ten, city == "BOSTON") %>% select(model,percent,rank) 
top_ten_boston

# Find the top 10 cars in Boston (Accord and Camry are #1 and #2 respectively)
top_ten_makes_boston <- filter(rank_make, city == "BOSTON") %>% head(10)
top_ten_makes_boston

# Find number of Ferraris in Boston (35)
ferraris_boston <- filter(rank_make, city == "BOSTON",manufacturer == "FERR") 
ferraris_boston$total

# Find # of Plymouths  in Boston (55)
plymouth_boston <- filter(rank_make, city == "BOSTON",manufacturer == "PLYM" |manufacturer == "PLYMO") %>% summarize(cars = sum(total))
plymouth_boston$cars

# Find # of Plymouth Valients in Boston (2)
plymouth_boston <- filter(rank_models, city == "BOSTON")  %>% filter(grepl('PLYM.*VAL', model)) %>% summarize(valients = sum(total))
plymouth_boston$valients


# Find the top 10 makes in Revere (Toyota and Honda are #1 and #2 respectively)
top_makes_boston <- filter(rank_make, city == "BOSTON") %>% head(3)
top_makes_boston

# Find the top 10 cars in Revere (Accord and Camry are #1 and #2 respectively)
top_ten_revere <- filter(top_ten, city == "REVERE")
top_ten_revere



# Find top cars in Berkshire County by town
berkshire <- filter(rank_models, county == "BERKSHIRE",rank==1)
berkshire

# Berkshire towns where Chev Silverado  is No. 1
# "ADAMS"  "CHESHIRE"  "CLARKSBURG"  "FLORIDA"  "HINSDALE" "LANESBOROUGH", 
#"LEE"  "OTIS" PERU"   "SAVOY"   "SHEFFIELD"    "WASHINGTON"  
# "WINDSOR" 
berkshire_chev <- filter(berkshire,model == "CHEV   SILVER")
berkshire_chev$city

# Berkshire towns where Subaru Forrester  is No. 1 
# (Becket, Egremont, Great Barrington, Lenox, Monterey, Mount Washington, 
# New Marlborough, Stockbridge, West Stockbridge)
berkshire_subaru <- filter(berkshire,model == "SUBA   FOREST")
berkshire_subaru$city
berkshire_subaru

# Berkshire towns where Subaru Outback  is No. 1  (Alford, Richmond, Sandisfield, Tyringham, Williamstown)
berkshire_outback <- filter(berkshire,model == "SUBA   OUTBAC")
berkshire_outback$city
berkshire_outback

#Number of towns in Massachusetts where Subaru Forrester is ranked No. 1 (20)
mass_subaru <- filter(rank_models,model == "SUBA   FOREST",rank==1)
nrow(mass_subaru)

# Correlate Trump versus Clinton with cars in R?
# One map of town voting is here: https://www.nytimes.com/elections/results/massachusetts
# Baker noticed that in the past presidential election, 
# Donald Trump generally fared much better in towns where the Silverado was tops.

# town that has one dominant car (Nantucket, where Jeep Wranglers account for 11.4% of cars)
mass_dominant <- filter(rank_models,rank==1,city_total>100) %>% arrange(-percent) 
mass_dominant$city[1]
str_squish(mass_dominant$model[1])
mass_dominant$total[1]
mass_dominant$percent[1]

# town that is second dominant car (Lawrence, where Honda Accord accounts for 9.7% of cars)
mass_dominant$city[2]
str_squish(mass_dominant$model)[2]
mass_dominant$total[2]
mass_dominant$percent[2]

# town where one manufacturer dominates
# Lawrence (Honda) is No. 1
# Wellfleet, Eastham, Orleans (Toyota) rank 2-4.
mass_dominant_make <- filter(rank_make,rank==1,city_total>100) %>% arrange(-percent)
head(mass_dominant_make,4)

# Top manufacturers statewide (Toyota with 17.7%)
head(statewide_make_totals,10)

# Top models statewide (Toyota Camry with nearly 4%)
head(statewide_model_totals,10)

# Find number of towns that have some of the top cars
number_one_car <- filter(rank_models,rank==1) %>% select (city,model) %>% group_by(model) %>% count(model) %>% arrange(-n) %>% rename(number_of_towns = n)
head(number_one_car,6) 
number_one_car

# Find towns where Toyota Tacoma dominates 
# Includes Essex in Cape Ann and a number of towns on Cape Cod
# such as Proncetown, Chilmark, Wellfleet and Truro.
toyota_tacoma <- filter(rank_models, model=="TOYT   TACOMA",rank==1)
toyota_tacoma$city

# Find towns where Toyota Prius dominates - 9 towns, including Amherst and Northampton, Lincoln, and Carlisle
toyota_prius <- filter(rank_models, model=="TOYT   PRIUS",rank==1)
toyota_prius$city # name of towns
nrow(toyota_prius) # number of towns 

#Find the five most popular cars in Cambridge
top_five_cambridge <- filter(top_ten, city == "CAMBRIDGE") %>% head(5)
top_five_cambridge


# Find towns where Mercedes dominates - Weston is number one, followed by Dover, Lynnfield, and Wellesley
top_towns_mercedes <- filter(rank_make, manufacturer == "MERZ") %>% arrange(rank) %>% head(5)
top_towns_mercedes

# Find towns where BMW dominates - Weston is number one, followed by Dover, Wellesley, Sudbury, and Manchester-by-the-sea
top_towns_BMW <- filter(rank_make, manufacturer == "BMW") %>% arrange(-percent) %>% head(5)
top_towns_BMW

# Find towns where Tesla dominates - Weston is number one, followed by Dover, Wellesley, Lincoln and Carlisle.
# Concord, Sherborn, Brookline, Lexington, and Wayland
top_towns_tesla <- filter(rank_make, manufacturer == "TESL") %>% arrange(-percent) %>% head(10)
top_towns_tesla

#Find the 10 most popular cars in Weston # Honda CRV is No 1, followed by Jeep Wrangler. BMW X5 comes in third
top_ten_weston <- filter(top_ten, city == "WESTON") %>% head(10)
top_ten_weston



# create maps

shape_file <- "gis/TOWNSSURVEY_POLY.shp"
mass <- st_read(shape_file)
mass
ggplot(mass) + geom_sf()
View(mass)
mass <- mass %>% mutate_if(is.factor, as.character) 

nrow(mass)

library(dplyr)

cars_map <- left_join(mass_dominant_make, mass,
                          by=c("city"="TOWN"))
ncol(cars_map)
View(cars_map)
colnames(cars_map)


# map manufacturer type
ggplot(cars_map) +
  geom_sf(aes(fill=manufacturer)) +
  labs(title="Most popular car make by town", caption="Source: RMV") +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank())

mass_dominant_model <- filter(rank_models,rank==1)
models_map <- left_join(mass_dominant_model, mass,
                      by=c("city"="TOWN"))

ggplot(models_map) +
  geom_sf(aes(fill=model)) +
  labs(title="Most popular car model by town", caption="Source: RMV") +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank())

        

#mass$TOWN <-   gsub("EAST BROOKFIELD","E BROOKFIELD",mass$TOWN )
#mass$TOWN <-   gsub("WEST BRIDGEWATER","W BRIDGEWATER",mass$TOWN )  
#View(mass)



#glimpse(mass_dominant_model)


ferraris_boston <- filter(rank_make, city == "BOSTON",manufacturer == "FERR")