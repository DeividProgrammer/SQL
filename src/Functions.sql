DELIMITER // 
CREATE OR REPLACE FUNCTION totalCost (deliveryId INT) RETURNS DOUBLE
	BEGIN
		DECLARE productCost DOUBLE;
		DECLARE shipCost DOUBLE;
		DECLARE totalCost DOUBLE;

		SET productCost = (SELECT sum(p.price*da.numberofproducts)
								FROM deliveries d JOIN deliveryamounts da
									ON (d.deliveryId=da.deliveryId)
								JOIN products p
									ON (p.productId=da.productId)
								WHERE d.deliveryId=deliveryId);


		SET shipCost = (SELECT d.shippingCost FROM deliveries d
								WHERE d.deliveryId = deliveryId);
		
		SET totalCost = productCost;
		IF productCost<25 THEN
				SET totalCost = shipCost+productCost;
		END IF;
		RETURN totalCost;
	END //

SELECT deliveryId,totalCost(deliveryId) FROM deliveries //
 
delimiter //
CREATE OR REPLACE FUNCTION MostOrderedProduct() RETURNS INT
	BEGIN 
		RETURN (SELECT p.productId FROM products p
			JOIN deliveryamounts da ON(da.productId=p.productId)
			GROUP BY p.productId
			ORDER BY SUM(numberOfProducts) DESC 
			LIMIT 1);
	END //

SELECT  MostOrderedProduct()//



CREATE OR REPLACE FUNCTION mostExpensiveDelivery() RETURNS INT
	BEGIN  
		RETURN (SELECT deliveryId FROM deliveries ORDER BY totalCost(deliveryId) DESC LIMIT 1);
	END //



SELECT mostExpensiveDelivery()//
-- Un repartidor es un el mejor y si tienes las mejores valoraciones. 
CREATE OR REPLACE FUNCTION bestDeliveryPeliveryPersonCurrentlyWorking() RETURNS INT
	BEGIN 
		RETURN (SELECT dp.deliveryPersonId FROM workinghours wh
			JOIN deliverypeople dp ON(wh.workingHoursId=dp.workingHoursId)
			JOIN deliveryassessments da ON (dp.deliveryPersonId=da.deliveryPersonId)
			WHERE CURTIME() BETWEEN wh.startingHour AND wh.endingHour
			GROUP BY dp.deliveryPersonId
			ORDER BY AVG(da.ratingDeliveryPerson) DESC  
			LIMIT 1);
	
	END //
SELECT bestDeliveryPeliveryPersonCurrentlyWorking() //
