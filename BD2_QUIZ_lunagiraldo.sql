-- Ejercicio Procedimientos y Vistas 
-- Contexto:
-- Un sistema de gestión de un GIMNASIO con varias sedes necesita administrar instructores,
-- clientes, clases grupales y reservas. Se requiere el diseño básico de la base de datos
-- y la implementación de 3 procedimientos almacenados y 2 vistas para apoyar la operación.
CREATE DATABASE QuizCorte2;
-- DROP DATABASE QuizCorte2;
USE QuizCorte2;
-- ------------------------------------------------------------
-- Creación del esquema base (MySQL 8+)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS Reservas;
DROP TABLE IF EXISTS Clases;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Instructores;
DROP TABLE IF EXISTS Sedes;

CREATE TABLE Sedes (
    id_sede INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);

CREATE TABLE Instructores (
    id_instructor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(80),
    correo VARCHAR(120) UNIQUE NOT NULL
);

CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    membresia ENUM('BASICA','PREMIUM') NOT NULL DEFAULT 'BASICA'
);

CREATE TABLE Clases (
    id_clase INT PRIMARY KEY AUTO_INCREMENT,
    id_sede INT NOT NULL,
    id_instructor INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    cupo INT NOT NULL CHECK (cupo > 0),
    fecha_hora DATETIME NOT NULL,
    duracion_min INT NOT NULL CHECK (duracion_min > 0),
    FOREIGN KEY (id_sede) REFERENCES Sedes(id_sede),
    FOREIGN KEY (id_instructor) REFERENCES Instructores(id_instructor)
);

CREATE TABLE Reservas (
    id_reserva INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_clase INT NOT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('RESERVADA','CANCELADA','ASISTIDA') NOT NULL DEFAULT 'RESERVADA',
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_clase) REFERENCES Clases(id_clase),
    UNIQUE KEY uq_reserva_unica (id_cliente, id_clase) -- un cliente no puede reservar dos veces la misma clase
);

-- ------------------------------------------------------------
-- Inserción de datos mínimos de prueba 
-- ------------------------------------------------------------
INSERT INTO Sedes (nombre, direccion) VALUES
('Centro', 'Calle 10 #5-20'),
('Norte', 'Av. 3N #45-12'),
('Sur', 'Cra. 80 #30-55'),
('Occidente', 'Transv. 5 #72-10'),
('Oriente', 'Calle 50 #12-34');

INSERT INTO Instructores (nombre, especialidad, correo) VALUES
('Laura Díaz', 'Spinning', 'laura.diaz@gym.com'),
('Carlos Rojas', 'CrossFit', 'carlos.rojas@gym.com'),
('Andrea Méndez', 'Yoga', 'andrea.mendez@gym.com'),
('Diego Pardo', 'HIIT', 'diego.pardo@gym.com'),
('Sofía Martínez', 'Pilates', 'sofia.martinez@gym.com');

INSERT INTO Clientes (nombre, correo, membresia) VALUES
('Juan Pérez', 'juan.perez@correo.com', 'BASICA'),
('María López', 'maria.lopez@correo.com', 'PREMIUM'),
('Pedro Gómez', 'pedro.gomez@correo.com', 'BASICA'),
('Ana Torres', 'ana.torres@correo.com', 'PREMIUM'),
('Luis Fernández', 'luis.fernandez@correo.com', 'BASICA');

-- Clases próximas (fechas de ejemplo)
INSERT INTO Clases (id_sede, id_instructor, nombre, cupo, fecha_hora, duracion_min) VALUES
(1, 1, 'Spinning AM', 10, '2025-10-10 07:00:00', 60),
(2, 2, 'CrossFit Power', 12, '2025-10-10 18:00:00', 50),
(3, 3, 'Yoga Flow', 15, '2025-10-11 08:00:00', 70),
(4, 4, 'HIIT Express', 8,  '2025-10-11 19:00:00', 30),
(5, 5, 'Pilates Core', 10, '2025-10-12 06:30:00', 55);

-- Reservas iniciales
INSERT INTO Reservas (id_cliente, id_clase, estado) VALUES
(1, 1, 'RESERVADA'),
(2, 1, 'ASISTIDA'),
(3, 2, 'RESERVADA'),
(4, 3, 'RESERVADA'),
(5, 4, 'CANCELADA');


-- ------------------------------------------------------------
-- Ejercicios 
-- (3 procedimientos + 2 vistas ya implementados)
-- ------------------------------------------------------------
-- E4 (VIEW): Consulta vw_clases_con_aforo para listar las clases con sus cupos disponibles
--     ordenadas por menor cupo disponible primero.
create view vw_clases_con_aforo as
select nombre, cupo from Clases order by cupo asc;
-- select * from vw_clases_con_aforo;

-- E5 (VIEW): Consulta vw_resumen_reservas_cliente para identificar qué clientes PREMIUM
--     presentan mayor número de cancelaciones.
create view vw_resumen_reservas_cliente as
select c.nombre, count(r.estado) as Clases_Canceladas from Clientes c, Reservas r where r.estado = 'CANCELADA' and c.membresia = 'PREMIUM' GROUP BY c.nombre;
-- select * from vw_resumen_reservas_cliente;


-- E1 (SP): Usa sp_reservar_clase para intentar reservar la clase 1 para el cliente 3.
--     Muestra el valor de p_cupos_restantes. Luego intenta reservar de nuevo y observa el error por duplicado.
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_reservar_clase $$
CREATE PROCEDURE sp_reservar_clase(
  IN i_id_cliente INT,
  IN i_id_clase INT
)
BEGIN
	INSERT INTO Reservas(id_cliente, id_clase, estado) VALUES (i_id_cliente, i_id_clase, default);
    update Clases set cupo = cupo-1 where id_clase = i_id_clase;
	select nombre as clases, cupo from Clases where id_clase = i_id_clase;
END $$
-- CALL sp_reservar_clase(3, 1);

-- E2 (SP): Marca una reserva existente como CANCELADA con sp_cancelar_reserva y
--     verifica el cambio consultando la vista vw_clases_con_aforo antes y después.
DROP PROCEDURE IF EXISTS sp_cancelar_reserva $$
CREATE PROCEDURE sp_cancelar_reserva(
	IN i_id_reserva INT
)
BEGIN
  UPDATE Reservas r, Clases c SET r.estado = 'CANCELADA', c.cupo = c.cupo+1  WHERE id_reserva = 6 and c.id_clase = r.id_clase;
END $$

-- E3 (SP): Calcula el porcentaje de asistencia del instructor 1 usando sp_porcentaje_asistencia_instructor.
--     Registra algunas reservas como ASISTIDA y vuelve a calcular para comparar.
DROP PROCEDURE IF EXISTS sp_porcentaje_asistencia_instructor $$
CREATE PROCEDURE sp_porcentaje_asistencia_instructor(
	IN i_id_instructor INT
)
BEGIN
  select ((c.cupo/100)*count(r.estado))*100 as porcentaje_asistencia from reservas r inner join clases c on  c.id_clase = r.id_clase inner join instructores i on i.id_instructor = c.id_instructor where r.estado = 'ASISTIDA' and i.id_instructor = i_id_instructor group by c.cupo;
END $$
DELIMITER $$
-- ------------------------------------------------------------
-- Entregable:
-- archivo en TXT  BD2_QUIZ_juanitoperez.txt
-- Sube el script a un repositorio público y envía el enlace al correo diego.prado.o@uniautonoma.edu.co
-- Asunto: Quiz - Procedimientos y Vistas (Gimnasio)
-- ------------------------------------------------------------

