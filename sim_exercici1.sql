-- Tema 2 Base de Datos

-- Exercici 1

-- Eliminar objetos existentes (opcional)
/*
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
   WHEN OTHERS THEN NULL; -- Ignorar errores si los objetos no existen
END;
/
*/


-- Definir el tipus TELÈFON
CREATE TYPE Telefon AS OBJECT (
    tipus VARCHAR2(20), 
    numero VARCHAR2(20) -- Cambio de NUMBER a VARCHAR2 para admitir prefijos
);
/

-- Definir el tipus VARRAY per als telèfons
CREATE TYPE vec_telefon AS VARRAY(3) OF Telefon;
/

-- Definir el tipus CLIENT
CREATE TYPE CLIENT AS OBJECT (
    codi CHAR(10),
    nom VARCHAR2(50),
    adreça VARCHAR2(50),
    telefons vec_telefon,
    correu_elect VARCHAR2(50)
);
/

-- Definir el tipus PRODUCTE
CREATE TYPE PRODUCTE AS OBJECT (
    codi NUMBER(10),
    nom VARCHAR2(50),
    descripcio VARCHAR2(100),
    preu NUMBER(10,2)
);
/

-- Definir el tipus LINIA
CREATE TYPE LINIA AS OBJECT (
    codi NUMBER(10),
    ref_producte REF PRODUCTE,
    unitats NUMBER(10),
    MEMBER FUNCTION calcular_import RETURN NUMBER
);
/

-- Implementació del mètode calcular_import per LINIA
CREATE TYPE BODY LINIA AS 
    MEMBER FUNCTION calcular_import RETURN NUMBER IS
        product PRODUCTE;
    BEGIN
        SELECT DEREF(ref_producte) INTO product FROM DUAL;
        RETURN unitats * product.preu;
    END calcular_import;
END;
/

-- Definir una taula niuada de línies
CREATE TYPE taula_linies AS TABLE OF LINIA;
/

-- Definir el tipus COMANDA
CREATE TYPE COMANDA AS OBJECT (
    codi NUMBER(10),
    data_comanda DATE,
    ref_client REF CLIENT,
    tab_linies taula_linies,
    MEMBER FUNCTION calcular_import_total RETURN NUMBER
);
/

-- Implementació del mètode calcular_import_total per COMANDA
CREATE TYPE BODY COMANDA AS 
    MEMBER FUNCTION calcular_import_total RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        IF tab_linies IS NOT NULL THEN
            FOR i IN 1..tab_linies.COUNT LOOP
                total := total + tab_linies(i).calcular_import();
            END LOOP;
        END IF;
        RETURN total;
    END calcular_import_total;
END;
/

-- Crear les taules d'objectes
-- CREATE TABLE tab_producte OF PRODUCTE (
--     PRIMARY KEY (codi)
-- )NOT FINAL;
-- /
CREATE TABLE tab_producte OF PRODUCTE (
    PRIMARY KEY (codi)
);


CREATE TABLE tab_client OF CLIENT (
    PRIMARY KEY (codi)
);


-- CREATE TABLE tab_comanda OF COMANDA (
--     PRIMARY KEY (codi)
-- ) NESTED TABLE tab_linies STORE AS tab_linies_table
--   ( SCOPE FOR (ref_producte) IS tab_producte );
-- /
CREATE TABLE tab_comanda OF COMANDA (
    PRIMARY KEY (codi)
)
NESTED TABLE tab_linies STORE AS tab_linies_table;

-- Inserir productes
INSERT INTO tab_producte VALUES (PRODUCTE(1, 'Ordinador', 'Portàtil de gamma alta', 1200.00));
INSERT INTO tab_producte VALUES (PRODUCTE(2, 'Ratolí', 'Ratolí sense fil', 25.00));
INSERT INTO tab_producte VALUES (PRODUCTE(3, 'Teclat', 'Teclat mecànic', 80.00));
/

-- Inserir clients
INSERT INTO tab_client VALUES (
    CLIENT('C001', 'Joan Pérez', 'Carrer Major 12', 
           vec_telefon(Telefon('Mòbil', '666111222')), 'joan@email.com')
);

INSERT INTO tab_client VALUES (
    CLIENT('C002', 'Maria López', 'Avinguda Catalunya 34', 
           vec_telefon(Telefon('Fix', '931234567')), 'maria@email.com')
);
/


-- Inserir comanda amb PL/SQL
-- DECLARE
--     prod1 REF PRODUCTE;
--     prod2 REF PRODUCTE;
--     cli REF CLIENT;
--     comanda COMANDA;
-- BEGIN
--     SELECT REF(p) INTO prod1 FROM tab_producte p WHERE p.codi = 1;
--     SELECT REF(p) INTO prod2 FROM tab_producte p WHERE p.codi = 2;
--     SELECT REF(c) INTO cli FROM tab_client c WHERE c.codi = 'C001';

--     comanda := COMANDA(1, SYSDATE, cli, 
--         taula_linies(
--             LINIA(1, prod1, 2),
--             LINIA(2, prod2, 5)
--         )
--     );

--     INSERT INTO tab_comanda VALUES (comanda);
-- END;
-- /
DECLARE
    prod1 REF PRODUCTE;
    prod2 REF PRODUCTE;
    cli REF CLIENT;
BEGIN
    -- Obtener referencias
    SELECT REF(p) INTO prod1 FROM tab_producte p WHERE p.codi = 1;
    SELECT REF(p) INTO prod2 FROM tab_producte p WHERE p.codi = 2;
    SELECT REF(c) INTO cli FROM tab_client c WHERE c.codi = 'C001';

    -- Insertar la comanda directamente
    INSERT INTO tab_comanda VALUES (
        COMANDA(
            1,
            SYSDATE,
            cli,
            taula_linies(
                LINIA(1, prod1, 2),
                LINIA(2, prod2, 5)
            )
        )
    );
END;
/

SELECT * FROM tab_producte;
/
-- Consultar clientes con los números de teléfono desglosados
SELECT c.codi, c.nom, c.adreça, t.tipus, t.numero, c.correu_elect
FROM tab_client c, TABLE(c.telefons) t;