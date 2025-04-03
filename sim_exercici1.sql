-- Tema 2 Base de Datos - Ejercicio 1
-- Autors: Rafa Oliver, Dani pérez y Dani Jan

-------------------------------------------
-- 1. Eliminación previa de objetos (opcional)
-------------------------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE tab_comanda';
   EXECUTE IMMEDIATE 'DROP TABLE tab_client';
   EXECUTE IMMEDIATE 'DROP TABLE tab_producte';
   EXECUTE IMMEDIATE 'DROP TYPE COMANDA';
   EXECUTE IMMEDIATE 'DROP TYPE taula_linies';
   EXECUTE IMMEDIATE 'DROP TYPE LINIA';
   EXECUTE IMMEDIATE 'DROP TYPE CLIENT';
   EXECUTE IMMEDIATE 'DROP TYPE vec_telefon';
   EXECUTE IMMEDIATE 'DROP TYPE Telefon';
   EXECUTE IMMEDIATE 'DROP TYPE PRODUCTE';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/


-- 2. Definición del tipo TELEFON

CREATE TYPE Telefon AS OBJECT (
    tipus VARCHAR2(20), 
    numero VARCHAR2(20)
);
/


-- 3. Definición del VARRAY para teléfonos

CREATE TYPE vec_telefon AS VARRAY(3) OF Telefon;
/


-- 4. Definición del tipo CLIENT

CREATE TYPE CLIENT AS OBJECT (
    codi CHAR(10),
    nom VARCHAR2(50),
    adreça VARCHAR2(50),
    telefons vec_telefon,
    correu_electronic VARCHAR2(50)
);
/


-- 5. Definición del tipo PRODUCTE

CREATE TYPE PRODUCTE AS OBJECT (
    codi NUMBER(10),
    nom VARCHAR2(50),
    descripcio VARCHAR2(100),
    preu NUMBER(10,2)
);
/


-- 6. Definición del tipo LINIA

CREATE TYPE LINIA AS OBJECT (
    codi NUMBER(10),
    ref_producte REF PRODUCTE,
    unitats NUMBER(10),
    MEMBER FUNCTION calcular_import RETURN NUMBER
);
/


-- 7. Implementación del método para LINIA

CREATE TYPE BODY LINIA AS 
    MEMBER FUNCTION calcular_import RETURN NUMBER IS
        product PRODUCTE;
    BEGIN
        SELECT DEREF(ref_producte) INTO product FROM DUAL;
        RETURN unitats * product.preu;
    END calcular_import;
END;
/


-- 8. Definición de tabla anidada para líneas

CREATE TYPE taula_linies AS TABLE OF LINIA;
/


-- 9. Definición del tipo COMANDA

CREATE TYPE COMANDA AS OBJECT (
    codi NUMBER(10),
    data_comanda DATE,
    ref_client REF CLIENT,
    linies taula_linies,
    MEMBER FUNCTION calcular_import_total RETURN NUMBER
);
/


-- 10. Implementación del método para COMANDA

CREATE TYPE BODY COMANDA AS 
    MEMBER FUNCTION calcular_import_total RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        IF linies IS NOT NULL THEN
            FOR i IN 1..linies.COUNT LOOP
                total := total + linies(i).calcular_import();
            END LOOP;
        END IF;
        RETURN total;
    END calcular_import_total;
END;
/

-------------------------------------------
-- 11. Creación de tablas de objetos
-------------------------------------------
CREATE TABLE tab_producte OF PRODUCTE (
    PRIMARY KEY (codi)
);

CREATE TABLE tab_client OF CLIENT (
    PRIMARY KEY (codi)
);

CREATE TABLE tab_comanda OF COMANDA (
    PRIMARY KEY (codi)
) NESTED TABLE linies STORE AS linies_table;


-- 12. Inserción de datos de ejemplo

-- Productos
INSERT INTO tab_producte VALUES (PRODUCTE(1, 'MacBook Pro', 'Portátil Apple 16 pulgadas', 1200.00));
INSERT INTO tab_producte VALUES (PRODUCTE(2, 'Ratolí', 'Ratolí gaming bluetoth', 30.00));
INSERT INTO tab_producte VALUES (PRODUCTE(3, 'Teclat', 'Teclat mecànic gaming', 90.00));

-- Clientes
INSERT INTO tab_client VALUES (
    CLIENT('C001', 'Sofía Martínez', 'Gran Vía 28, Madrid', 
           vec_telefon(Telefon('Mòbil', '666111222')), 'sofiamart@email.com')
);

INSERT INTO tab_client VALUES (
    CLIENT('C002', 'David Leonhard', 'Calle Serrano 112', 
           vec_telefon(Telefon('Fix', '931234567')), 'davidleon@gmail.com')
);

-- Comanda (usando PL/SQL)
DECLARE
    prod1 REF PRODUCTE;
    prod2 REF PRODUCTE;
    cli REF CLIENT;
BEGIN
    SELECT REF(p) INTO prod1 FROM tab_producte p WHERE p.codi = 1;
    SELECT REF(p) INTO prod2 FROM tab_producte p WHERE p.codi = 2;
    SELECT REF(c) INTO cli FROM tab_client c WHERE c.codi = 'C001';
    
    INSERT INTO tab_comanda VALUES (
        COMANDA(1, SYSDATE, cli, 
            taula_linies(
                LINIA(1, prod1, 2),
                LINIA(2, prod2, 5)
            )
        )
    );
END;
/


-- 13. Consultas de demostración

-- Consulta 1: Mostrar todos los productos
SELECT * FROM tab_producte;

-- Consulta 2: Mostrar clientes con sus teléfonos
SELECT c.codi, c.nom, t.tipus, t.numero, c.correu_electronic
FROM tab_client c, TABLE(c.telefons) t;


/* --Consultas especificas
-- Consulta 3: Calcular importe de líneas de comanda
SELECT c.codi AS num_comanda, l.codi AS num_linia, 
       l.calcular_import() AS import_linia
FROM tab_comanda c, TABLE(c.linies) l
WHERE c.codi = 1;

-- Consulta 4: Calcular importe total de comanda
SELECT c.codi, c.calcular_import_total() AS import_total
FROM tab_comanda c
WHERE c.codi = 1;

-- Consulta 5: Mostrar comandas con detalles
SELECT c.codi, c.data_comanda, 
       DEREF(c.ref_client).nom AS client,
       c.calcular_import_total() AS total
FROM tab_comanda c;*/