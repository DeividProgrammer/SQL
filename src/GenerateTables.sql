DROP DATABASE if exists deliverus;
CREATE DATABASE deliverus;
USE deliverus;


CREATE OR REPLACE TABLE workinghours (
	workingHoursId INT  NOT NULL AUTO_INCREMENT,
	startingHour TIME,
	endingHour TIME,
	
	PRIMARY KEY(workingHoursId),
	CONSTRAINT coherenceTimes CHECK(startingHour<endingHour)
);


CREATE OR REPLACE TABLE DeliveryPeople (
	deliveryPersonId INT  NOT NULL AUTO_INCREMENT, 
	
	userName VARCHAR (12) NOT NULL,
	email VARCHAR(50) NOT NULL,
	`password` VARCHAR(30) NOT NULL,
	phoneNumber CHAR(9) NOT NULL,
	fullname VARCHAR (30) NOT NULL,
	bankAccount VARCHAR(100) NOT NULL,
	
	`typeOfVehicle` ENUM ('Car','Motorcycle','Bike','ElectricScooter'),
	`paymentMethod` ENUM ('CreditCard','Paypal','Bizzum','Bitcoin'),
	`workArea` VARCHAR (80) NOT NULL ,
	workingHoursId INT,
	 
	PRIMARY KEY (deliveryPersonId),
	FOREIGN KEY (workingHoursId) REFERENCES WorkingHours(workingHoursId),
	UNIQUE(userName),
	UNIQUE(email),
	UNIQUE(phoneNumber),
	
	CONSTRAINT correctEmail CHECK(email LIKE '%@%'),
	CONSTRAINT correctBankAcount CHECK(bankAccount LIKE 'ES%')
	
);


CREATE OR REPLACE TABLE Clients (
	clientId INT  NOT NULL AUTO_INCREMENT , 
	userName VARCHAR (12) NOT NULL,
	email VARCHAR(50) NOT NULL,
	`password` VARCHAR(30) NOT NULL,
	phoneNumber CHAR(9) NOT NULL,
	fullname VARCHAR (30) NOT NULL,
	
	
	`deliveryAddress` VARCHAR (100) 	NOT NULL UNIQUE ,	
	`paymentMethod` ENUM ('CreditCard','Paypal','Bizzum','Bitcoin'),
	PRIMARY KEY (clientId),
	UNIQUE(userName),
	UNIQUE(email),
	UNIQUE(phoneNumber),
	
	CONSTRAINT correctEmail CHECK(email LIKE '%@%')
);


CREATE or replace TABLE Owners (
	OwnerID INT  NOT NULL AUTO_INCREMENT , 
 	userName VARCHAR (12) NOT NULL,
	email VARCHAR(50) NOT NULL,
	`password` VARCHAR(30) NOT NULL,
	phoneNumber CHAR(9) NOT NULL,
	fullname VARCHAR (30) NOT NULL,
	bankAccount VARCHAR(100) NOT NULL,
	
	PRIMARY KEY (OwnerID),
	UNIQUE(userName),
	UNIQUE(email),
	UNIQUE(phoneNumber),
	UNIQUE(bankAccount),
	
	CONSTRAINT correctEmail CHECK(email LIKE '%@%'),
	CONSTRAINT correctBankAcount CHECK(bankAccount LIKE 'ES%')
);


CREATE OR REPLACE TABLE Restaurants(
	restaurantID INT  NOT NULL AUTO_INCREMENT ,

	userName VARCHAR (12) NOT NULL,
	email VARCHAR(50) NOT NULL,
	`password` VARCHAR(30) NOT NULL,
	phoneNumber CHAR(9) NOT NULL,
	fullname VARCHAR (30) NOT NULL,
	bankAccount VARCHAR(100) NOT NULL,
	
	restaurantAddress VARCHAR(100) NOT NULL,
	openTime TIME,
	restaurantAvailability ENUM('PermanentlyClosed', 'AcceptingOrders', 'NotAcceptingOrders', 'TemporalyClosed'),
	ownerId INT,
	PRIMARY KEY(restaurantID),
	FOREIGN KEY (ownerId) REFERENCES owners(ownerID),
	
	CONSTRAINT correctEmail CHECK(email LIKE '%@%'),
	CONSTRAINT correctBankAcount CHECK(bankAccount LIKE 'ES%')
);


CREATE OR REPLACE TABLE Suppliers (
	supplierID INT  NOT NULL AUTO_INCREMENT , 
	
	userName VARCHAR (12) NOT NULL,
	email VARCHAR(50) NOT NULL,
	`password` VARCHAR(30) NOT NULL,
	phoneNumber CHAR(9) NOT NULL,
	fullname VARCHAR (30) NOT NULL,
	bankAccount VARCHAR(100) NOT NULL,
	
	address VARCHAR (150) NOT NULL,	

	PRIMARY KEY (SupplierID),
	UNIQUE(userName),
	UNIQUE(email),
	UNIQUE(phoneNumber),
	UNIQUE(bankAccount),
	
	CONSTRAINT correctEmail CHECK(email LIKE '%@%'),
	CONSTRAINT correctBankAcount CHECK(bankAccount LIKE 'ES%')

	);
	
CREATE OR REPLACE TABLE RawMaterials (
	rawMaterialId INT NOT NULL AUTO_INCREMENT, 
	
	supplierId INT NOT NULL,
	typeOfRawMaterial ENUM('Meat', 'Fish', 'Legum', 'Dairy', 'Vegetable', 'Fruits', 'Sweet', 'Drinks'),
	price DECIMAL (4,2) NOT NULL,	
	amount DECIMAL (4,2) NOT NULL, 
	PRIMARY KEY (rawMaterialId), 
	FOREIGN KEY (supplierId) REFERENCES suppliers(supplierId)
);

	
	
CREATE OR REPLACE TABLE Amounts (
	amountId INT NOT NULL AUTO_INCREMENT, 
	rawMaterialId INT NOT NULL, 
	restaurantId INT NOT NULL, 
	numberOfProducts INT NOT NULL, 
	PRIMARY KEY (amountId), 
	FOREIGN KEY (rawMaterialId) REFERENCES rawmaterials(rawMaterialId), 
	FOREIGN KEY (restaurantId) REFERENCES restaurants(restaurantId),
	
	CONSTRAINT maxAmount CHECK(numberOfProducts<1000)
);

CREATE OR REPLACE TABLE Products (
	productId INT NOT NULL AUTO_INCREMENT, 
	restaurantId INT NOT NULL, 
	description VARCHAR (150) NOT NULL,
	price DECIMAL (4,2) NOT NULL,	
	stock ENUM('available', 'outOfStock', 'fewUnits'), 
	PRIMARY KEY (productId), 
	FOREIGN KEY (restaurantId) REFERENCES restaurants(restaurantId)
);
	

CREATE OR REPLACE TABLE Deliveries(
	deliveryId INT NOT NULL AUTO_INCREMENT,
	deliveryPersonId INT NOT NULL,
	clientId INT NOT NULL,
	restaurantId INT NOT NULL,
	
	deliveryDate DATETIME,
	maximumWaiting INT,
	orderStatuts ENUM('inProcess','ready','cancelled','sent','completed'),
	shippingCost FLOAT(4,2),
	
	PRIMARY KEY(deliveryId),
	FOREIGN KEY (deliveryPersonId) REFERENCES DeliveryPeople(deliveryPersonId),
	FOREIGN KEY(clientId) REFERENCES clients(clientId),
	FOREIGN KEY(restaurantId) REFERENCES restaurants(restaurantId),
	

	CONSTRAINT maxWaitingTime CHECK(maximumWaiting <40)
);

CREATE OR REPLACE TABLE  DeliveryAmounts(
	deliveryAmountId INT NOT NULL AUTO_INCREMENT,
	numberOfProducts INT(20) NOT NULL,
	productId INT NOT NULL, 
	deliveryId INT NOT NULL,
		
	PRIMARY KEY (deliveryAmountId),
	FOREIGN KEY (productId) REFERENCES products(productId),
	FOREIGN KEY (deliveryId) REFERENCES deliveries(deliveryId),
	
	CONSTRAINT maxAmount CHECK(numberOfProducts<20)
);
	
CREATE OR REPLACE TABLE DeliveryAssessments(
	assessmentId INT NOT NULL AUTO_INCREMENT,
	clientId INT NOT NULL,
	deliveryPersonId INT NOT NULL,
	deliveryId INT NOT null,
	restaurantId INT NOT NULL,
	
	ratingDeliveryPerson INT(1),
	ratingDelivery INT(1),
	ratingRestaurant INT(1),
	`comment` VARCHAR(200),
	
	PRIMARY KEY(assessmentId),
	FOREIGN KEY (clientId) REFERENCES clients(clientId),
	FOREIGN KEY (deliveryPersonId) REFERENCES deliveryPeople(deliveryPersonId),
	FOREIGN KEY (deliveryId) REFERENCES deliveries(deliveryId),
	FOREIGN KEY (restaurantId) REFERENCES restaurants(restaurantId),
	
		
	CONSTRAINT Valoracionde1a5DP CHECK(ratingDeliveryPerson<6),
	CONSTRAINT Valoracionde1a5D CHECK(ratingDelivery<6),
	CONSTRAINT Valoracionde1a5R CHECK(ratingRestaurant<6)
	
	
);
	


	
	
-- PROCEDIMIENTOS PARA INSERTAR DATOS

DELIMITER //
CREATE OR REPLACE PROCEDURE addWorkingHours (workingHoursId INT,startingHour TIME,
	endingHour TIME)
BEGIN
INSERT INTO workinghours VALUES (workingHoursId, startingHour,endingHour); 
END //


CREATE OR REPLACE PROCEDURE addDeliverypeople (deliveryPersonId INT,userName VARCHAR (12), email VARCHAR (50), `password` VARCHAR(30),	
phoneNumber CHAR(9), fullname VARCHAR (30), bankAccount VARCHAR(100), 	`typeOfVehicle` ENUM ('Car','Motorcycle','Bike','ElectricScooter'),
	`paymentMethod` ENUM ('CreditCard','Paypal','Bizzum','Bitcoin'),	`workArea` VARCHAR (80) ,workingHoursId INT )
BEGIN 
INSERT INTO deliverypeople VALUES (deliveryPersonId,userName,email,`PASSWORD`,
phoneNumber,fullname,bankAccount,typeOfVehicle,paymentMethod,workArea,workinghoursId);
END //

	


CREATE OR REPLACE PROCEDURE addClients (clientId INT, userName VARCHAR (12), email VARCHAR(50), `password` VARCHAR(30),
	phoneNumber CHAR(9), fullname VARCHAR (30),	`deliveryAddress` VARCHAR (100),`paymentMethod` ENUM ('CreditCard','Paypal','Bizzum','Bitcoin'))
BEGIN 
INSERT INTO clients VALUES (clientId, userName, email, `password`, phoneNumber, fullname, deliveryAddress, paymentMethod);
END //



CREATE OR REPLACE PROCEDURE addOwners (OwnerID INT, userName VARCHAR (12), email VARCHAR(50), `password` VARCHAR(30),
	phoneNumber CHAR(9), fullname VARCHAR (30), bankAccount VARCHAR(100))
BEGIN
 INSERT INTO owners VALUES (ownerid,username,email,`PASSWORD`,phoneNumber,fullname,bankAccount);
END //



DELIMITER //
CREATE OR REPLACE PROCEDURE addRestaurants (restaurantID INT, userName VARCHAR (12), email VARCHAR(50),`password` VARCHAR(30), phoneNumber CHAR(9),
fullname VARCHAR (30), bankAccount VARCHAR(100), restaurantAddress VARCHAR(100), openTime TIME, 
restaurantAvailability ENUM('PermanentlyClosed', 'AcceptingOrders', 'NotAcceptingOrders', 'TemporalyClosed'), ownerId INT)
BEGIN 
INSERT INTO restaurants VALUES (restaurantid,username,email,`PASSWORD`,phoneNumber,fullname,bankAccount,restaurantaddress,opentime,restaurantavailability,ownerid);
END //


	

CREATE OR REPLACE PROCEDURE addSuppliers (supplierID INT, userName VARCHAR (12), email VARCHAR(50), `password` VARCHAR(30), phoneNumber CHAR(9),
	fullname VARCHAR (30), bankAccount VARCHAR(100), address VARCHAR (150))
BEGIN 
INSERT INTO suppliers VALUES (supplierId,username,email,`PASSWORD`,phoneNumber,fullname,bankAccount,address);
END //




CREATE OR REPLACE PROCEDURE addRawMaterials (rawMaterialId INT, supplierId INT, typeOfRawMaterial ENUM('Meat', 'Fish', 'Legum', 'Dairy', 'Vegetable', 'Fruits', 'Sweet', 'Drinks'),
	price DECIMAL (4,2),	amount DECIMAL (4,2))
BEGIN 
INSERT INTO rawmaterials VALUES (rawmaterialid,supplierId,typeofrawmaterial,price,amount);
END //




CREATE OR REPLACE PROCEDURE addAmounts	(amountId INT, rawMaterialId INT, restaurantId INT, numberOfProducts INT) 
BEGIN 
INSERT INTO amounts VALUES (amountid,rawmaterialid,restaurantid,numberofproducts);
END //

	
	

CREATE OR REPLACE PROCEDURE addProducts (productId INT, restaurantId INT, description VARCHAR (150), price DECIMAL (4,2), stock ENUM('available', 'outOfStock', 'fewUnits'))
BEGIN
INSERT INTO products VALUES (productId, restaurantId, description, price, stock);
END //



CREATE OR REPLACE PROCEDURE addDeliveries (deliveryId INT, deliveryPersonId INT, clientId INT, restaurantId INT, deliveryDate DATETIME, maximumWaiting INT,
	orderStatuts ENUM('inProcess','ready','cancelled','sent','completed'), shippingCost FLOAT(4,2))
BEGIN
INSERT INTO deliveries VALUES (deliveryId , deliveryPersonId , clientId , restaurantId , deliveryDate , maximumWaiting, orderStatuts, shippingCost);
END //

	


CREATE OR REPLACE PROCEDURE addDeliveryAmounts (deliveryAmountId INT, numberOfProducts INT(20), productId INT, deliveryId INT)
BEGIN
INSERT INTO deliveryAmounts VALUES (deliveryAmountId , numberOfProducts , productId , deliveryId);
END //


	
	
CREATE OR REPLACE PROCEDURE addDeliveryAssessments (assessmentId INT, clientId INT,	deliveryPersonId INT, deliveryId INT,restaurantId INT,
	ratingDeliveryPerson INT(1),ratingDelivery INT(1),	ratingRestaurant INT(1),`comment` VARCHAR(200))
BEGIN 
  INSERT INTO DeliveryAssessments VALUES (assessmentId,clientId,	deliveryPersonId,deliveryId ,	restaurantId ,	ratingDeliveryPerson,ratingDelivery,
  	ratingRestaurant ,	`comment`);
END //

	








DELIMITER ;	
-- DATOS INSERTADOS A LA BASE DE DATOS 

	CALL addWorkingHours (null, TIME('12:30:00'), TIME('17:30:00'));
	CALL addWorkingHours (null, TIME ('18:30:00'), TIME('23:30:00'));
	CALL addWorkingHours (null, TIME ('10:00:00'), TIME('17:10:00'));
	CALL addWorkingHours (null, TIME ('19:00:00'), TIME('23:00:00'));
	
	

	CALL addDeliveryPeople (null,'MariaDB','MariaDB@gmail.com','Marii123',655854623,'Maria Ramos Vazquez','ES27 4587 5466 6898 5414','Bike','Bizzum','Nervión', 1);
	CALL addDeliveryPeople(null,'EledeBar','elenamolona@gmail.com','gigi420',633654875,'Elena Martin Ginebra','ES27 5652 5987 4521 6892','Car','PayPal','Espartinas', 4);
	CALL addDeliveryPeople(null,'Manuelo','vivaelbetis@gmail.com','viva346',654722189,'Manuel Barragan Perez','ES27 5052 5787 4521 6122','Motorcycle','PayPal','Bami', 2);
	CALL addDeliveryPeople (null,'Paco20','pacoguapo@gmail.com','12345',680144632,'Francisco Bernal Ramos','ES27 6620 5426 7229 9111','Car','CreditCard','Triana', 3);
	

	CALL addClients (null,'Rauu777','vegeta@gmail.com','12345',658954215,'Raul Gomez de la Sierra','Calle Sierpes 9','Bizzum');
	CALL addClients(null,'PriscilaMol','priscilaremolona@gmail.com','equisdeMe7950',666739587,'Priscila Cánovas Donas','Calle Melancólicas 8','Bizzum');
	CALL addClients(null,'JuandeDioso','juandedioso@gmail.com','refrescosNObebo',610725009,'Juan de Dios Palomares Fragua','Calle Rigodón 9','CreditCard');
	CALL addClients (null,'Leclein98','leclein98@gmail.com','machusaca8yosinagas',656833422,'Ramona Leclein Tiatio','Calle Camomila 82','Bitcoin');
	

	CALL addOwners (null,'JBezos','amazonmola@gmail.com','12345',656985684,'Jeff Preston Bezos','ES19 9856 8652 6845 5684');
	CALL addOwners(null,'Maca5','reinamaca@gmail.com','friolera-de-nacimient0',666184456,'Macarena Reina Países','ES00 8883 8652 3949 5684');
	CALL addOwners(null,'GanguiA','ganguisanchez@gmail.com','vivaBTS',619335678,'Ángeles Gangui Sánchez','ES19 4879 1189 2299 4999');
	CALL addOwners(null,'PuriMerceria','purimerceria@gmail.com','queBellezaTereza',691665533,'Purificación Milagros Mercería','ES32 8909 3344 32775 5654');
	

	CALL addRestaurants	(null,'MCDonalds1','McDonalds1@gmail.com','Hamburguesauneuro',954896532,'Restaurante McDonalds','ES19 5465 8453 5684 5413', 'Calle Lázaro 9','10:00','AcceptingOrders',1);
	CALL addRestaurants	(null,'ElGordito','elgordito@gmail.com','noEstoygordo,estoyEn3D',954113411,'Cervecería El Gordito','ES19 9958 0099 5684 3389', 'Calle Agaporni 17','10:00','AcceptingOrders',2);
	CALL addRestaurants	(null,'VikyBlaslu','vikyblaslu@gmail.com','holavikyBlaslu',955112290,'Bar Viky y Blaslu','ES11 8877 7639 0944 1188', 'Calle Javier de María 10','11:00','NotAcceptingOrders',3);
	CALL addRestaurants	(null,'GigiCasa','casagigi@gmail.com','madrePresa99',911993784,'Gigi en la casa','ES19 9948 1178 0039 9999', 'Calle Martilopi 32','12:00','AcceptingOrders',4);
	
	

	CALL addSuppliers	(null,'CarnesPedro','pedrocarnes@gmail.com','Hamburguesa',987562523,'Proveedor de Carnes Pedro','ES58 5624 8954 3245 7856', 'Calle Portil 29');
	CALL addSuppliers(null,'RocioCubata','rociocubata@gmail.com','hatePEPElnary',96759849,'Proveedora de bebidas Rocicubi','ES58 9984 5589 2233 0098', 'Calle Enagenación 59');
	CALL addSuppliers	(null,'TiaPescanova','tiapescanova@gmail.com','ignacioForraje',954229847,'Proveedor de pescado Pescanova','ES58 8478 5589 2289 4998', 'Calle Tablantes 12');
	CALL addSuppliers	(null,'Disfrutona','disfrutona@gmail.com','miVidaEs-espectacular',967339864,'Proveedor de Frutas Disfrutona','ES58 9957 4378 5987 2289', 'Calle Mequetrefe 18');
	

	CALL addRawMaterials	(null,1,'Meat',0.74,16.78);
	CALL addRawMaterials	(null,2,'Drinks',1.50, 5.00);
	CALL addRawMaterials	(null,3,'Fish',0.94,12.48);
	CALL addRawMaterials	(null,4,'Fruits',20.74,9.72);
	

	CALL addAmounts (null,1,1,2);
 	CALL addAmounts (null,2,2,3);
	CALL addAmounts (null,3,3,2);
	CALL addAmounts (null,4,4,15);
	

	CALL addProducts(null,1, "Delicious burger with caramelized onion", 5.50, 'available');
	CALL addProducts (null,2,"Fresh house beer", 3.50, 'available');
	CALL addProducts (null,3,"Squid in its own ink with a touch of lemon from Nicaraguan trees", 10.50, 'fewUnits');
	CALL addProducts (null,4,"Peaches in their syrup with confit", 4.90, 'available');
	
	CALL addDeliveries (null,1, 1, 1, '05/12/22 12:00:11', 15, 'inProcess', 2.5);
	CALL addDeliveries (null,2,2, 2, '05/12/22 10:00:00', 20, 'sent', 2.5);
	CALL addDeliveries (null,3, 3,3, '05/12/22 18:15:00', 7, 'ready', 2.5);
	CALL addDeliveries (null,4, 4, 4, '05/12/22 22:00:00', 21, 'completed', 2.5);
		
	CALL addDeliveryAmounts (null,2, 1, 2);
	CALL addDeliveryAmounts	(null,2,2, 3);
	CALL addDeliveryAmounts	(null,1, 1, 3);
	CALL addDeliveryAmounts (null,1, 2, 4);

	

	CALL addDeliveryAssessments(null,1, 2,2,2,2,1, 2, "Polite and friendly. I thought it was funny she was called like the SQL thing");
	CALL addDeliveryAssessments(null,2, 1, 3,3,2,3,5, "The delivery girl almost drank my beer. She did not transmit confidence that she lived disguised as a clown.");
	CALL addDeliveryAssessments(NULL,3, 3,2,1,3,5,4, "I don't have much to say, all good");
	CALL addDeliveryAssessments(null,4, 2,2,1, 4,2,4, "Paco, I loved him! We have exchanged numbers because we did not stop talking about La Rosalía");
	
