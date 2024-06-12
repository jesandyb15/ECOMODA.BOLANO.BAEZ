Drop schema IF exists ECOMODA;
create schema ECOMODA;
USE ECOMODA;

drop table if exists materiales;
create table materiales(
id_material int primary key auto_increment not null,
descripcion varchar(45) not null unique,
tipo ENUM("hilo", "tela"),
cantidad int not null,
precio Decimal(10,2) not null
);

Select * from materiales;
Drop table if exists proveedores;
create table proveedores(
nombre_proveedor varchar(25) not null,
id_material int not null,
descripcion_material varchar(45) not null references materiales(descripcion),
direccion varchar(45) not null,
telefono int not null,
Primary Key (nombre_proveedor),
FOREIGN KEY (id_material) REFERENCES materiales(id_material),
foreign key (descripcion_material) references materiales(descripcion)
);
select * from proveedores;

Drop table if exists orden_compra;
create table orden_compra(
id_orden_compra int auto_increment not null UNIQUE,
nombre_proveedor varchar(25) not null,
id_material int not null unique,
cantidad int not null,
precio double not null unique,
Primary key (id_orden_compra),
foreign key (nombre_proveedor) references proveedores(nombre_proveedor),
foreign key(id_material) references materiales(id_material)
);

SELECT * FROM orden_compra;

Drop table if exists productos;
create table productos(
id_producto int primary key auto_increment not null,
descripcion varchar(45) not null unique,
cantidad int not null,
precio_unidad double not null
);
Select * from productos;

use ecomoda;
Drop table if exists clientes;
create table clientes(
nombre_cliente varchar(45) primary key not null unique,
id_producto int not null,
descripcion_producto varchar(45) not null ,
direccion varchar(45) not null unique,
telefono int not null,
foreign key (id_producto) references productos(id_producto),
foreign key (descripcion_producto) references productos(descripcion)
);
Select * from clientes;

Drop table if exists orden_venta;
create table orden_venta(
id_orden_venta int auto_increment not null unique,
nombre_cliente varchar(45) not null,
id_producto int not null unique,
descripcion_producto varchar(45) not null ,
cantidad int not null unique,
precio double not null unique,
primary key (id_orden_venta),
foreign key (id_producto) references productos(id_producto),
foreign key (nombre_cliente) references clientes(nombre_cliente),
foreign key (descripcion_producto) references productos(descripcion)
);
select * from orden_venta;

drop table if exists orden_envio;
create table orden_envio(
id_orden_envio int auto_increment not null,
nombre_cliente varchar(45) not null,
direccion varchar(45) not null,
id_producto int not null,
cantidad int not null,
id_orden_venta_referencia int not null,
primary key(id_orden_envio),
constraint FK_cliente foreign key (nombre_cliente) references clientes(nombre_cliente),
constraint FK_direccion_envio foreign key (direccion) references clientes(direccion),
constraint FK_id_producto foreign key (id_producto) references orden_venta(id_producto),
constraint FK_cantidad foreign key (cantidad) references orden_venta(cantidad),
constraint FK_id_orden_venta_referencia foreign key (id_orden_venta_referencia) references orden_venta(id_orden_venta)
);
select * from orden_envio;

drop table if exists cuentas_cobrar;
create table cuentas_cobrar(
id_cuenta_cobrar int auto_increment primary key not null,
documento_referencia int not null ,
estado enum('por cobrar', 'saldada'),
valor double not null references orden_venta(precio),
articulo int not null references orden_venta(id_producto),
foreign key (documento_referencia) references orden_venta(id_orden_venta),
foreign key (valor) references orden_venta(precio),
foreign key (articulo) references orden_venta(id_producto)
);
select *from cuentas_cobrar;

drop table if exists cuentas_pagar;
create table cuentas_pagar(
id_cuentas_pagar int auto_increment primary key not null, 
documento_referencia int not null ,
estado enum('por pagar', 'saldada'),
valor double not null,
material int not null ,
foreign key (documento_referencia) references orden_compra(id_orden_compra),
foreign key (valor) references orden_compra(precio),
foreign key (material) references orden_compra(id_material)
);
select * from cuentas_pagar;


















 
