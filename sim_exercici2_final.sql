-- EXERCICI 2 - SIMM
-- Autors: Rafa Oliver, Dani Pérez i Dani Jan

-- PAS 1: Crear tipus base PERSONA
CREATE OR REPLACE TYPE Persona AS OBJECT (
  codi NUMBER,
  dni VARCHAR2(9),
  nom VARCHAR2(100),
  adreça VARCHAR2(150),
  telefon VARCHAR2(15)
) NOT FINAL;
/

-- PAS 2: Creació dels tipus derivats i les seves implementacions
-- Crear tipus Empleat que hereta de Persona
CREATE OR REPLACE TYPE Empleat UNDER Persona (
  sou NUMBER(8,2),
  data_contracte DATE,
  telefon_feina VARCHAR2(15),
  lloc_treball VARCHAR2(100),
  MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;
/

-- Crear tipus Estudiant que hereta de Persona
CREATE OR REPLACE TYPE Estudiant UNDER Persona (
  num_est NUMBER,
  correu VARCHAR2(100),
  data_naixement DATE,
  MEMBER FUNCTION edat RETURN NUMBER
) NOT FINAL;
/

-- Implementació del mètode antiguitat d'Empleat
CREATE OR REPLACE TYPE BODY Empleat AS 
  MEMBER FUNCTION antiguitat RETURN NUMBER IS
    anys NUMBER;
  BEGIN
    anys := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_contracte);
    RETURN anys;
  END;
END;
/

-- Implementació del mètode edat d'Estudiant
CREATE OR REPLACE TYPE BODY Estudiant AS 
  MEMBER FUNCTION edat RETURN NUMBER IS
    anys NUMBER;
  BEGIN
    anys := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_naixement);
    RETURN anys;
  END;
END;
/

-- Crear tipus Professor que hereta de Empleat
CREATE OR REPLACE TYPE Professor UNDER Empleat (
  titulacions VARCHAR2(200),
  docencia VARCHAR2(100),
  MEMBER FUNCTION triennis RETURN NUMBER
);
/

-- Crear tipus PAS que hereta de Empleat
CREATE OR REPLACE TYPE PAS UNDER Empleat (
  feina VARCHAR2(100),
  tipus_contracte VARCHAR2(50),
  MEMBER FUNCTION sou_anual RETURN NUMBER
);
/

-- Implementació del mètode triennis de Professor
CREATE OR REPLACE TYPE BODY Professor AS
  MEMBER FUNCTION triennis RETURN NUMBER IS
  BEGIN
    RETURN FLOOR(EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_contracte)) / 3;
  END;
END;
/

-- Implementació del mètode sou_anual de PAS
CREATE OR REPLACE TYPE BODY PAS AS
  MEMBER FUNCTION sou_anual RETURN NUMBER IS
  BEGIN
    RETURN sou * 14;
  END;
END;
/

-- Crear tipus Est_grau que hereta de Estudiant
CREATE OR REPLACE TYPE Est_grau UNDER Estudiant (
  titulacio VARCHAR2(100),
  durada NUMBER,
  any_1a_matricula NUMBER,
  MEMBER FUNCTION matricules_disponibles RETURN NUMBER,
  CONSTRUCTOR FUNCTION Est_grau RETURN SELF AS RESULT
)
INSTANTIABLE NOT FINAL;
/

-- Crear tipus Est_cicles que hereta de Estudiant
CREATE OR REPLACE TYPE Est_cicles UNDER Estudiant (
  nivell VARCHAR2(50),
  cicle VARCHAR2(50),
  curs NUMBER,
  MEMBER FUNCTION descripcio RETURN VARCHAR2,
  CONSTRUCTOR FUNCTION Est_cicles RETURN SELF AS RESULT
)
INSTANTIABLE NOT FINAL;
/

-- Implementació dels mètodes d'Est_grau
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

-- Implementació dels mètodes d'Est_cicles
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
-- Creació de la taula persones
CREATE TABLE persones OF Persona;
-- Creació de la taula empleats
CREATE TABLE empleats OF Empleat;
-- Creació de la taula professors
CREATE TABLE professors OF Professor;
-- Creació de la taula pas_obj
CREATE TABLE pas_obj OF PAS;
-- Creació de la taula estudiants
CREATE TABLE estudiants OF Estudiant;
-- Creació de la taula est_grau_obj
CREATE TABLE est_grau_obj OF Est_grau;
-- Creació de la taula est_cicles_obj
CREATE TABLE est_cicles_obj OF Est_cicles;
/

-- PAS 4: Inserció de dades a cada taula
-- Inserció de dades a la taula professors
INSERT INTO professors VALUES (
  Professor(1, '48162357F', 'Helena Martí', 'C/ Aragó 182, Barcelona', '678452113',
    2750, TO_DATE('2016-09-12', 'YYYY-MM-DD'), '934827364', 'Edifici Omega',
    'Enginyeria de Telecomunicació', 'Xarxes i Comunicació Digital')
);

-- Inserció de dades a la taula pas_obj
INSERT INTO pas_obj VALUES (
  PAS(2, '78215439R', 'Tomàs Rius', 'Av. Josep Tarradellas 98, Barcelona', '622113845',
    1850, TO_DATE('2019-03-01', 'YYYY-MM-DD'), '934111222', 'Departament de Recursos Humans',
    'Tècnic Administratiu', 'Substitució')
);

-- Inserció de dades a la taula est_grau_obj
INSERT INTO est_grau_obj VALUES (
  Est_grau(3, '39521784B', 'Irina Bonet', 'Rbla. Catalunya 45, Sabadell', '630925174',
    202235, 'ibonet@grau.upc.edu', TO_DATE('2001-11-17', 'YYYY-MM-DD'),
    'Enginyeria Biomèdica', 4, EXTRACT(YEAR FROM SYSDATE))
);

-- Inserció de dades a la taula est_cicles_obj
INSERT INTO est_cicles_obj VALUES (
  Est_cicles(4, '49018375L', 'Eric Marquès', 'C/ Indústria 76, Badalona', '679103482',
    202402, 'eric.marques@cfp.cat', TO_DATE('2005-03-03', 'YYYY-MM-DD'),
    'Mitjà', 'ASIX', 2)
);

-- PAS 5: Inserció d'objectes a la taula PERSONES
-- Inserció de Professor a la taula persones
INSERT INTO persones VALUES (
  Professor(10, '50391827N', 'Júlia Nolla', 'C/ Casanova 123, Barcelona', '654982147',
    3100, TO_DATE('2010-11-05', 'YYYY-MM-DD'), '932558741', 'Campus Nord',
    'Enginyeria Industrial', 'Organització de la Producció')
);

-- Inserció de PAS a la taula persones
INSERT INTO persones VALUES (
  PAS(11, '76482135J', 'Roger Vilaplana', 'Passeig Fabra i Puig 210, Barcelona', '699875421',
    2000, TO_DATE('2017-06-15', 'YYYY-MM-DD'), '933654987', 'Serveis Informàtics',
    'Suport Tècnic', 'Indefinit')
);

-- Inserció d'Est_grau a la taula persones
INSERT INTO persones VALUES (
  Est_grau(12, '31297854M', 'Núria Fargas', 'C/ Marina 87, Granollers', '672114985',
    202334, 'nuria.fargas@estudiant.upc.edu', TO_DATE('2002-08-23', 'YYYY-MM-DD'),
    'Enginyeria Informàtica', 4, EXTRACT(YEAR FROM SYSDATE))
);

-- Inserció d'Est_cicles a la taula persones
INSERT INTO persones VALUES (
  Est_cicles(13, '47821935H', 'Arnau Gallart', 'C/ Ample 12, Mataró', '688432761',
    202401, 'arnaug@cfp.cat', TO_DATE('2004-12-09', 'YYYY-MM-DD'),
    'Superior', 'DAM', 1)
);

-- PAS 6: Consultes de comprovació
-- Crida al mètode antiguitat()
SELECT p.nom, TREAT(VALUE(p) AS Empleat).antiguitat() AS antiguitat
FROM persones p
WHERE VALUE(p) IS OF (Empleat);

-- Crida al mètode edat()
SELECT p.nom, TREAT(VALUE(p) AS Estudiant).edat() AS edat
FROM persones p
WHERE VALUE(p) IS OF (Estudiant);

-- Crida al mètode triennis()
SELECT p.nom, TREAT(VALUE(p) AS Professor).triennis() AS triennis
FROM persones p
WHERE VALUE(p) IS OF (ONLY Professor);

-- Crida al mètode sou_anual()
SELECT p.nom, TREAT(VALUE(p) AS PAS).sou_anual() AS sou_anual
FROM persones p
WHERE VALUE(p) IS OF (ONLY PAS);

-- Crida al mètode matricules_disponibles()
SELECT p.nom, TREAT(VALUE(p) AS Est_grau).matricules_disponibles() AS disponibles
FROM persones p
WHERE VALUE(p) IS OF (ONLY Est_grau);

-- Crida al mètode descripcio()
SELECT p.nom, TREAT(VALUE(p) AS Est_cicles).descripcio() AS descripcio
FROM persones p
WHERE VALUE(p) IS OF (ONLY Est_cicles);