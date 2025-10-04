-- Ejercicio Procedimientos Almacenados
CREATE DATABASE Ejercicio4bd2;
USE Ejercicio4bd2;
-- Contexto:
-- Una plataforma de cursos en línea necesita gestionar la información sobre cursos, estudiantes, inscripciones y calificaciones.
-- Se requiere el diseño de la base de datos y la implementación de procedimientos almacenados para la gestión de datos.

-- Creación de las tablas
CREATE TABLE Cursos (
    id_curso INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion INT -- duración en horas
);

CREATE TABLE Estudiantes (
    id_estudiante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Inscripciones (
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    id_estudiante INT,
    id_curso INT,
    fecha_inscripcion DATE,
    FOREIGN KEY (id_estudiante) REFERENCES Estudiantes(id_estudiante),
    FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso)
);

CREATE TABLE Calificaciones (
    id_calificacion INT PRIMARY KEY AUTO_INCREMENT,
    id_inscripcion INT,
    nota DECIMAL(5,2),
    fecha_evaluacion DATE,
    FOREIGN KEY (id_inscripcion) REFERENCES Inscripciones(id_inscripcion)
);

-- Inserción de datos (10 registros por tabla)
INSERT INTO Cursos (nombre, descripcion, duracion) VALUES
('SQL Básico', 'Curso introductorio sobre SQL', 10),
('Python para Data Science', 'Aprendizaje de Python enfocado en análisis de datos', 20),
('Fundamentos de Redes', 'Conceptos básicos de redes de computadoras', 15),
('Java Avanzado', 'Curso avanzado de Java', 25),
('Cálculo I', 'Introducción al cálculo diferencial', 40),
('Machine Learning', 'Curso introductorio sobre aprendizaje automático', 30),
('Diseño Web con CSS', 'Aprendizaje de CSS para diseño web', 15),
('Administración de Bases de Datos', 'Curso sobre gestión de bases de datos', 25),
('Estructuras de Datos', 'Curso sobre estructuras de datos en programación', 35),
('Seguridad Informática', 'Fundamentos de ciberseguridad', 20);

INSERT INTO Estudiantes (nombre, correo) VALUES
('Juan Pérez', 'juan.perez@example.com'),
('María López', 'maria.lopez@example.com'),
('Carlos Ramírez', 'carlos.ramirez@example.com'),
('Ana Torres', 'ana.torres@example.com'),
('Luis Fernández', 'luis.fernandez@example.com'),
('Elena Díaz', 'elena.diaz@example.com'),
('Pedro Gómez', 'pedro.gomez@example.com'),
('Marta Ruiz', 'marta.ruiz@example.com'),
('Jorge Herrera', 'jorge.herrera@example.com'),
('Sofía Sánchez', 'sofia.sanchez@example.com');

INSERT INTO Inscripciones (id_estudiante, id_curso, fecha_inscripcion) VALUES
(1, 1, '2025-01-10'),
(2, 2, '2025-01-15'),
(3, 3, '2025-01-20'),
(4, 4, '2025-01-25'),
(5, 5, '2025-02-01'),
(6, 6, '2025-02-05'),
(7, 7, '2025-02-10'),
(8, 8, '2025-02-15'),
(9, 9, '2025-02-20'),
(10, 10, '2025-02-25');

INSERT INTO Calificaciones (id_inscripcion, nota, fecha_evaluacion) VALUES
(1, 85.5, '2025-03-01'),
(2, 90.0, '2025-03-02'),
(3, 75.8, '2025-03-03'),
(4, 88.2, '2025-03-04'),
(5, 92.5, '2025-03-05'),
(6, 80.3, '2025-03-06'),
(7, 85.0, '2025-03-07'),
(8, 78.9, '2025-03-08'),
(9, 88.6, '2025-03-09'),
(10, 91.2, '2025-03-10');

-- Procedimientos Almacenados
DELIMITER $$

-- CREATE
-- 1. Procedimiento para inscribir un estudiante en un curso
DROP PROCEDURE IF EXISTS inscribir_estudiante $$
CREATE PROCEDURE inscribir_estudiante(
  IN i_id_estudiante INT,
  IN i_id_curso INT,
  IN i_fecha_inscripcion DATE
)
BEGIN
  INSERT INTO Inscripciones(id_estudiante, id_curso, fecha_inscripcion) VALUES (i_id_estudiante, i_id_curso, i_fecha_inscripcion);
  SELECT LAST_INSERT_ID() AS id_inscripcion;
END $$

-- 2. Procedimiento para calcular el promedio de notas de un estudiante
DROP PROCEDURE IF EXISTS calcular_promedio $$
CREATE PROCEDURE calcular_promedio(IN c_id INT)
BEGIN
  SELECT AVG(c.nota) AS PROMEDIO FROM Calificaciones c INNER JOIN Inscripciones i WHERE i.id_estudiante = c_id;
END $$

-- 3. Procedimiento para obtener la lista de cursos en los que está inscrito un estudiante
DROP PROCEDURE IF EXISTS listar_cursos $$
CREATE PROCEDURE listar_cursos(IN l_id INT)
BEGIN
  SELECT * FROM Inscripciones WHERE id_estudiante = l_id;
END $$

-- 4. Procedimiento para actualizar la calificación de un estudiante en un curso
DROP PROCEDURE IF EXISTS actualizar_calificacion $$
CREATE PROCEDURE actualizar_calificacion(
  IN a_id_calificacion INT,
  IN a_id_inscripcion INT,
  IN a_nota DECIMAL(5,2),
  IN a_fecha_evaluacion DATE
)
BEGIN
  UPDATE Calificaciones
  SET id_inscripcion = a_id_inscripcion,
      nota = a_nota,
      fecha_evaluacion = a_fecha_evaluacion
  WHERE id_calificacion = a_id_calificacion;
END $$

-- 5. Procedimiento para eliminar la inscripción de un estudiante en un curso
DROP PROCEDURE IF EXISTS eliminar_estudiante_curso $$
CREATE PROCEDURE eliminar_estudiante_curso(IN e_id INT)
BEGIN
  DELETE FROM Inscripciones WHERE id_inscripcion = e_id;
END $$

DELIMITER $$

-- CALL inscribir_estudiante(10, 9, '2025-10-03');
-- CALL calcular_promedio(3);
-- CALL listar_cursos(5);
-- CALL actualizar_calificacion(4, 4, 80.00, '2025-03-04');
-- CALL eliminar_estudiante_curso(9);