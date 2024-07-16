-- views

use ecomoda;

-- esta view sirve para la gente que trabaja en la bodega ya que no le interesa el valor de los materiales para realizar su trabajo, solo la cantidad.
Create view view_material as 
Select id_material, cantidad, descripcion
From materiales;
-- esta view sirve para la gente que trabaja en la bodega ya que no le interesa el valor de los productos para realizar su trabajo, solo la cantidad.
Create view view_producto  as 
Select id_producto, cantidad, descripcion
From productos;

-- funciones
-- Esta funcion sirve para conocer el saldo total de las cuentas por pagar pendientes(no saldadas)

DELIMITER $$

CREATE FUNCTION fn_cuentas_pagar(
    param_estado VARCHAR(20)
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total_valor DECIMAL(10,2);
    IF param_estado = 'por pagar' THEN
        SELECT SUM(valor) INTO total_valor 
        FROM cuentas_cobrar
        WHERE estado = 'por pagar';
    ELSEIF param_estado = 'saldada' THEN
        SELECT SUM(valor) INTO total_valor
        FROM cuentas_cobrar
        WHERE estado = 'saldada';
    ELSE
        SET total_valor = 0;  
    END IF;
    
    RETURN total_valor;
END$$

DELIMITER ;

SELECT fn_cuentas_pagar('por pagar') AS total_por_pagar;
SELECT fn_cuentas_pagar('saldada') AS total_saldada;

-- esta funcion sirve para conocer el saldo total de las cuentas por cobrar pendientes(no saldadas)

DELIMITER $$
DROP FUNCTION IF EXISTS fn_cuentas_cobrar;
CREATE FUNCTION fn_cuentas_cobrar(
    param_estado VARCHAR(20)
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total_valor DECIMAL(10,2);
    IF param_estado = 'por cobrar' THEN
        SELECT SUM(valor) INTO total_valor
        FROM cuentas_cobrar
        WHERE estado = 'por cobrar';
    ELSEIF param_estado = 'saldada' THEN
        SELECT SUM(valor) INTO total_valor
        FROM cuentas_cobrar
        WHERE estado = 'saldada';
    ELSE
        SET total_valor = 0;  
    END IF;
    
    RETURN total_valor;
END$$

DELIMITER ;

SELECT fn_cuentas_cobrar('por cobrar') AS total_por_cobrar;
SELECT fn_cuentas_cobrar('saldada') AS total_saldada;




-- stored procedure

-- este stored procedure inserta valores en orden compra
DELIMITER //

CREATE PROCEDURE InsertOrdenCompra(
    IN id_orden_compra_param INT,
    IN nombre_proveedor_param VARCHAR(25),
    IN id_material_param INT,
    IN cantidad_param INT,
    IN precio_param DOUBLE
)
BEGIN
    DECLARE foreign_key_violation CONDITION FOR SQLSTATE '23000';
    DECLARE CONTINUE HANDLER FOR foreign_key_violation
        SELECT 'Error: Foreign key constraint violation';

    INSERT INTO orden_compra (id_orden_compra, nombre_proveedor, id_material, cantidad, precio)
    VALUES (id_orden_compra_param, nombre_proveedor_param, id_material_param, cantidad_param, precio_param);
    
    SELECT 'Orden de Compra inserted successfully' AS Message;
END //

DELIMITER ;

-- este trigger inserta valores en orden_venta
DELIMITER //

CREATE PROCEDURE InsertOrdenVenta(
    IN id_orden_venta_param INT,
    IN nombre_cliente_param VARCHAR(45),
    IN id_producto_param INT,
    IN descripcion_producto_param VARCHAR(45),
    IN cantidad_param INT,
    IN precio_param DOUBLE
)
BEGIN
    DECLARE foreign_key_violation CONDITION FOR SQLSTATE '23000';
    DECLARE CONTINUE HANDLER FOR foreign_key_violation
        SELECT 'Error: Foreign key constraint violation';

    INSERT INTO orden_venta (id_orden_venta, nombre_cliente, id_producto, descripcion_producto, cantidad, precio)
    VALUES (id_orden_venta_param, nombre_cliente_param, id_producto_param, descripcion_producto_param, cantidad_param, precio_param);
    
    SELECT 'Orden de Venta inserted successfully' AS Message;
END //

DELIMITER ;


USE ECOMODA;


-- Triggers

-- este trigger se activa cuando se inserta un valor en la tabla orden_compra y hace una actualizacion en la tabla materiales.
This trigger activates after a new row is inserted into the orden_compra table.
It updates the cantidad (quantity) in the materiales table by subtracting the cantidad from the new orden_compra entry.
DELIMITER //

CREATE TRIGGER update_materiales_on_insert
AFTER INSERT ON orden_compra
FOR EACH ROW
BEGIN
    UPDATE materiales
    SET cantidad = cantidad - NEW.cantidad
    WHERE id_material = NEW.id_material;
END //

DELIMITER ;

-- este trigger e activa cuando se inserta un valor en la tabla )orden_venta y hace una actualizacion en el estado  de la tabla cuentas_cobrara.

DELIMITER //

CREATE TRIGGER update_cuentas_cobrar_on_update
AFTER UPDATE ON orden_venta
FOR EACH ROW
BEGIN
    UPDATE cuentas_cobrar
    SET estado = 'saldada'
    WHERE documento_referencia = NEW.id_orden_venta AND valor = NEW.precio;
END //

DELIMITER ;