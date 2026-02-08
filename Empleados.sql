
CREATE DATABASE EmpleadosDB;

USE EmpleadosDB;

CREATE table Puesto (
    puestoID INT PRIMARY KEY AUTO_INCREMENT,
    nombrePuesto VARCHAR(50),
    SalarioPorHora DECIMAL(10, 2)
);

CREATE TABLE Area (
    AreaID INT PRIMARY KEY AUTO_INCREMENT,
    NombreArea VARCHAR(50) NOT NULL,
    puestoA INT,
    FOREIGN KEY (puestoA) REFERENCES Puesto(puestoID) ON DELETE RESTRICT ON UPDATE CASCADE  
);  


CREATE TABLE Empleados (
    EmpleadoID INT PRIMARY KEY AUTO_INCREMENT,
    NombreCompleto VARCHAR(50) NOT NULL,
    FechaDeIngreso DATE,
    CURP VARCHAR(50),
    Area INT,
    Puesto INT,
    HoraDeEntrada TIME,
    RetardoPermitido INT,
    Activo TINYINT(1) DEFAULT 1,
    FOREIGN KEY (Puesto) REFERENCES Puesto(puestoID) ON DELETE RESTRICT ON UPDATE CASCADE ,  
    FOREIGN KEY (Area) REFERENCES Area(AreaID) ON DELETE RESTRICT ON UPDATE CASCADE     
    
);

    CREATE TABLE DiasDeDescanso (
        DescansoID INT PRIMARY KEY AUTO_INCREMENT,
        EmpleadoID INT,
        DiaSemana TINYINT UNSIGNED CHECK (DiaSemana BETWEEN 1 AND 7),
        UNIQUE (EmpleadoID, DiaSemana),
        FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID) ON DELETE CASCADE ON UPDATE CASCADE
    );


CREATE TABLE Asistencia (
    AsistenciaID INT PRIMARY KEY AUTO_INCREMENT,
    EmpleadoID INT,
    Fecha DATE,
    HoraDeEntrada TIME,
    HoraDeSalida TIME,
    Retardo INT,
    UNIQUE (EmpleadoID, Fecha),
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID) ON DELETE CASCADE ON UPDATE CASCADE
);  

CREATE TABLE FALTAS (
    FaltasID INT PRIMARY KEY AUTO_INCREMENT,
    EmpleadoID INT,
    Fecha DATE,
    Motivo VARCHAR(255) NOT NULL,
    UNIQUE (EmpleadoID, Fecha),
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID) ON DELETE CASCADE ON UPDATE CASCADE
);  

DELIMITER //

CREATE TRIGGER VerificarDiaDeDescansoAntesDeFalta
BEFORE INSERT ON FALTAS
FOR EACH ROW
BEGIN

    DECLARE dia INT;

    -- Obtener día de la semana (1=Lunes, 7=Domingo)
    SET dia = WEEKDAY(NEW.Fecha) + 1;

    IF EXISTS (
        SELECT 1
        FROM DiasDeDescanso
        WHERE EmpleadoID = NEW.EmpleadoID
        AND DiaSemana = dia
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede registrar una falta en día de descanso';

    END IF;

END//

DELIMITER ;