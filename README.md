# Delivery App DataBase
## Introduction
University project developed in the course Introduction to Software Engineering I.
The main problem that we want to solve with this proyect is creating a database for a delivery app which has 4 types of users: clients, delivery person, owner and supplier. We have created a [class diagram](/Annex/ClassDiagram.png) stored in the folder "Annex". It is develop using SQL in MariaDB.
## Structure
The proyect is made out of 4 files.
1. Generate tables: to create the tables with their respectives restrictions.
2. Triggers, Procedures and Views.
3. Functions with their data.

#### Generate tables
Using data definition languages (DDL) for creating the tables and data manipulation language (DML) for adding information to the tables using a insert procedure.


#### Triggers, Procedures and Views
**Triggers**: they are used when there are few unit of stocks, when a users try to take a product that it is out of stock, to alert when a restaurant is not accepting orders and when a order is cancelled.

**Views**: the most interesting one are _RawMaterialsOrders_ and _ViewOrdersbyRestaurant_. The first one creates a view that shows the raw material that is left in a restaurant.The other one displays all the deliveries of each restaurant with each client.

**Procedures**: _currentlyWorkingDP_ shows the delivery people that are currently working and _mostExpensiveProduct_ the most expensive product of each restaurant. 

#### Functions
1. **_totalCost_**: given a deliveryId it returns total cost of a delivery. If the totalCost is lower that 25 the client has to paw the shipping costs.
2. **_MostOrderedProduct_**: returns the most ordered product.
3. **_mostExpensiveDelivery_**: returns the most expensive delivery.
4. **_bestDeliveryPeliveryPersonCurrentlyWorking_**: returns the delivery person with the best reviews that is currently working.






