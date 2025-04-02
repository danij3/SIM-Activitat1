-- EXERCICI 2 - SIMM 
-- Autors: Rafa Oliver, Dani pérez y Dani Jan 

-- PAS 1: Crear tipus base PERSONA
CREATE OR REPLACE TYPE Persona AS OBJECT (
  codi NUMBER,
  dni VARCHAR2(9),
  nom VARCHAR2(100),
  adreça VARCHAR2(150),
  telefon VARCHAR2(15)
) NOT FINAL;

-- PAS 2: Creació dels tipus derivats i les seves implementacions
-- Creació dels tipus derivats de Persona
CREATE OR REPLACE TYPE Empleat UNDER Persona (
  sou NUMBER(8,2),
  data_contracte DATE,
  telefon_feina VARCHAR2(15),
  lloc_treball VARCHAR2(100),
  MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE Estudiant UNDER Persona (
  num_est NUMBER,
  correu VARCHAR2(100),
  data_naixement DATE,
  MEMBER FUNCTION edat RETURN NUMBER
) NOT FINAL;

-- implementació dels métodes
CREATE OR REPLACE TYPE BODY Empleat AS 
  MEMBER FUNCTION antiguitat RETURN NUMBER IS
    anys NUMBER;
  BEGIN
    anys := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_contracte);
    RETURN anys;
  END;
END;
/

CREATE OR REPLACE TYPE BODY Estudiant AS 
  MEMBER FUNCTION edat RETURN NUMBER IS
    anys NUMBER;
  BEGIN
    anys := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_naixement);
    RETURN anys;
  END;
END;
/

-- Creació dels tipus derivats de Empleat
CREATE OR REPLACE TYPE Professor UNDER Empleat (
  titulacions VARCHAR2(200),
  docencia VARCHAR2(100),
  MEMBER FUNCTION triennis RETURN NUMBER
);

CREATE OR REPLACE TYPE PAS UNDER Empleat (
  feina VARCHAR2(100),
  tipus_contracte VARCHAR2(50),
  MEMBER FUNCTION sou_anual RETURN NUMBER
);

-- implementació dels métodes
CREATE OR REPLACE TYPE BODY Professor AS
  MEMBER FUNCTION triennis RETURN NUMBER IS
  BEGIN
    RETURN FLOOR(EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_contracte)) / 3;
  END;
END;
/

CREATE OR REPLACE TYPE BODY PAS AS
  MEMBER FUNCTION sou_anual RETURN NUMBER IS
  BEGIN
    RETURN sou * 14;
  END;
END;
/

-- Creació dels tipus derivats de Estudiant
CREATE OR REPLACE TYPE Est_grau UNDER Estudiant (
  titulacio VARCHAR2(100),
  durada NUMBER,
  any_1a_matricula NUMBER,
  MEMBER FUNCTION matricules_disponibles RETURN NUMBER,
  CONSTRUCTOR FUNCTION Est_grau RETURN SELF AS RESULT
) 
INSTANTIABLE NOT FINAL;

CREATE OR REPLACE TYPE Est_cicles UNDER Estudiant (
  nivell VARCHAR2(50),
  cicle VARCHAR2(50),
  curs NUMBER,
  MEMBER FUNCTION descripcio RETURN VARCHAR2,
  CONSTRUCTOR FUNCTION Est_cicles RETURN SELF AS RESULT
)
INSTANTIABLE NOT FINAL;

-- implementació dels métodes
CREATE OR REPLACE TYPE BODY Est_grau AS
  MEMBER FUNCTION matricules_disponibles RETURN NUMBER IS
    anys_passats NUMBER;
  BEGIN
    anys_passats := EXTRACT(YEAR FROM SYSDATE) - any_1a_matricula;
    RETURN durada - anys_passats;
  END;

  CONSTRUCTOR FUNCTION Est_grau RETURN SELF AS RESULT IS
  BEGIN
    durada := 4;
    any_1a_matricula := EXTRACT(YEAR FROM SYSDATE);
    RETURN;
  END;
END;
/

CREATE OR REPLACE TYPE BODY Est_cicles AS
  MEMBER FUNCTION descripcio RETURN VARCHAR2 IS
  BEGIN
    RETURN nivell || ' - ' || cicle || ' - Curs: ' || curs;
  END;

  CONSTRUCTOR FUNCTION Est_cicles RETURN SELF AS RESULT IS
  BEGIN
    nivell := 'Superior';
    cicle := 'DAW';
    curs := 1;
    RETURN;
  END;
END;
/

-- PAS 3: Creació de les taules per a cada tipus
CREATE TABLE persones OF Persona;
CREATE TABLE empleats OF Empleat;
CREATE TABLE professors OF Professor;
CREATE TABLE pas_obj OF PAS;
CREATE TABLE estudiants OF Estudiant;
CREATE TABLE est_grau_obj OF Est_grau;
CREATE TABLE est_cicles_obj OF Est_cicles;

-- PAS 4: Inserció de dades a cada taula
INSERT INTO professors VALUES (
  Professor(1, '12345678A', 'Anna Puig', 'Carrer Major 10', '600111222',
    2500, TO_DATE('2015-09-01', 'YYYY-MM-DD'), '933123456', 'Facultat Informàtica',
    'Enginyeria Informàtica', 'POO i BD')
);

INSERT INTO pas_obj VALUES (
  PAS(2, '87654321B', 'Joan Serra', 'Av. Diagonal 100', '600333444',
    1800, TO_DATE('2018-01-15', 'YYYY-MM-DD'), '933654321', 'Gestió Acadèmica',
    'Administratiu', 'Indefinit')
);

INSERT INTO est_grau_obj VALUES (
  Est_grau(3, '11223344C', 'Laura Gómez', 'C/ Universitat 25', '600777888',
    202301, 'laura@correo.com', TO_DATE('2002-05-20', 'YYYY-MM-DD'),
    'Multimèdia', 4, EXTRACT(YEAR FROM SYSDATE))
);

INSERT INTO est_cicles_obj VALUES (
  Est_cicles(4, '44556677D', 'Marc López', 'C/ Gran Via 90', '600999000',
    202401, 'marc@correo.com', TO_DATE('2004-11-25', 'YYYY-MM-DD'),
    'Superior', 'DAW', 1)
);

-- PAS 5: Inserció d'objectes de diferents subclasses a la taula PERSONES
INSERT INTO persones VALUES (
  Professor(10, '11111111A', 'Marta Vidal', 'C/ Ronda Universitat 5', '600000001',
    3000, TO_DATE('2012-10-01', 'YYYY-MM-DD'), '932123456', 'Aulari Nord',
    'Industrial', 'Automàtica')
);

INSERT INTO persones VALUES (
  PAS(11, '22222222B', 'Pere Font', 'C/ Consell de Cent 100', '600000002',
    1900, TO_DATE('2016-02-20', 'YYYY-MM-DD'), '931456789', 'Serveis Generals',
    'Manteniment', 'Temporal')
);

INSERT INTO persones VALUES (
  Est_grau(12, '33333333C', 'Clara Riera', 'Av. Meridiana 20', '600000003',
    202321, 'clara@est.fib.upc.edu', TO_DATE('2003-04-10', 'YYYY-MM-DD'),
    'Informàtica', 4, EXTRACT(YEAR FROM SYSDATE))
);

INSERT INTO persones VALUES (
  Est_cicles(13, '44444444D', 'Albert Serra', 'Pg. Sant Joan 55', '600000004',
    202401, 'albert@cicles.cat', TO_DATE('2004-11-25', 'YYYY-MM-DD'),
    'Superior', 'DAW', 1)
);

-- PAS 6: Comprovació de la crida a les funcions
-- Antiguitat dels empleats
SELECT p.nom, TREAT(VALUE(p) AS Empleat).antiguitat() AS antiguitat
FROM persones p
WHERE VALUE(p) IS OF (Empleat);

-- Edat dels estudiants
SELECT p.nom, TREAT(VALUE(p) AS Estudiant).edat() AS edat
FROM persones p
WHERE VALUE(p) IS OF (Estudiant);

-- Triennis dels professors
SELECT p.nom, TREAT(VALUE(p) AS Professor).triennis() AS triennis
FROM persones p
WHERE VALUE(p) IS OF (ONLY Professor);

-- Sou anual del PAS
SELECT p.nom, TREAT(VALUE(p) AS PAS).sou_anual() AS sou_anual
FROM persones p
WHERE VALUE(p) IS OF (ONLY PAS);

-- Matrícules disponibles dels estudiants de grau
SELECT p.nom, TREAT(VALUE(p) AS Est_grau).matricules_disponibles() AS disponibles
FROM persones p
WHERE VALUE(p) IS OF (ONLY Est_grau);

-- Descripció dels estudiants de cicles
SELECT p.nom, TREAT(VALUE(p) AS Est_cicles).descripcio() AS descripcio
FROM persones p
WHERE VALUE(p) IS OF (ONLY Est_cicles);





























