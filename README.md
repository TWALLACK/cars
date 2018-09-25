"# nr-data-car-models" 

The RMV provided data showing what types of cars are registered in each town and county (including make, model number, and number of each type).

Billy Baker obtained this data for a feature story he is working on about what cars are popular in different towns.


The original RMV file is titled:
total active passenger plates for each county and town broken down by ma... (1).csv

I wrote an R script that generated several CSVs to help Billy sort through the data, including:

Top make and model in each city and town
* top_car.csv	
* top_make.csv	

Top 10 makes and in each city and town
* top_10_make.csv
* top_ten_cars.csv

Ranking of all makes and models in every town:
* rank_make.csv
* rank_models.csv


I also saved some intermediate files that you can probable ignore:
car_model.csv
make_popular.csv
