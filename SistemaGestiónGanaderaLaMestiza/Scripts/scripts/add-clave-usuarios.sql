-- Añade la columna clave a la tabla usuarios para autenticación.
-- Ejecutar en Oracle antes de usar login/registro si la tabla no tiene esta columna.

ALTER TABLE usuarios ADD clave VARCHAR2(255);

COMMIT;
