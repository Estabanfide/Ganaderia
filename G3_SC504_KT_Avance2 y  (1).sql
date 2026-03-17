 
----Grupo 3-----
---Autores: Keily Nuñez Chaves, Dylan Jhoel Brenes Valverde, Pablo Andres Rodriguez, Isaac Serrano ----




---------Secuencia para usuarios---------
CREATE SEQUENCE seq_usuario START WITH 1 INCREMENT BY 1;

--------Secuencia para fincas---------
CREATE SEQUENCE seq_finca START WITH 1 INCREMENT BY 1;

--------Secuencia para potreros--------
CREATE SEQUENCE seq_potrero START WITH 1 INCREMENT BY 1;

----------Secuencia para animales------------
CREATE SEQUENCE seq_animal START WITH 1 INCREMENT BY 1;

-------------Secuencia para vacunas-------
CREATE SEQUENCE seq_vacuna START WITH 1 INCREMENT BY 1;

-----------Secuencia para costos-------
CREATE SEQUENCE seq_costo START WITH 1 INCREMENT BY 1;

--------Secuencia para eventos reproductivos--------
CREATE SEQUENCE seq_evento START WITH 1 INCREMENT BY 1;

---------------Secuencia para tabla de auditoría de movimientos--------
CREATE SEQUENCE seq_mov START WITH 1 INCREMENT BY 1;




-------Tabla de usuarios del sistema--------

CREATE TABLE usuarios (
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    email VARCHAR2(120),
    fecha_registro DATE DEFAULT SYSDATE
);


-------Tabla de fincas---------

CREATE TABLE fincas(
    id_finca NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    ubicacion VARCHAR2(100)
);



-----Tabla de potreros------

CREATE TABLE potreros(
    id_potrero NUMBER PRIMARY KEY,
    id_finca NUMBER,
    nombre VARCHAR2(100),
    capacidad NUMBER,
    FOREIGN KEY(id_finca) REFERENCES fincas(id_finca)
);




------Tabla de animales--------

CREATE TABLE animales(
    id_animal NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    fecha_nac DATE,
    raza VARCHAR2(60),
    sexo VARCHAR2(1),
    tipo VARCHAR2(30),
    salud VARCHAR2(40),
    id_potrero NUMBER,
    FOREIGN KEY(id_potrero) REFERENCES potreros(id_potrero)
);


---------Tabla de Vacunas---------

CREATE TABLE vacunas(
    id_vacuna NUMBER PRIMARY KEY,
    nombre VARCHAR2(80)
);


------------Tabla de control de vacunación-----------

CREATE TABLE vacunacion(
    id_animal NUMBER,
    id_vacuna NUMBER,
    fecha_aplicacion DATE,
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal),
    FOREIGN KEY(id_vacuna) REFERENCES vacunas(id_vacuna)
);

-------------Tabla de costos por animal------------------

CREATE TABLE costos(
    id_costo NUMBER PRIMARY KEY,
    id_animal NUMBER,
    monto NUMBER,
    fecha_costo DATE DEFAULT SYSDATE,
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal)
);


--------Tabla de eventos reproductivos----------------

CREATE TABLE eventos_reproductivos(
    id_evento NUMBER PRIMARY KEY,
    id_animal NUMBER,
    fecha_evento DATE,
    tipo_evento VARCHAR2(40),
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal)
);


----------Tabla de auditoría de movimientos-------------

CREATE TABLE movimientos(
    id NUMBER PRIMARY KEY,
    accion VARCHAR2(100),
    usuario VARCHAR2(100),
    fecha DATE
);





----------Trigger para registrar INSERT, UPDATE y DELETE--------------
-----------en la tabla ANIMALES----------

CREATE OR REPLACE TRIGGER tg_auditoria_animales
AFTER INSERT OR UPDATE OR DELETE ON animales
FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
    v_accion  VARCHAR2(100);
BEGIN
    -- Obtener usuario actual
    SELECT USER INTO v_usuario FROM dual;

    -- Detectar operación
    IF INSERTING THEN
        v_accion := 'INSERT EN ANIMALES';
    ELSIF UPDATING THEN
        v_accion := 'UPDATE EN ANIMALES';
    ELSIF DELETING THEN
        v_accion := 'DELETE EN ANIMALES';
    END IF;

    -- Insertar registro en auditoría
    INSERT INTO movimientos (id, accion, usuario, fecha)
    VALUES (seq_mov.NEXTVAL, v_accion, v_usuario, SYSDATE);
END;
/



--------------------------------------------------------
-- Evita aplicar la misma vacuna a un animal en el mismo mes
--------------------------------------------------------
CREATE OR REPLACE TRIGGER tg_validar_vacunacion
BEFORE INSERT ON vacunacion
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    ---------------Contar vacunaciones repetidas en el último mes--------
    SELECT COUNT(*) INTO v_count
    FROM vacunacion
    WHERE id_animal = :NEW.id_animal
    AND id_vacuna = :NEW.id_vacuna
    AND fecha_aplicacion >= ADD_MONTHS(SYSDATE, -1);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
        'No puede aplicar la misma vacuna en el mismo mes.');
    END IF;
END;
/






--------------Retorna edad en años basada en fecha de nacimiento-------------

CREATE OR REPLACE FUNCTION fn_calcular_edad(pfecha DATE)
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, pfecha) / 12);
END;
/





------------------Suma total de costos asociados a un animal---------------

CREATE OR REPLACE FUNCTION fn_total_costos(pid NUMBER)
RETURN NUMBER IS
    total NUMBER;
BEGIN
    SELECT NVL(SUM(monto),0) INTO total
    FROM costos
    WHERE id_animal = pid;

    RETURN total;
END;
/





--------------SP para insertar un animal nuevo-------------------

CREATE OR REPLACE PROCEDURE sp_insertar_animal(
    pn VARCHAR2,
    pf DATE,
    pr VARCHAR2,
    ps VARCHAR2,
    pt VARCHAR2,
    psl VARCHAR2,
    pidp NUMBER
)
IS
BEGIN
    INSERT INTO animales
    VALUES(
        seq_animal.NEXTVAL,
        pn, pf, pr, ps, pt, psl, pidp
    );
END;
/




-----------SP para registrar costos---------

CREATE OR REPLACE PROCEDURE sp_registrar_costo(
    pid NUMBER,
    pmonto NUMBER
)
IS
BEGIN
    INSERT INTO costos
    VALUES(seq_costo.NEXTVAL, pid, pmonto, SYSDATE);
END;
/




---------------Lista animales con su edad usando un cursor-----------

CREATE OR REPLACE PROCEDURE sp_listar_animales IS
    CURSOR c_anim IS
        SELECT nombre, fn_calcular_edad(fecha_nac) AS edad
        FROM animales;
BEGIN
    FOR reg IN c_anim LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Animal: '||reg.nombre||' - Edad: '||reg.edad||' años'
        );
    END LOOP;
END;
/




-----------------SQL dinámico para búsqueda flexible------------

CREATE OR REPLACE PROCEDURE sp_busqueda_dinamica(
    pcolumna VARCHAR2,
    pvalor   VARCHAR2
)
IS
    v_sql VARCHAR2(500);
BEGIN
    v_sql := 'SELECT * FROM animales WHERE '||pcolumna||
             ' LIKE ''%'||pvalor||'%'' ';
    EXECUTE IMMEDIATE v_sql;
END;
/


-----------PAQUETE DEL SISTEMA GANADERO----------
CREATE OR REPLACE PACKAGE pkg_ganaderia AS
    PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2);
    FUNCTION edad_animal(p_id NUMBER) RETURN NUMBER;
END pkg_ganaderia;
/

-----------CUERPO DEL PAQUETE--------
CREATE OR REPLACE PACKAGE BODY pkg_ganaderia AS

    ----------Inserta usuario validando email con REGEXP_LIKE--------
    PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2) IS
    BEGIN
        IF NOT REGEXP_LIKE(pe,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20002,'Email inválido');
        END IF;

        INSERT INTO usuarios VALUES(
            seq_usuario.NEXTVAL, pn, pe, SYSDATE
        );
    END insertar_usuario;

    --------Obtener edad desde pkg-------------
    FUNCTION edad_animal(p_id NUMBER)
    RETURN NUMBER
    IS
        v_fecha_nac DATE;
        v_edad      NUMBER;
    BEGIN
        SELECT fecha_nac
        INTO v_fecha_nac
        FROM animales
        WHERE id_animal = p_id;

        v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);

        RETURN v_edad;
    END edad_animal;

END pkg_ganaderia;
/

---------------------------------
---SELECT-----------------
SELECT table_name 
FROM user_tables;

SELECT * FROM fincas;

SELECT * FROM potreros;

SELECT * FROM animales;

SELECT * FROM vacunas;

SELECT * FROM costos;

SELECT * FROM eventos_reproductivos;

SELECT * FROM movimientos;

----para ver los movimeintos generados por los triggers
SELECT * FROM movimientos ORDER BY fecha DESC;

SELECT trigger_name, status 
FROM user_triggers;

SELECT object_name 
FROM user_objects
WHERE object_type = 'FUNCTION';

SELECT object_name 
FROM user_objects
WHERE object_type = 'PROCEDURE';


----Datos de Finca----
INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'La Mestiza', 'San Carlos');
INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'El Porvenir', 'Guanacaste');

----Datos de Potreros----
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Norte', 25);
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Sur', 30);
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 2, 'Potrero Valle', 15);

-----Animales-----
INSERT INTO animales VALUES (1, 'Luna', DATE '2020-03-10', 'Holstein', 'H', 'Leche', 'Sana', 1);
INSERT INTO animales VALUES (2, 'Bruno', DATE '2019-07-22', 'Brahman', 'M', 'Carne', 'Sano', 2);
INSERT INTO animales VALUES (3, 'Estrella', DATE '2021-01-15', 'Jersey', 'H', 'Leche', 'En tratamiento', 3);

-----Vacunas----
INSERT INTO vacunas VALUES (1, 'Fiebre Aftosa');
INSERT INTO vacunas VALUES (2, 'Brucelosis');
INSERT INTO vacunas VALUES (3, 'Rabia');

----Vacunacion----
INSERT INTO vacunacion VALUES (1, 1, SYSDATE);
INSERT INTO vacunacion VALUES (2, 2, SYSDATE);
INSERT INTO vacunacion VALUES (3, 3, SYSDATE);

----Costos---
INSERT INTO costos VALUES (1, 1, 15000, SYSDATE);
INSERT INTO costos VALUES (2, 1, 8000, SYSDATE);
INSERT INTO costos VALUES (3, 2, 20000, SYSDATE);

-----Eventos Reproductivos-------
INSERT INTO eventos_reproductivos VALUES (1, 1, SYSDATE, 'Inseminación');
INSERT INTO eventos_reproductivos VALUES (2, 1, SYSDATE - 90, 'Palpación');
INSERT INTO eventos_reproductivos VALUES (3, 2, SYSDATE - 30, 'Monta Natural');


----Grupo 3-----
---Autores: Keily Nuñez Chaves, Dylan Jhoel Brenes Valverde, Pablo Andres Rodriguez, Isaac Serrano ----




---------Secuencia para usuarios---------
CREATE SEQUENCE seq_usuario START WITH 1 INCREMENT BY 1;

--------Secuencia para fincas---------
CREATE SEQUENCE seq_finca START WITH 1 INCREMENT BY 1;

--------Secuencia para potreros--------
CREATE SEQUENCE seq_potrero START WITH 1 INCREMENT BY 1;

----------Secuencia para animales------------
CREATE SEQUENCE seq_animal START WITH 1 INCREMENT BY 1;

-------------Secuencia para vacunas-------
CREATE SEQUENCE seq_vacuna START WITH 1 INCREMENT BY 1;

-----------Secuencia para costos-------
CREATE SEQUENCE seq_costo START WITH 1 INCREMENT BY 1;

--------Secuencia para eventos reproductivos--------
CREATE SEQUENCE seq_evento START WITH 1 INCREMENT BY 1;

---------------Secuencia para tabla de auditoría de movimientos--------
CREATE SEQUENCE seq_mov START WITH 1 INCREMENT BY 1;




-------Tabla de usuarios del sistema--------

CREATE TABLE usuarios (
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    email VARCHAR2(120),
    fecha_registro DATE DEFAULT SYSDATE
);


-------Tabla de fincas---------

CREATE TABLE fincas(
    id_finca NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    ubicacion VARCHAR2(100)
);



-----Tabla de potreros------

CREATE TABLE potreros(
    id_potrero NUMBER PRIMARY KEY,
    id_finca NUMBER,
    nombre VARCHAR2(100),
    capacidad NUMBER,
    FOREIGN KEY(id_finca) REFERENCES fincas(id_finca)
);




------Tabla de animales--------

CREATE TABLE animales(
    id_animal NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    fecha_nac DATE,
    raza VARCHAR2(60),
    sexo VARCHAR2(1),
    tipo VARCHAR2(30),
    salud VARCHAR2(40),
    id_potrero NUMBER,
    FOREIGN KEY(id_potrero) REFERENCES potreros(id_potrero)
);


---------Tabla de Vacunas---------

CREATE TABLE vacunas(
    id_vacuna NUMBER PRIMARY KEY,
    nombre VARCHAR2(80)
);


------------Tabla de control de vacunación-----------

CREATE TABLE vacunacion(
    id_animal NUMBER,
    id_vacuna NUMBER,
    fecha_aplicacion DATE,
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal),
    FOREIGN KEY(id_vacuna) REFERENCES vacunas(id_vacuna)
);

-------------Tabla de costos por animal------------------

CREATE TABLE costos(
    id_costo NUMBER PRIMARY KEY,
    id_animal NUMBER,
    monto NUMBER,
    fecha_costo DATE DEFAULT SYSDATE,
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal)
);


--------Tabla de eventos reproductivos----------------

CREATE TABLE eventos_reproductivos(
    id_evento NUMBER PRIMARY KEY,
    id_animal NUMBER,
    fecha_evento DATE,
    tipo_evento VARCHAR2(40),
    FOREIGN KEY(id_animal) REFERENCES animales(id_animal)
);


----------Tabla de auditoría de movimientos-------------

CREATE TABLE movimientos(
    id NUMBER PRIMARY KEY,
    accion VARCHAR2(100),
    usuario VARCHAR2(100),
    fecha DATE
);





----------Trigger para registrar INSERT, UPDATE y DELETE--------------
-----------en la tabla ANIMALES----------

CREATE OR REPLACE TRIGGER tg_auditoria_animales
AFTER INSERT OR UPDATE OR DELETE ON animales
FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
    v_accion  VARCHAR2(100);
BEGIN
    -- Obtener usuario actual
    SELECT USER INTO v_usuario FROM dual;

    -- Detectar operación
    IF INSERTING THEN
        v_accion := 'INSERT EN ANIMALES';
    ELSIF UPDATING THEN
        v_accion := 'UPDATE EN ANIMALES';
    ELSIF DELETING THEN
        v_accion := 'DELETE EN ANIMALES';
    END IF;

    -- Insertar registro en auditoría
    INSERT INTO movimientos (id, accion, usuario, fecha)
    VALUES (seq_mov.NEXTVAL, v_accion, v_usuario, SYSDATE);
END;
/



--------------------------------------------------------
-- Evita aplicar la misma vacuna a un animal en el mismo mes
--------------------------------------------------------
CREATE OR REPLACE TRIGGER tg_validar_vacunacion
BEFORE INSERT ON vacunacion
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    ---------------Contar vacunaciones repetidas en el último mes--------
    SELECT COUNT(*) INTO v_count
    FROM vacunacion
    WHERE id_animal = :NEW.id_animal
    AND id_vacuna = :NEW.id_vacuna
    AND fecha_aplicacion >= ADD_MONTHS(SYSDATE, -1);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
        'No puede aplicar la misma vacuna en el mismo mes.');
    END IF;
END;
/







--------------Retorna edad en años basada en fecha de nacimiento-------------

CREATE OR REPLACE FUNCTION fn_calcular_edad(pfecha DATE)
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, pfecha) / 12);
END;
/





------------------Suma total de costos asociados a un animal---------------

CREATE OR REPLACE FUNCTION fn_total_costos(pid NUMBER)
RETURN NUMBER IS
    total NUMBER;
BEGIN
    SELECT NVL(SUM(monto),0) INTO total
    FROM costos
    WHERE id_animal = pid;

    RETURN total;
END;
/






--------------SP para insertar un animal nuevo-------------------

CREATE OR REPLACE PROCEDURE sp_insertar_animal(
    pn VARCHAR2,
    pf DATE,
    pr VARCHAR2,
    ps VARCHAR2,
    pt VARCHAR2,
    psl VARCHAR2,
    pidp NUMBER
)
IS
BEGIN
    INSERT INTO animales
    VALUES(
        seq_animal.NEXTVAL,
        pn, pf, pr, ps, pt, psl, pidp
    );
END;
/




-----------SP para registrar costos---------

CREATE OR REPLACE PROCEDURE sp_registrar_costo(
    pid NUMBER,
    pmonto NUMBER
)
IS
BEGIN
    INSERT INTO costos
    VALUES(seq_costo.NEXTVAL, pid, pmonto, SYSDATE);
END;
/




---------------Lista animales con su edad usando un cursor-----------

CREATE OR REPLACE PROCEDURE sp_listar_animales IS
    CURSOR c_anim IS
        SELECT nombre, fn_calcular_edad(fecha_nac) AS edad
        FROM animales;
BEGIN
    FOR reg IN c_anim LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Animal: '||reg.nombre||' - Edad: '||reg.edad||' años'
        );
    END LOOP;
END;
/





-----------------SQL dinámico para búsqueda flexible------------

CREATE OR REPLACE PROCEDURE sp_busqueda_dinamica(
    pcolumna VARCHAR2,
    pvalor   VARCHAR2
)
IS
    v_sql VARCHAR2(500);
BEGIN
    v_sql := 'SELECT * FROM animales WHERE '||pcolumna||
             ' LIKE ''%'||pvalor||'%'' ';
    EXECUTE IMMEDIATE v_sql;
END;
/







-----------PAQUETE DEL SISTEMA GANADERO----------

CREATE OR REPLACE PACKAGE pkg_ganaderia AS
    PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2);
    FUNCTION edad_animal(pid NUMBER) RETURN NUMBER;
END;
/


-----------CUERPO DEL PAQUETE--------

CREATE OR REPLACE PACKAGE BODY pkg_ganaderia AS


    ----------Inserta usuario validando email con REGEXP_LIKE--------
   
 CREATE OR REPLACE PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2) IS
    BEGIN
        IF NOT REGEXP_LIKE(pe,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20002,'Email inválido');
        END IF;

        INSERT INTO usuarios VALUES(
            seq_usuario.NEXTVAL, pn, pe, SYSDATE
        );
    END;

   
    --------Obtener edad desde pkg-------------
    
CREATE OR REPLACE FUNCTION edad_animal(p_id NUMBER)
RETURN NUMBER
IS
    v_fecha_nac DATE;
    v_edad      NUMBER;
BEGIN
    -- Obtener la fecha de nacimiento del animal
    SELECT fecha_nac
    INTO v_fecha_nac
    FROM animales
    WHERE id_animal = p_id;

    -- Calcular edad en años
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);

    RETURN v_edad;
END edad_animal;
/
---------------------------------
---SELECT-----------------
SELECT table_name 
FROM user_tables;

SELECT * FROM fincas;

SELECT * FROM potreros;

SELECT * FROM animales

SELECT * FROM vacunas;

SELECT * FROM costos;

SELECT * FROM eventos_reproductivos;

SELECT * FROM movimientos;

----para ver los movimeintos generados por los triggers
SELECT * FROM movimientos ORDER BY fecha DESC;

SELECT trigger_name, status 
FROM user_triggers;

SELECT object_name 
FROM user_objects
WHERE object_type = 'FUNCTION'

SELECT object_name 
FROM user_objects
WHERE object_type = 'PROCEDURE';


----Datos de Finca----
INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'La Mestiza', 'San Carlos');
INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'El Porvenir', 'Guanacaste');

----Datos de Potreros----
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Norte', 25);
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Sur', 30);
INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 2, 'Potrero Valle', 15);

-----Animales-----
INSERT INTO animales VALUES (1, 'Luna', DATE '2020-03-10', 'Holstein', 'H', 'Leche', 'Sana', 1);
INSERT INTO animales VALUES (2, 'Bruno', DATE '2019-07-22', 'Brahman', 'M', 'Carne', 'Sano', 2);
INSERT INTO animales VALUES (3, 'Estrella', DATE '2021-01-15', 'Jersey', 'H', 'Leche', 'En tratamiento', 3);

-----Vacunas----
INSERT INTO vacunas VALUES (1, 'Fiebre Aftosa');
INSERT INTO vacunas VALUES (2, 'Brucelosis');
INSERT INTO vacunas VALUES (3, 'Rabia');

----Vacunacion----
INSERT INTO vacunacion VALUES (1, 1, SYSDATE);
INSERT INTO vacunacion VALUES (2, 2, SYSDATE);
INSERT INTO vacunacion VALUES (3, 3, SYSDATE);

----Costos---
INSERT INTO costos VALUES (1, 1, 15000, SYSDATE);
INSERT INTO costos VALUES (2, 1, 8000, SYSDATE);
INSERT INTO costos VALUES (3, 2, 20000, SYSDATE);

-----Eventos Reproductivos-------
INSERT INTO eventos_reproductivos VALUES (1, 1, SYSDATE, 'Inseminación');
INSERT INTO eventos_reproductivos VALUES (2, 1, SYSDATE - 90, 'Palpación');
INSERT INTO eventos_reproductivos VALUES (3, 2, SYSDATE - 30, 'Monta Natural');





