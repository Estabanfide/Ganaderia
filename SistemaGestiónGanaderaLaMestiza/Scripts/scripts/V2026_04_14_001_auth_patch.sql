/* 
   Script incremental para compatibilidad con autenticacion de la app.
   Base esperada: granja_lbd_final_1.sql
*/

DECLARE
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM user_tab_cols
     WHERE table_name = 'USUARIOS'
       AND column_name = 'CLAVE';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE usuarios ADD clave VARCHAR2(255)';
    END IF;
END;
/
