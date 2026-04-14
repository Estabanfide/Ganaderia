/*============================================================
  PROYECTO FINAL - LENGUAJES DE BASE DE DATOS (SC-504)
  Sistema de Gestión Ganadera - Happy Farmer / La Mestiza
  Universidad Fidelitas
  Profesor: Randall Leiton Jiménez
  I Cuatrimestre, 2026
  Integrantes:
    - Esteban Vado Monge
    - Isaac Serrano Lobo
============================================================*/


/* ========================================================
   SECCIÓN 1: SECUENCIAS
   ======================================================== */

-- Secuencia para tabla USUARIOS
CREATE SEQUENCE seq_usuario
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla FINCAS
CREATE SEQUENCE seq_finca
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla POTREROS
CREATE SEQUENCE seq_potrero
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla ANIMALES
CREATE SEQUENCE seq_animal
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla VACUNAS
CREATE SEQUENCE seq_vacuna
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla COSTOS
CREATE SEQUENCE seq_costo
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla EVENTOS_REPRODUCTIVOS
CREATE SEQUENCE seq_evento
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla MOVIMIENTOS (auditoría)
CREATE SEQUENCE seq_mov
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla PRODUCCION_LECHE
CREATE SEQUENCE seq_produccion
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Secuencia para tabla TRATAMIENTOS
CREATE SEQUENCE seq_tratamiento
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


/* ========================================================
   SECCIÓN 2: TABLAS (DDL)
   ======================================================== */

-- Tabla de usuarios del sistema
CREATE TABLE usuarios (
    id_usuario     NUMBER        CONSTRAINT pk_usuarios PRIMARY KEY,
    nombre         VARCHAR2(100) CONSTRAINT nn_usuarios_nombre NOT NULL,
    email          VARCHAR2(120) CONSTRAINT nn_usuarios_email NOT NULL,
    fecha_registro DATE          DEFAULT SYSDATE
);

-- Tabla de fincas
CREATE TABLE fincas (
    id_finca   NUMBER        CONSTRAINT pk_fincas PRIMARY KEY,
    nombre     VARCHAR2(100) CONSTRAINT nn_fincas_nombre NOT NULL,
    ubicacion  VARCHAR2(100)
);

-- Tabla de potreros
CREATE TABLE potreros (
    id_potrero NUMBER        CONSTRAINT pk_potreros PRIMARY KEY,
    id_finca   NUMBER        CONSTRAINT fk_potreros_finca
                                REFERENCES fincas(id_finca),
    nombre     VARCHAR2(100) CONSTRAINT nn_potreros_nombre NOT NULL,
    capacidad  NUMBER        CONSTRAINT ck_potreros_cap CHECK (capacidad > 0)
);

-- Tabla de animales
CREATE TABLE animales (
    id_animal  NUMBER        CONSTRAINT pk_animales PRIMARY KEY,
    nombre     VARCHAR2(100),
    fecha_nac  DATE,
    raza       VARCHAR2(60),
    sexo       VARCHAR2(1)   CONSTRAINT ck_animales_sexo CHECK (sexo IN ('M','F')),
    tipo       VARCHAR2(30),
    salud      VARCHAR2(40),
    id_potrero NUMBER        CONSTRAINT fk_animales_potrero
                                REFERENCES potreros(id_potrero)
);

-- Tabla catálogo de vacunas
CREATE TABLE vacunas (
    id_vacuna NUMBER        CONSTRAINT pk_vacunas PRIMARY KEY,
    nombre    VARCHAR2(80)  CONSTRAINT nn_vacunas_nombre NOT NULL
);

-- Tabla de control de vacunación (tabla relacional)
CREATE TABLE vacunacion (
    id_animal        NUMBER CONSTRAINT fk_vacunacion_animal
                              REFERENCES animales(id_animal),
    id_vacuna        NUMBER CONSTRAINT fk_vacunacion_vacuna
                              REFERENCES vacunas(id_vacuna),
    fecha_aplicacion DATE   DEFAULT SYSDATE,
    CONSTRAINT pk_vacunacion PRIMARY KEY (id_animal, id_vacuna, fecha_aplicacion)
);

-- Tabla de costos por animal
CREATE TABLE costos (
    id_costo   NUMBER        CONSTRAINT pk_costos PRIMARY KEY,
    id_animal  NUMBER        CONSTRAINT fk_costos_animal
                                REFERENCES animales(id_animal),
    monto      NUMBER(10,2)  CONSTRAINT ck_costos_monto CHECK (monto >= 0),
    descripcion VARCHAR2(200),
    fecha_costo DATE          DEFAULT SYSDATE
);

-- Tabla de eventos reproductivos
CREATE TABLE eventos_reproductivos (
    id_evento   NUMBER       CONSTRAINT pk_eventos PRIMARY KEY,
    id_animal   NUMBER       CONSTRAINT fk_eventos_animal
                                REFERENCES animales(id_animal),
    fecha_evento DATE,
    tipo_evento  VARCHAR2(40)
);

-- Tabla de producción de leche (nueva tabla para reportes)
CREATE TABLE produccion_leche (
    id_produccion NUMBER       CONSTRAINT pk_produccion PRIMARY KEY,
    id_animal     NUMBER       CONSTRAINT fk_produccion_animal
                                  REFERENCES animales(id_animal),
    fecha_registro DATE        DEFAULT SYSDATE,
    litros        NUMBER(6,2)  CONSTRAINT ck_prod_litros CHECK (litros >= 0)
);

-- Tabla de tratamientos veterinarios
CREATE TABLE tratamientos (
    id_tratamiento NUMBER       CONSTRAINT pk_tratamientos PRIMARY KEY,
    id_animal      NUMBER       CONSTRAINT fk_tratamiento_animal
                                   REFERENCES animales(id_animal),
    descripcion    VARCHAR2(300),
    fecha_inicio   DATE,
    fecha_fin      DATE,
    veterinario    VARCHAR2(100)
);

-- Tabla de auditoría de movimientos
CREATE TABLE movimientos (
    id       NUMBER        CONSTRAINT pk_movimientos PRIMARY KEY,
    accion   VARCHAR2(100),
    usuario  VARCHAR2(100),
    fecha    DATE          DEFAULT SYSDATE
);


/* ========================================================
   SECCIÓN 3: FUNCIONES (FUNCTIONS)
   ======================================================== */

-- Función 1: Calcula la edad de un animal en años dado su ID
CREATE OR REPLACE FUNCTION fn_edad_por_id(pid NUMBER)
RETURN NUMBER IS
    v_fecha DATE;
BEGIN
    SELECT fecha_nac INTO v_fecha
    FROM animales
    WHERE id_animal = pid;
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha) / 12);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_edad_por_id;
/

-- Función 2: Calcula la edad en años dado una fecha de nacimiento
CREATE OR REPLACE FUNCTION fn_calcular_edad(pfecha DATE)
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, pfecha) / 12);
END fn_calcular_edad;
/

-- Función 3: Suma total de costos acumulados de un animal
CREATE OR REPLACE FUNCTION fn_total_costos(pid NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(monto), 0)
    INTO v_total
    FROM costos
    WHERE id_animal = pid;
    RETURN v_total;
END fn_total_costos;
/

-- Función 4: Retorna la cantidad de animales en un potrero
CREATE OR REPLACE FUNCTION fn_animales_en_potrero(pid_potrero NUMBER)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM animales
    WHERE id_potrero = pid_potrero;
    RETURN v_count;
END fn_animales_en_potrero;
/

-- Función 5: Verifica si un potrero tiene capacidad disponible (1=sí, 0=no)
CREATE OR REPLACE FUNCTION fn_potrero_disponible(pid_potrero NUMBER)
RETURN NUMBER IS
    v_cap      NUMBER;
    v_ocupados NUMBER;
BEGIN
    SELECT capacidad INTO v_cap
    FROM potreros WHERE id_potrero = pid_potrero;

    v_ocupados := fn_animales_en_potrero(pid_potrero);

    IF v_ocupados < v_cap THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END fn_potrero_disponible;
/

-- Función 6: Retorna el total de litros producidos por un animal
CREATE OR REPLACE FUNCTION fn_total_produccion(pid NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(litros), 0)
    INTO v_total
    FROM produccion_leche
    WHERE id_animal = pid;
    RETURN v_total;
END fn_total_produccion;
/

-- Función 7: Cuenta vacunaciones recibidas por un animal
CREATE OR REPLACE FUNCTION fn_conteo_vacunas(pid NUMBER)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM vacunacion
    WHERE id_animal = pid;
    RETURN v_count;
END fn_conteo_vacunas;
/

-- Función 8: Formatea el nombre del animal con su ID
CREATE OR REPLACE FUNCTION fn_etiqueta_animal(pid NUMBER)
RETURN VARCHAR2 IS
    v_nombre VARCHAR2(100);
BEGIN
    SELECT nombre INTO v_nombre
    FROM animales WHERE id_animal = pid;
    RETURN 'ID-' || pid || ': ' || v_nombre;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Animal no encontrado';
END fn_etiqueta_animal;
/

-- Función 9: Retorna el estado de salud de un animal
CREATE OR REPLACE FUNCTION fn_salud_animal(pid NUMBER)
RETURN VARCHAR2 IS
    v_salud VARCHAR2(40);
BEGIN
    SELECT salud INTO v_salud
    FROM animales WHERE id_animal = pid;
    RETURN NVL(v_salud, 'No registrado');
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Animal no existe';
END fn_salud_animal;
/

-- Función 10: Verifica si email tiene formato válido (1=válido, 0=inválido)
CREATE OR REPLACE FUNCTION fn_validar_email(p_email VARCHAR2)
RETURN NUMBER IS
BEGIN
    IF REGEXP_LIKE(p_email,
       '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END fn_validar_email;
/

-- Función 11: Retorna la diferencia en días entre dos fechas
CREATE OR REPLACE FUNCTION fn_dias_entre(p_fecha1 DATE, p_fecha2 DATE)
RETURN NUMBER IS
BEGIN
    RETURN ABS(TRUNC(p_fecha2) - TRUNC(p_fecha1));
END fn_dias_entre;
/

-- Función 12: Retorna el nombre de la finca donde se ubica un animal
CREATE OR REPLACE FUNCTION fn_finca_de_animal(pid NUMBER)
RETURN VARCHAR2 IS
    v_nombre_finca VARCHAR2(100);
BEGIN
    SELECT f.nombre INTO v_nombre_finca
    FROM animales a
    JOIN potreros p ON a.id_potrero = p.id_potrero
    JOIN fincas f   ON p.id_finca = f.id_finca
    WHERE a.id_animal = pid;
    RETURN v_nombre_finca;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Sin asignación';
END fn_finca_de_animal;
/

-- Función 13: Determina la categoría de edad del animal
CREATE OR REPLACE FUNCTION fn_categoria_edad(pid NUMBER)
RETURN VARCHAR2 IS
    v_edad NUMBER;
BEGIN
    v_edad := fn_edad_por_id(pid);
    IF v_edad IS NULL THEN RETURN 'Desconocido';
    ELSIF v_edad < 1    THEN RETURN 'Ternero';
    ELSIF v_edad < 3    THEN RETURN 'Novillo';
    ELSE                     RETURN 'Adulto';
    END IF;
END fn_categoria_edad;
/

-- Función 14: Retorna promedio de litros de leche de un animal
CREATE OR REPLACE FUNCTION fn_promedio_produccion(pid NUMBER)
RETURN NUMBER IS
    v_prom NUMBER;
BEGIN
    SELECT NVL(ROUND(AVG(litros), 2), 0)
    INTO v_prom
    FROM produccion_leche
    WHERE id_animal = pid;
    RETURN v_prom;
END fn_promedio_produccion;
/

-- Función 15: Cuenta eventos reproductivos de un animal en el año actual
CREATE OR REPLACE FUNCTION fn_eventos_anio_actual(pid NUMBER)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM eventos_reproductivos
    WHERE id_animal = pid
      AND EXTRACT(YEAR FROM fecha_evento) = EXTRACT(YEAR FROM SYSDATE);
    RETURN v_count;
END fn_eventos_anio_actual;
/


/* ========================================================
   SECCIÓN 4: PROCEDIMIENTOS ALMACENADOS
   ======================================================== */

-- SP 1: Inserta un usuario validando formato de email
CREATE OR REPLACE PROCEDURE sp_insertar_usuario(
    pn  VARCHAR2,
    pe  VARCHAR2
) IS
BEGIN
    IF fn_validar_email(pe) = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Email inválido: ' || pe);
    END IF;
    INSERT INTO usuarios VALUES (seq_usuario.NEXTVAL, pn, pe, SYSDATE);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_insertar_usuario;
/

-- SP 2: Inserta un nuevo animal
CREATE OR REPLACE PROCEDURE sp_insertar_animal(
    pn   VARCHAR2,
    pf   DATE,
    pr   VARCHAR2,
    ps   VARCHAR2,
    pt   VARCHAR2,
    psl  VARCHAR2,
    pidp NUMBER
) IS
BEGIN
    IF fn_potrero_disponible(pidp) = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El potrero no tiene capacidad disponible.');
    END IF;
    INSERT INTO animales VALUES (
        seq_animal.NEXTVAL, pn, pf, pr, ps, pt, psl, pidp
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_insertar_animal;
/

-- SP 3: Registra un costo asociado a un animal
CREATE OR REPLACE PROCEDURE sp_registrar_costo(
    pid         NUMBER,
    pmonto      NUMBER,
    pdescripcion VARCHAR2 DEFAULT NULL
) IS
BEGIN
    INSERT INTO costos VALUES (
        seq_costo.NEXTVAL, pid, pmonto, pdescripcion, SYSDATE
    );
    COMMIT;
END sp_registrar_costo;
/

-- SP 4: Lista todos los animales con nombre, raza y edad usando cursor
CREATE OR REPLACE PROCEDURE sp_listar_animales IS
    CURSOR c_anim IS
        SELECT id_animal, nombre, raza, fn_calcular_edad(fecha_nac) AS edad,
               salud, tipo
        FROM animales
        ORDER BY nombre;
BEGIN
    FOR reg IN c_anim LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: '     || reg.id_animal ||
            ' | Nombre: ' || reg.nombre ||
            ' | Raza: '   || reg.raza   ||
            ' | Edad: '   || reg.edad   || ' años' ||
            ' | Tipo: '   || reg.tipo   ||
            ' | Salud: '  || reg.salud
        );
    END LOOP;
END sp_listar_animales;
/

-- SP 5: Registra la producción de leche de un animal
CREATE OR REPLACE PROCEDURE sp_registrar_produccion(
    pid    NUMBER,
    plitros NUMBER
) IS
BEGIN
    IF plitros < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Los litros no pueden ser negativos.');
    END IF;
    INSERT INTO produccion_leche
    VALUES (seq_produccion.NEXTVAL, pid, SYSDATE, plitros);
    COMMIT;
END sp_registrar_produccion;
/

-- SP 6: Registra un evento reproductivo
CREATE OR REPLACE PROCEDURE sp_registrar_evento(
    pid         NUMBER,
    pfecha      DATE,
    ptipo_evento VARCHAR2
) IS
BEGIN
    INSERT INTO eventos_reproductivos
    VALUES (seq_evento.NEXTVAL, pid, pfecha, ptipo_evento);
    COMMIT;
END sp_registrar_evento;
/

-- SP 7: Actualiza el estado de salud de un animal
CREATE OR REPLACE PROCEDURE sp_actualizar_salud(
    pid     NUMBER,
    pnuevo_estado VARCHAR2
) IS
BEGIN
    UPDATE animales
    SET salud = pnuevo_estado
    WHERE id_animal = pid;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Animal no encontrado: ID=' || pid);
    END IF;
    COMMIT;
END sp_actualizar_salud;
/

-- SP 8: Elimina un animal por su ID (solo si no tiene costos asociados)
CREATE OR REPLACE PROCEDURE sp_eliminar_animal(pid NUMBER) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM costos WHERE id_animal = pid;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006,
            'No se puede eliminar: el animal tiene ' || v_count || ' costos registrados.');
    END IF;
    DELETE FROM animales WHERE id_animal = pid;
    COMMIT;
END sp_eliminar_animal;
/

-- SP 9: Registra un tratamiento veterinario
CREATE OR REPLACE PROCEDURE sp_registrar_tratamiento(
    pid          NUMBER,
    pdescripcion VARCHAR2,
    pfecha_inicio DATE,
    pfecha_fin    DATE,
    pveterinario  VARCHAR2
) IS
BEGIN
    INSERT INTO tratamientos
    VALUES (seq_tratamiento.NEXTVAL, pid, pdescripcion,
            pfecha_inicio, pfecha_fin, pveterinario);
    COMMIT;
END sp_registrar_tratamiento;
/

-- SP 10: Búsqueda dinámica en animales por columna y valor
CREATE OR REPLACE PROCEDURE sp_busqueda_dinamica(
    pcolumna VARCHAR2,
    pvalor   VARCHAR2
) IS
    v_sql     VARCHAR2(500);
    v_cursor  SYS_REFCURSOR;
BEGIN
    v_sql := 'SELECT id_animal, nombre, raza, salud FROM animales WHERE '
             || DBMS_ASSERT.SIMPLE_SQL_NAME(pcolumna)
             || ' LIKE :val';
    OPEN v_cursor FOR v_sql USING '%' || pvalor || '%';
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Búsqueda dinámica ejecutada sobre columna: ' || pcolumna);
END sp_busqueda_dinamica;
/

-- SP 11: Inserta una finca nueva
CREATE OR REPLACE PROCEDURE sp_insertar_finca(
    pnombre    VARCHAR2,
    pubicacion VARCHAR2
) IS
BEGIN
    INSERT INTO fincas VALUES (seq_finca.NEXTVAL, pnombre, pubicacion);
    COMMIT;
END sp_insertar_finca;
/

-- SP 12: Inserta un potrero nuevo
CREATE OR REPLACE PROCEDURE sp_insertar_potrero(
    pid_finca  NUMBER,
    pnombre    VARCHAR2,
    pcapacidad NUMBER
) IS
BEGIN
    INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, pid_finca, pnombre, pcapacidad);
    COMMIT;
END sp_insertar_potrero;
/

-- SP 13: Mueve un animal de potrero
CREATE OR REPLACE PROCEDURE sp_mover_animal(
    pid_animal  NUMBER,
    pid_potrero NUMBER
) IS
BEGIN
    IF fn_potrero_disponible(pid_potrero) = 0 THEN
        RAISE_APPLICATION_ERROR(-20007,
            'El potrero destino está lleno.');
    END IF;
    UPDATE animales
    SET id_potrero = pid_potrero
    WHERE id_animal = pid_animal;
    COMMIT;
END sp_mover_animal;
/

-- SP 14: Reporte de costos por animal usando cursor explícito
CREATE OR REPLACE PROCEDURE sp_reporte_costos IS
    CURSOR c_costos IS
        SELECT a.nombre AS animal,
               fn_total_costos(a.id_animal) AS total_costo,
               fn_categoria_edad(a.id_animal) AS categoria
        FROM animales a
        ORDER BY total_costo DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== REPORTE DE COSTOS POR ANIMAL ===');
    FOR reg IN c_costos LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Animal: ' || RPAD(reg.animal, 15) ||
            ' | Categoría: ' || RPAD(reg.categoria, 10) ||
            ' | Costo Total: ₡' || TO_CHAR(reg.total_costo, 'FM999,990.00')
        );
    END LOOP;
END sp_reporte_costos;
/

-- SP 15: Listar animales con salud crítica
CREATE OR REPLACE PROCEDURE sp_animales_criticos IS
    CURSOR c_criticos IS
        SELECT id_animal, nombre, salud, fn_finca_de_animal(id_animal) AS finca
        FROM animales
        WHERE LOWER(salud) LIKE '%tratamiento%'
           OR LOWER(salud) LIKE '%crítico%'
           OR LOWER(salud) LIKE '%enfermo%';
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ANIMALES CON SALUD CRÍTICA ===');
    FOR reg IN c_criticos LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || reg.id_animal ||
            ' | Nombre: ' || reg.nombre ||
            ' | Salud: ' || reg.salud ||
            ' | Finca: ' || reg.finca
        );
    END LOOP;
END sp_animales_criticos;
/

-- SP 16: Registra una vacuna en el catálogo
CREATE OR REPLACE PROCEDURE sp_insertar_vacuna(
    pnombre VARCHAR2
) IS
BEGIN
    INSERT INTO vacunas VALUES (seq_vacuna.NEXTVAL, pnombre);
    COMMIT;
END sp_insertar_vacuna;
/

-- SP 17: Aplica vacuna a un animal (con validación de trigger)
CREATE OR REPLACE PROCEDURE sp_vacunar_animal(
    pid_animal NUMBER,
    pid_vacuna NUMBER
) IS
BEGIN
    INSERT INTO vacunacion VALUES (pid_animal, pid_vacuna, SYSDATE);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_vacunar_animal;
/

-- SP 18: Muestra resumen general del sistema
CREATE OR REPLACE PROCEDURE sp_resumen_sistema IS
    v_total_animales  NUMBER;
    v_total_fincas    NUMBER;
    v_total_potreros  NUMBER;
    v_total_usuarios  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_animales  FROM animales;
    SELECT COUNT(*) INTO v_total_fincas    FROM fincas;
    SELECT COUNT(*) INTO v_total_potreros  FROM potreros;
    SELECT COUNT(*) INTO v_total_usuarios  FROM usuarios;
    DBMS_OUTPUT.PUT_LINE('==== RESUMEN SISTEMA HAPPY FARMER ====');
    DBMS_OUTPUT.PUT_LINE('Fincas:    ' || v_total_fincas);
    DBMS_OUTPUT.PUT_LINE('Potreros:  ' || v_total_potreros);
    DBMS_OUTPUT.PUT_LINE('Animales:  ' || v_total_animales);
    DBMS_OUTPUT.PUT_LINE('Usuarios:  ' || v_total_usuarios);
END sp_resumen_sistema;
/

-- SP 19: Elimina registros de auditoría anteriores a una fecha
CREATE OR REPLACE PROCEDURE sp_limpiar_auditoria(pfecha DATE) IS
BEGIN
    DELETE FROM movimientos WHERE fecha < pfecha;
    DBMS_OUTPUT.PUT_LINE('Registros eliminados: ' || SQL%ROWCOUNT);
    COMMIT;
END sp_limpiar_auditoria;
/

-- SP 20: Actualiza ubicación de una finca
CREATE OR REPLACE PROCEDURE sp_actualizar_finca(
    pid        NUMBER,
    pnombre    VARCHAR2,
    pubicacion VARCHAR2
) IS
BEGIN
    UPDATE fincas
    SET nombre = pnombre, ubicacion = pubicacion
    WHERE id_finca = pid;
    COMMIT;
END sp_actualizar_finca;
/

-- SP 21: Listado de potreros con ocupación actual
CREATE OR REPLACE PROCEDURE sp_ocupacion_potreros IS
    CURSOR c_pot IS
        SELECT p.id_potrero, p.nombre, p.capacidad,
               fn_animales_en_potrero(p.id_potrero) AS ocupados,
               f.nombre AS finca
        FROM potreros p
        JOIN fincas f ON p.id_finca = f.id_finca;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== OCUPACIÓN DE POTREROS ===');
    FOR reg IN c_pot LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Finca: ' || RPAD(reg.finca, 15) ||
            ' | Potrero: ' || RPAD(reg.nombre, 15) ||
            ' | Ocupados: ' || reg.ocupados ||
            '/' || reg.capacidad
        );
    END LOOP;
END sp_ocupacion_potreros;
/

-- SP 22: Genera reporte de producción por animal en un rango de fechas
CREATE OR REPLACE PROCEDURE sp_reporte_produccion(
    p_desde DATE,
    p_hasta DATE
) IS
    CURSOR c_prod IS
        SELECT a.nombre, SUM(pl.litros) AS total_litros,
               COUNT(*) AS registros
        FROM produccion_leche pl
        JOIN animales a ON pl.id_animal = a.id_animal
        WHERE pl.fecha_registro BETWEEN p_desde AND p_hasta
        GROUP BY a.nombre
        ORDER BY total_litros DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRODUCCIÓN ' ||
        TO_CHAR(p_desde,'DD/MM/YYYY') || ' al ' ||
        TO_CHAR(p_hasta,'DD/MM/YYYY') || ' ===');
    FOR reg IN c_prod LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(reg.nombre, 15) ||
            ' | Litros: ' || TO_CHAR(reg.total_litros, 'FM9990.00') ||
            ' | Registros: ' || reg.registros
        );
    END LOOP;
END sp_reporte_produccion;
/

-- SP 23: Eliminar un potrero (solo si está vacío)
CREATE OR REPLACE PROCEDURE sp_eliminar_potrero(pid NUMBER) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM animales WHERE id_potrero = pid;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20008,
            'No se puede eliminar: el potrero tiene ' || v_count || ' animales.');
    END IF;
    DELETE FROM potreros WHERE id_potrero = pid;
    COMMIT;
END sp_eliminar_potrero;
/

-- SP 24: Historial de eventos reproductivos de un animal
CREATE OR REPLACE PROCEDURE sp_historial_reproductivo(pid NUMBER) IS
    CURSOR c_eventos IS
        SELECT tipo_evento, fecha_evento
        FROM eventos_reproductivos
        WHERE id_animal = pid
        ORDER BY fecha_evento DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== HISTORIAL REPRODUCTIVO - ' ||
        fn_etiqueta_animal(pid) || ' ===');
    FOR reg IN c_eventos LOOP
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(reg.fecha_evento, 'DD/MM/YYYY') ||
            ' | ' || reg.tipo_evento
        );
    END LOOP;
END sp_historial_reproductivo;
/

-- SP 25: Inserta datos de prueba (datos de demostración)
CREATE OR REPLACE PROCEDURE sp_cargar_datos_prueba IS
BEGIN
    -- Fincas
    INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'La Mestiza', 'San Carlos');
    INSERT INTO fincas VALUES (seq_finca.NEXTVAL, 'El Porvenir', 'Guanacaste');
    -- Potreros
    INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Norte', 25);
    INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 1, 'Potrero Sur', 30);
    INSERT INTO potreros VALUES (seq_potrero.NEXTVAL, 2, 'Potrero Valle', 15);
    -- Animales
    INSERT INTO animales VALUES (seq_animal.NEXTVAL, 'Luna',    DATE '2020-03-10', 'Holstein', 'F', 'Leche', 'Sana', 1);
    INSERT INTO animales VALUES (seq_animal.NEXTVAL, 'Bruno',   DATE '2019-07-22', 'Brahman',  'M', 'Carne', 'Sano', 2);
    INSERT INTO animales VALUES (seq_animal.NEXTVAL, 'Estrella',DATE '2021-01-15', 'Jersey',   'F', 'Leche', 'En tratamiento', 3);
    -- Vacunas
    INSERT INTO vacunas VALUES (seq_vacuna.NEXTVAL, 'Fiebre Aftosa');
    INSERT INTO vacunas VALUES (seq_vacuna.NEXTVAL, 'Brucelosis');
    INSERT INTO vacunas VALUES (seq_vacuna.NEXTVAL, 'Rabia');
    -- Vacunaciones
    INSERT INTO vacunacion VALUES (1, 1, SYSDATE - 60);
    INSERT INTO vacunacion VALUES (2, 2, SYSDATE - 45);
    INSERT INTO vacunacion VALUES (3, 3, SYSDATE - 30);
    -- Costos
    INSERT INTO costos VALUES (seq_costo.NEXTVAL, 1, 15000, 'Alimentación', SYSDATE - 5);
    INSERT INTO costos VALUES (seq_costo.NEXTVAL, 1,  8000, 'Medicamento',  SYSDATE - 3);
    INSERT INTO costos VALUES (seq_costo.NEXTVAL, 2, 20000, 'Alimentación', SYSDATE - 2);
    -- Producción de leche
    INSERT INTO produccion_leche VALUES (seq_produccion.NEXTVAL, 1, SYSDATE - 2, 18.5);
    INSERT INTO produccion_leche VALUES (seq_produccion.NEXTVAL, 1, SYSDATE - 1, 20.0);
    INSERT INTO produccion_leche VALUES (seq_produccion.NEXTVAL, 3, SYSDATE - 1, 12.5);
    -- Eventos reproductivos
    INSERT INTO eventos_reproductivos VALUES (seq_evento.NEXTVAL, 1, SYSDATE - 90, 'Inseminación');
    INSERT INTO eventos_reproductivos VALUES (seq_evento.NEXTVAL, 1, SYSDATE - 60, 'Palpación');
    INSERT INTO eventos_reproductivos VALUES (seq_evento.NEXTVAL, 2, SYSDATE - 30, 'Monta Natural');
    -- Usuarios
    INSERT INTO usuarios VALUES (seq_usuario.NEXTVAL, 'Administrador', 'admin@happyfarmer.cr', SYSDATE);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Datos de prueba cargados correctamente.');
END sp_cargar_datos_prueba;
/


/* ========================================================
   SECCIÓN 5: VISTAS (VIEWS)
   ======================================================== */

-- Vista 1: Resumen completo de animales con finca y edad
CREATE OR REPLACE VIEW vw_animales_detalle AS
    SELECT a.id_animal,
           a.nombre,
           a.raza,
           a.sexo,
           a.tipo,
           a.salud,
           fn_calcular_edad(a.fecha_nac)   AS edad_anios,
           fn_categoria_edad(a.id_animal)  AS categoria,
           p.nombre    AS potrero,
           f.nombre    AS finca,
           f.ubicacion AS ubicacion_finca
    FROM animales a
    JOIN potreros p ON a.id_potrero = p.id_potrero
    JOIN fincas   f ON p.id_finca   = f.id_finca;

-- Vista 2: Resumen de costos por animal
CREATE OR REPLACE VIEW vw_costos_por_animal AS
    SELECT a.id_animal,
           a.nombre,
           COUNT(c.id_costo)  AS cantidad_costos,
           SUM(c.monto)       AS total_costos,
           AVG(c.monto)       AS promedio_costo,
           MAX(c.fecha_costo) AS ultimo_costo
    FROM animales a
    LEFT JOIN costos c ON a.id_animal = c.id_animal
    GROUP BY a.id_animal, a.nombre;

-- Vista 3: Animales con sus vacunas aplicadas
CREATE OR REPLACE VIEW vw_vacunacion_animales AS
    SELECT a.nombre AS animal,
           v.nombre AS vacuna,
           va.fecha_aplicacion
    FROM vacunacion va
    JOIN animales a ON va.id_animal = a.id_animal
    JOIN vacunas  v ON va.id_vacuna = v.id_vacuna
    ORDER BY a.nombre, va.fecha_aplicacion DESC;

-- Vista 4: Producción de leche resumida
CREATE OR REPLACE VIEW vw_produccion_leche AS
    SELECT a.nombre AS animal,
           ROUND(AVG(pl.litros), 2) AS promedio_litros,
           SUM(pl.litros)           AS total_litros,
           COUNT(*)                 AS registros,
           MAX(pl.fecha_registro)   AS ultimo_registro
    FROM produccion_leche pl
    JOIN animales a ON pl.id_animal = a.id_animal
    GROUP BY a.nombre;

-- Vista 5: Ocupación de potreros
CREATE OR REPLACE VIEW vw_ocupacion_potreros AS
    SELECT f.nombre AS finca,
           p.nombre AS potrero,
           p.capacidad,
           COUNT(a.id_animal)                   AS animales_actuales,
           p.capacidad - COUNT(a.id_animal)     AS espacios_disponibles
    FROM potreros p
    JOIN fincas f ON p.id_finca = f.id_finca
    LEFT JOIN animales a ON p.id_potrero = a.id_potrero
    GROUP BY f.nombre, p.nombre, p.capacidad;

-- Vista 6: Últimos movimientos de auditoría
CREATE OR REPLACE VIEW vw_auditoria_reciente AS
    SELECT id, accion, usuario,
           TO_CHAR(fecha, 'DD/MM/YYYY HH24:MI') AS fecha_formato
    FROM movimientos
    ORDER BY fecha DESC;

-- Vista 7: Animales por finca con totales
CREATE OR REPLACE VIEW vw_animales_por_finca AS
    SELECT f.nombre AS finca,
           COUNT(a.id_animal)                            AS total_animales,
           SUM(CASE WHEN a.sexo='F' THEN 1 ELSE 0 END)  AS hembras,
           SUM(CASE WHEN a.sexo='M' THEN 1 ELSE 0 END)  AS machos
    FROM fincas f
    LEFT JOIN potreros p ON f.id_finca = p.id_finca
    LEFT JOIN animales a ON p.id_potrero = a.id_potrero
    GROUP BY f.nombre;

-- Vista 8: Historial de eventos reproductivos
CREATE OR REPLACE VIEW vw_eventos_reproductivos AS
    SELECT a.nombre AS animal,
           e.tipo_evento,
           TO_CHAR(e.fecha_evento, 'DD/MM/YYYY') AS fecha,
           fn_finca_de_animal(a.id_animal)       AS finca
    FROM eventos_reproductivos e
    JOIN animales a ON e.id_animal = a.id_animal
    ORDER BY e.fecha_evento DESC;

-- Vista 9: Animales en tratamiento
CREATE OR REPLACE VIEW vw_animales_en_tratamiento AS
    SELECT a.id_animal, a.nombre, a.salud,
           t.descripcion AS tratamiento,
           t.veterinario,
           t.fecha_inicio, t.fecha_fin
    FROM animales a
    JOIN tratamientos t ON a.id_animal = t.id_animal
    WHERE SYSDATE BETWEEN t.fecha_inicio AND NVL(t.fecha_fin, SYSDATE + 1);

-- Vista 10: Resumen general del sistema
CREATE OR REPLACE VIEW vw_resumen_sistema AS
    SELECT
        (SELECT COUNT(*) FROM fincas)    AS total_fincas,
        (SELECT COUNT(*) FROM potreros)  AS total_potreros,
        (SELECT COUNT(*) FROM animales)  AS total_animales,
        (SELECT COUNT(*) FROM usuarios)  AS total_usuarios,
        (SELECT COUNT(*) FROM movimientos) AS total_movimientos
    FROM dual;


/* ========================================================
   SECCIÓN 6: TRIGGERS
   ======================================================== */

-- Trigger 1: Auditoría de INSERT, UPDATE y DELETE en tabla ANIMALES
CREATE OR REPLACE TRIGGER tg_auditoria_animales
AFTER INSERT OR UPDATE OR DELETE ON animales
FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
    v_accion  VARCHAR2(100);
BEGIN
    SELECT USER INTO v_usuario FROM dual;
    IF    INSERTING THEN v_accion := 'INSERT EN ANIMALES';
    ELSIF UPDATING  THEN v_accion := 'UPDATE EN ANIMALES';
    ELSIF DELETING  THEN v_accion := 'DELETE EN ANIMALES';
    END IF;
    INSERT INTO movimientos (id, accion, usuario, fecha)
    VALUES (seq_mov.NEXTVAL, v_accion, v_usuario, SYSDATE);
END tg_auditoria_animales;
/

-- Trigger 2: Evita aplicar la misma vacuna a un animal en el mismo mes
CREATE OR REPLACE TRIGGER tg_validar_vacunacion
BEFORE INSERT ON vacunacion
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM vacunacion
    WHERE id_animal = :NEW.id_animal
      AND id_vacuna = :NEW.id_vacuna
      AND fecha_aplicacion >= ADD_MONTHS(SYSDATE, -1);
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'No puede aplicar la misma vacuna al mismo animal en el mismo mes.');
    END IF;
END tg_validar_vacunacion;
/

-- Trigger 3: Auditoría de cambios en la tabla USUARIOS
CREATE OR REPLACE TRIGGER tg_auditoria_usuarios
AFTER INSERT OR UPDATE OR DELETE ON usuarios
FOR EACH ROW
DECLARE
    v_accion VARCHAR2(100);
BEGIN
    IF    INSERTING THEN v_accion := 'INSERT EN USUARIOS';
    ELSIF UPDATING  THEN v_accion := 'UPDATE EN USUARIOS';
    ELSIF DELETING  THEN v_accion := 'DELETE EN USUARIOS';
    END IF;
    INSERT INTO movimientos (id, accion, usuario, fecha)
    VALUES (seq_mov.NEXTVAL, v_accion, USER, SYSDATE);
END tg_auditoria_usuarios;
/

-- Trigger 4: Valida que la producción de leche sea solo para hembras
CREATE OR REPLACE TRIGGER tg_validar_produccion
BEFORE INSERT ON produccion_leche
FOR EACH ROW
DECLARE
    v_sexo  VARCHAR2(1);
    v_tipo  VARCHAR2(30);
BEGIN
    SELECT sexo, tipo INTO v_sexo, v_tipo
    FROM animales WHERE id_animal = :NEW.id_animal;
    IF v_sexo != 'F' THEN
        RAISE_APPLICATION_ERROR(-20009,
            'Solo se puede registrar producción de leche para animales hembras.');
    END IF;
END tg_validar_produccion;
/

-- Trigger 5: Evita registrar costos negativos
CREATE OR REPLACE TRIGGER tg_validar_costo
BEFORE INSERT OR UPDATE ON costos
FOR EACH ROW
BEGIN
    IF :NEW.monto < 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'El monto de un costo no puede ser negativo.');
    END IF;
END tg_validar_costo;
/


/* ========================================================
   SECCIÓN 7: CURSORES DE SISTEMA
   ======================================================== */

-- Cursor de sistema 1: Verificar tablas creadas
SELECT table_name, num_rows
FROM user_tables
ORDER BY table_name;

-- Cursor de sistema 2: Verificar triggers activos
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
ORDER BY trigger_name;

-- Cursor de sistema 3: Verificar procedimientos almacenados
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
ORDER BY object_name;

-- Cursor de sistema 4: Verificar funciones creadas
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type = 'FUNCTION'
ORDER BY object_name;

-- Cursor de sistema 5: Verificar vistas creadas
SELECT view_name
FROM user_views
ORDER BY view_name;

-- Cursor de sistema 6: Verificar secuencias
SELECT sequence_name, last_number, increment_by
FROM user_sequences
ORDER BY sequence_name;

-- Cursor de sistema 7: Verificar paquetes
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name;

-- Cursor de sistema 8: Verificar constraints
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
ORDER BY table_name;


/* ========================================================
   SECCIÓN 8: PAQUETES (PACKAGES)
   ======================================================== */

-- ESPECIFICACIÓN del paquete principal
CREATE OR REPLACE PACKAGE pkg_ganaderia AS
    -- Gestión de usuarios
    PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2);

    -- Gestión de animales
    FUNCTION  edad_animal(pid NUMBER)    RETURN NUMBER;
    FUNCTION  salud_animal(pid NUMBER)   RETURN VARCHAR2;
    PROCEDURE listar_por_tipo(ptipo VARCHAR2);

    -- Gestión de producción
    FUNCTION  produccion_total(pid NUMBER) RETURN NUMBER;
    PROCEDURE reporte_produccion_mes;

    -- Gestión de costos
    FUNCTION  total_costos_finca(pid_finca NUMBER) RETURN NUMBER;
    PROCEDURE reporte_costos_mensual;

    -- Utilitarios
    FUNCTION  validar_email(p_email VARCHAR2) RETURN BOOLEAN;
END pkg_ganaderia;
/

-- CUERPO del paquete principal
CREATE OR REPLACE PACKAGE BODY pkg_ganaderia AS

    -- Inserta usuario con validación de email
    PROCEDURE insertar_usuario(pn VARCHAR2, pe VARCHAR2) IS
    BEGIN
        IF NOT REGEXP_LIKE(pe,
           '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20002, 'Email inválido: ' || pe);
        END IF;
        INSERT INTO usuarios VALUES (seq_usuario.NEXTVAL, pn, pe, SYSDATE);
        COMMIT;
    END insertar_usuario;

    -- Retorna la edad en años de un animal
    FUNCTION edad_animal(pid NUMBER) RETURN NUMBER IS
        v_fecha DATE;
    BEGIN
        SELECT fecha_nac INTO v_fecha
        FROM animales WHERE id_animal = pid;
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha) / 12);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END edad_animal;

    -- Retorna el estado de salud de un animal
    FUNCTION salud_animal(pid NUMBER) RETURN VARCHAR2 IS
        v_salud VARCHAR2(40);
    BEGIN
        SELECT salud INTO v_salud
        FROM animales WHERE id_animal = pid;
        RETURN NVL(v_salud, 'Sin registro');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'Animal no encontrado';
    END salud_animal;

    -- Lista animales filtrados por tipo
    PROCEDURE listar_por_tipo(ptipo VARCHAR2) IS
        CURSOR c_tipo IS
            SELECT nombre, raza, fn_calcular_edad(fecha_nac) AS edad
            FROM animales
            WHERE UPPER(tipo) = UPPER(ptipo);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ANIMALES DE TIPO: ' || UPPER(ptipo) || ' ===');
        FOR reg IN c_tipo LOOP
            DBMS_OUTPUT.PUT_LINE(
                reg.nombre || ' (' || reg.raza || ') - ' || reg.edad || ' años'
            );
        END LOOP;
    END listar_por_tipo;

    -- Retorna el total de litros producidos por un animal
    FUNCTION produccion_total(pid NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(litros), 0) INTO v_total
        FROM produccion_leche WHERE id_animal = pid;
        RETURN v_total;
    END produccion_total;

    -- Reporte de producción del mes actual
    PROCEDURE reporte_produccion_mes IS
        CURSOR c_prod IS
            SELECT a.nombre, SUM(pl.litros) AS litros_mes
            FROM produccion_leche pl
            JOIN animales a ON pl.id_animal = a.id_animal
            WHERE EXTRACT(MONTH FROM pl.fecha_registro) =
                  EXTRACT(MONTH FROM SYSDATE)
              AND EXTRACT(YEAR FROM pl.fecha_registro) =
                  EXTRACT(YEAR FROM SYSDATE)
            GROUP BY a.nombre
            ORDER BY litros_mes DESC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PRODUCCIÓN DEL MES ACTUAL ===');
        FOR reg IN c_prod LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(reg.nombre, 15) || ' | ' ||
                TO_CHAR(reg.litros_mes, 'FM9990.00') || ' litros'
            );
        END LOOP;
    END reporte_produccion_mes;

    -- Retorna la suma de costos de todos los animales de una finca
    FUNCTION total_costos_finca(pid_finca NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(c.monto), 0) INTO v_total
        FROM costos c
        JOIN animales  a ON c.id_animal  = a.id_animal
        JOIN potreros  p ON a.id_potrero = p.id_potrero
        WHERE p.id_finca = pid_finca;
        RETURN v_total;
    END total_costos_finca;

    -- Reporte de costos del mes actual agrupados por animal
    PROCEDURE reporte_costos_mensual IS
        CURSOR c_costos IS
            SELECT a.nombre, SUM(c.monto) AS total
            FROM costos c
            JOIN animales a ON c.id_animal = a.id_animal
            WHERE EXTRACT(MONTH FROM c.fecha_costo) = EXTRACT(MONTH FROM SYSDATE)
              AND EXTRACT(YEAR  FROM c.fecha_costo) = EXTRACT(YEAR  FROM SYSDATE)
            GROUP BY a.nombre
            ORDER BY total DESC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== COSTOS DEL MES ACTUAL ===');
        FOR reg IN c_costos LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(reg.nombre, 15) || ' | ₡' ||
                TO_CHAR(reg.total, 'FM999,990.00')
            );
        END LOOP;
    END reporte_costos_mensual;

    -- Valida formato de email (retorna BOOLEAN)
    FUNCTION validar_email(p_email VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN REGEXP_LIKE(p_email,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    END validar_email;

END pkg_ganaderia;
/


/* ========================================================
   SECCIÓN 9: MANEJO DE EXCEPCIONES PERSONALIZADAS
   ======================================================== */

-- Bloque anónimo: Prueba de manejo de excepciones
DECLARE
    e_animal_no_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_animal_no_encontrado, -20099);

    v_edad NUMBER;
BEGIN
    -- Intenta calcular edad de animal inexistente
    BEGIN
        SELECT fn_calcular_edad(fecha_nac) INTO v_edad
        FROM animales WHERE id_animal = 9999;

        IF v_edad IS NULL THEN
            RAISE_APPLICATION_ERROR(-20099, 'Animal 9999 no existe.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPCIÓN CONTROLADA: Animal no encontrado.');
        WHEN e_animal_no_encontrado THEN
            DBMS_OUTPUT.PUT_LINE('EXCEPCIÓN PERSONALIZADA: ' || SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
    END;
END;
/


/* ========================================================
   SECCIÓN 10: SQL DINÁMICO
   ======================================================== */

-- Demostración de SQL dinámico: cuenta registros de cualquier tabla
DECLARE
    v_sql   VARCHAR2(200);
    v_count NUMBER;
    v_tabla VARCHAR2(50) := 'ANIMALES';
BEGIN
    v_sql := 'SELECT COUNT(*) FROM ' ||
             DBMS_ASSERT.SIMPLE_SQL_NAME(v_tabla);
    EXECUTE IMMEDIATE v_sql INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Total en ' || v_tabla || ': ' || v_count);
END;
/


/* ========================================================
   SECCIÓN 11: CONSULTAS SELECT DE VERIFICACIÓN
   ======================================================== */

-- Verificar tablas del esquema
SELECT table_name FROM user_tables ORDER BY table_name;

-- Ver todos los animales con detalle
SELECT * FROM vw_animales_detalle;

-- Ver ocupación de potreros
SELECT * FROM vw_ocupacion_potreros;

-- Ver costos por animal
SELECT * FROM vw_costos_por_animal;

-- Ver producción de leche
SELECT * FROM vw_produccion_leche;

-- Ver vacunaciones
SELECT * FROM vw_vacunacion_animales;

-- Ver auditoría de movimientos
SELECT * FROM vw_auditoria_reciente;

-- Ver resumen del sistema
SELECT * FROM vw_resumen_sistema;

-- Ver fincas con conteo de animales
SELECT * FROM vw_animales_por_finca;

-- Prueba de función edad
SELECT nombre, fn_calcular_edad(fecha_nac) AS edad,
       fn_categoria_edad(id_animal) AS categoria
FROM animales;

-- Prueba de función costos
SELECT nombre, fn_total_costos(id_animal) AS total_costos
FROM animales;

-- Prueba de función producción
SELECT nombre, fn_total_produccion(id_animal) AS litros_totales
FROM animales WHERE tipo = 'Leche';

-- Prueba de función finca de animal
SELECT nombre, fn_finca_de_animal(id_animal) AS finca
FROM animales;

-- Movimientos generados por triggers
SELECT * FROM movimientos ORDER BY fecha DESC;
