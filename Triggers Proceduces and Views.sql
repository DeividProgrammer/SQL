DELIMITER //
CREATE OR REPLACE TRIGGER 
tStockBajo
AFTER  UPDATE ON Products FOR EACH ROW 
BEGIN 
	IF (NEW.stock='fewUnits') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
			'Se debe crear más stock de los productos';
		END IF;
END//
DELIMITER ;
#RN-03 Avisa al dueño de que en el producto seleccionado no hay Stock
DELIMITER //
CREATE OR REPLACE TRIGGER 
tStockAgotado
BEFORE  UPDATE ON Products FOR EACH ROW 
BEGIN 
	IF (NEW.stock='outOfStock') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
			'No hay stock de los productos seleccionados ';
		END IF;
END//
DELIMITER ;


# RN-05No acepta ordenes a no ser que el restaurante este AcceptingOrders
DELIMITER //
CREATE OR REPLACE TRIGGER 
tRestauranteDisponible 
BEFORE INSERT ON deliveries FOR EACH ROW 
BEGIN 
	DECLARE restaurantAvailabilitya ENUM ('PermanentlyClosed', 'AcceptingOrders', 'NotAcceptingOrders', 'TemporalyClosed');
	SET restaurantAvailabilitya = (SELECT restaurants.restaurantAvailability 
	 FROM restaurants WHERE (restaurants.restaurantID=deliveries.restaurantId));
	IF  (restaurantAvailabilitya !='AcceptingOrders') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede realizar pedidos al restaurante ';
	ELSE 
		UPDATE deliveries SET orderStatuts='sent';
	END IF;
END //
DELIMITER ;
#PA-07
DELIMITER //
CREATE OR REPLACE TRIGGER 
tCancelado
BEFORE UPDATE ON deliveries FOR EACH ROW 
BEGIN 
	IF (NEW.orderStatuts='cancelled') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
			'El pedido ha sido cancelado';
	END IF;
END//
DELIMITER ;

-- Quiero poder consultar un histórico de los pedidos realizados por los clientes en cada restaurante.
-- Para ver un ranking de los pedidos realizados en cada restaurante por los clientes y saber cuáles son los restaurantes más exitosos en cada momento.
-- CREATE OR REPLACE VIEW PedidosRealizadosPorRestaurante AS 
CREATE OR REPLACE VIEW ViewOrdersbyRestaurant AS
   SELECT clients.clientId, restaurants.restaurantID, deliveries.deliveryId
	FROM clients JOIN deliveries ON(clients.clientId = deliveries.clientId)
								JOIN deliveryamounts ON(deliveries.deliveryId = deliveryamounts.deliveryId)
								JOIN products ON(products.productId = deliveryamounts.productId)
								JOIN restaurants ON(restaurants.restaurantID = products.restaurantId);

SELECT restaurantId, COUNT(*) totalPedidos FROM viewordersbyrestaurant
	GROUP BY restaurantID;
								

--  consultar el stock de productos de los restaurantes que tienen en cada momento.
CREATE OR REPLACE VIEW stockRestaurantes AS
	SELECT r.restaurantID,p.productId,p.stock FROM restaurants r JOIN products p ON(r.restaurantID = p.restaurantId);

CREATE OR REPLACE VIEW restaurantsAssements AS 
	SELECT da.restaurantId,da.ratingRestaurant FROM deliveryassessments da;

CREATE OR REPLACE VIEW RawMaterialsOrders AS 
	SELECT suppliers.supplierID, rawmaterials.rawMaterialId, amounts.numberOfProducts, restaurants.restaurantID, restaurants.ownerId FROM suppliers
		JOIN rawmaterials ON (suppliers.supplierID=rawmaterials.supplierId)
		JOIN amounts ON(rawmaterials.rawMaterialId=amounts.rawMaterialId)
		JOIN restaurants ON (amounts.restaurantId = restaurants.restaurantID);
	

 -- -------------------------------- PROCEDIMIENTOS --------------------------------------


delimiter //
CREATE OR REPLACE PROCEDURE InsertClient(
	IuserName VARCHAR (12),
 	Iemail VARCHAR(50),
	`Ipassword` VARCHAR(30),
	IphoneNumber CHAR(9), 
	Ifullname VARCHAR (30),
	`IdeliveryAddress` VARCHAR (100),
	`IpaymentMethod` ENUM ('CreditCard','Paypal','Bizzum','Bitcoin'))
	
	BEGIN 
		INSERT INTO clients(userName , email , `password` ,phoneNumber , fullname, deliveryAddress, paymentMethod)
				VALUES(IuserName , Iemail , `Ipassword` ,IphoneNumber , Ifullname, IdeliveryAddress, IpaymentMethod);
	END //

-- CALL InsertClient('MaryDolo23','Dolores@dolomail.dol','1232',658154215,'Maria Dolores Real Borbon','Plaza España 9','BitCoin')//

-- ---------------------------- Ver pedidos mas recientes ---------
CREATE OR REPLACE PROCEDURE mostRecentDelivery()
	BEGIN 
		SELECT * FROM deliveries d ORDER BY d.deliveryDate LIMIT 1;
	END //

CALL mostRecentDelivery() //

-- ---------- Muestra los repartidores trabajando actualmente y sus numero de pedidos realizados ---
CREATE OR REPLACE PROCEDURE currentlyWorkingDP()
	BEGIN 
		SELECT dp.deliveryPersonId, COUNT(*) FROM  workinghours wh
			JOIN  deliverypeople dp ON(dp.workingHoursId=wh.workingHoursId)
			JOIN deliveries d ON (d.deliveryPersonId=dp.deliveryPersonId)
			WHERE CURTIME() BETWEEN wh.startingHour AND wh.endingHour
			GROUP BY dp.deliveryPersonId;
	END //

CALL currentlyWorkingDP() // 


-- Muestra el producto mas caro de cada restaurante .
CREATE OR REPLACE PROCEDURE mostExpensiveProduct()
	BEGIN 
		SELECT r.restaurantId,p.productId, MAX(p.price) FROM products p
			JOIN restaurants r ON(p.restaurantId=r.restaurantID)
			GROUP BY r.restaurantID;		
	END //

CALL mostExpensiveProduct()//


-- Quiero poder consultar un histórico de los pedidos realizados por los clientes en cada restaurante.
-- Para ver un ranking de los pedidos realizados en cada restaurante por los clientes y saber cuáles son los restaurantes más exitosos en cada momento.
-- CREATE OR REPLACE VIEW PedidosRealizadosPorRestaurante AS 
CREATE OR REPLACE VIEW ViewOrdersbyRestaurant AS
   SELECT clients.clientId, restaurants.restaurantID, deliveries.deliveryId
	FROM clients JOIN deliveries ON(clients.clientId = deliveries.clientId)
								JOIN deliveryamounts ON(deliveries.deliveryId = deliveryamounts.deliveryId)
								JOIN products ON(products.productId = deliveryamounts.productId)
								JOIN restaurants ON(restaurants.restaurantID = products.restaurantId);

SELECT restaurantId, COUNT(*) totalPedidos FROM viewordersbyrestaurant
	GROUP BY restaurantID;
								

--  consultar el stock de productos de los restaurantes que tienen en cada momento.
CREATE OR REPLACE VIEW stockRestaurantes AS
	SELECT r.restaurantID,p.productId,p.stock FROM restaurants r JOIN products p ON(r.restaurantID = p.restaurantId);

CREATE OR REPLACE VIEW restaurantsAssements AS 
	SELECT da.restaurantId,da.ratingRestaurant FROM deliveryassessments da;

CREATE OR REPLACE VIEW RawMaterialsOrders AS 
	SELECT suppliers.supplierID, rawmaterials.rawMaterialId, amounts.numberOfProducts, restaurants.restaurantID, restaurants.ownerId FROM suppliers
		JOIN rawmaterials ON (suppliers.supplierID=rawmaterials.supplierId)
		JOIN amounts ON(rawmaterials.rawMaterialId=amounts.rawMaterialId)
		JOIN restaurants ON (amounts.restaurantId = restaurants.restaurantID);
	

 -- -------------------------------- PROCEDIMIENTOS --------------------------------------


-- ---------------------------- Ver pedidos mas recientes ---------
CREATE OR REPLACE PROCEDURE mostRecentDelivery()
	BEGIN 
		SELECT * FROM deliveries d ORDER BY d.deliveryDate LIMIT 1;
	END //

CALL mostRecentDelivery() //

-- ---------- Muestra los repartidores trabajando actualmente y sus numero de pedidos realizados ---
CREATE OR REPLACE PROCEDURE currentlyWorkingDP()
	BEGIN 
		SELECT dp.deliveryPersonId, COUNT(*) FROM  workinghours wh
			JOIN  deliverypeople dp ON(dp.workingHoursId=wh.workingHoursId)
			JOIN deliveries d ON (d.deliveryPersonId=dp.deliveryPersonId)
			WHERE CURTIME() BETWEEN wh.startingHour AND wh.endingHour
			GROUP BY dp.deliveryPersonId;
	END //

CALL currentlyWorkingDP() // 


-- Muestra el producto mas caro de cada restaurante .
CREATE OR REPLACE PROCEDURE mostExpensiveProduct()
	BEGIN 
		SELECT r.restaurantId,p.productId, MAX(p.price) FROM products p
			JOIN restaurants r ON(p.restaurantId=r.restaurantID)
			GROUP BY r.restaurantID;		
	END //

CALL mostExpensiveProduct()//
