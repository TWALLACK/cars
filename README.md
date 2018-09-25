<h1 align="center">What cars are popular in different towns in Massachustts<h1>


The Massachusetts Registry of Motor Vehicles provided the Boston Globe with data in July 2018 showing what kind of private passenger vehicles are registered in each town in Massachusetts
(including make, model number, and number of each type).

The Globe used the data for a <a href="http://apps.bostonglobe.com/metro/graphics/2018/09/cars-by-town/">story</a> that ran in September 2018.
Todd Wallack wrangled the data. Billy Baker wrote the story. And Patrick Garvin creates the graphics and digital presentation.

The RMarkdown file in this repository generates an HTML file with all the key statistics and facts used in the story (as well as a few maps).

The R script  also generates the key stats, as well as several output files to help sort through the data, including:

Top make and model in each city and town
* top_car.csv	
* top_make.csv	

Top 10 makes and in each city and town
* top_10_make.csv
* top_ten_cars.csv

Ranking of all makes and models in every town:
* rank_make.csv
* rank_models.csv

The script also saves some intermediate files that you can probably safely ignore:
car_model.csv
make_popular.csv
