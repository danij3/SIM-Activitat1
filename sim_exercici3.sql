--1. Definiu en primer lloc tots els "type" necessaris amb CREATE OR REPLACE TYPE
--• Definiu un type per cada classe
-- ELIMINACIÓ DE TOTS ELS OBJECTES (FORÇAT AMB FORCE I PURGE)
/*DROP TABLE fasesprojecte PURGE;
DROP TABLE treballen PURGE;
DROP TABLE dirigeixen PURGE;
DROP TABLE fases PURGE;
DROP TABLE projectesestudi PURGE;
DROP TABLE projectesdesenv PURGE;
DROP TABLE tecnics PURGE;
DROP TABLE programadors PURGE;
DROP TABLE analistes PURGE;
DROP TABLE empleats PURGE;
DROP TABLE projectes PURGE;
DROP TABLE clientes PURGE;

DROP TYPE FasesProj FORCE;
DROP TYPE Treballa FORCE;
DROP TYPE Dirigeix FORCE;
DROP TYPE Fase FORCE;
DROP TYPE ProjEstudi FORCE;
DROP TYPE ProjDesenv FORCE;
DROP TYPE Tecnic FORCE;
DROP TYPE Programador FORCE;
DROP TYPE Analista FORCE;
DROP TYPE Empleat FORCE;
DROP TYPE Projecte FORCE;
DROP TYPE Client FORCE;*/
--Type Client:
CREATE OR REPLACE TYPE Client AS OBJECT (
  nif char(9),
  nom VARCHAR2(25),
  cognoms VARCHAR2(50),
  adreça VARCHAR2(100),
  telefon VARCHAR2(9),
  MEMBER FUNCTION numProj RETURN NUMBER
) NOT FINAL;
/

--Type Projecte:
CREATE OR REPLACE TYPE Projecte AS OBJECT (
  idProjecte numeric(6),
  nom VARCHAR2(50),
  descripcio VARCHAR2(100),
  nomclient REF Client,
  MEMBER FUNCTION director RETURN VARCHAR2
) NOT FINAL;
/

--Type Empleat:
CREATE OR REPLACE TYPE Empleat AS OBJECT (
  dni char(9),
  nom VARCHAR2(25),
  cognoms VARCHAR2(50),
  adreça VARCHAR2(80),
  telefon numeric(9),
  datacontracte DATE,
  MEMBER FUNCTION numProjDir RETURN NUMERIC,
  MEMBER FUNCTION numProjTreb RETURN NUMERIC,
  MEMBER FUNCTION antiguitat RETURN NUMERIC
) NOT FINAL;
/

--Type ProjDesenv heredada de Projecte:
CREATE OR REPLACE TYPE ProjDesenv UNDER Projecte (
  dataInici DATE,
  dataPrevistaFi DATE,
  MEMBER FUNCTION faseActual RETURN VARCHAR2
);
/

--Type ProjEstudi heredada de Projecte:
CREATE OR REPLACE TYPE ProjEstudi UNDER Projecte (
  preu NUMERIC(8,2),
  termini NUMERIC(3),
  MEMBER FUNCTION acceptat RETURN CHAR --Revisar lo del char1
);
/

--Type Fase
CREATE OR REPLACE TYPE Fase AS OBJECT (
  idFase NUMERIC(2),
  nom VARCHAR2(50),
  tipusEmp VARCHAR2(30),
  MEMBER FUNCTION numProj RETURN NUMBER
) NOT FINAL;
/


--• Implementeu també dos types per a les associacions Dirigeix i Treballa que inclouran referències a objectes de les classes Projecte i Empleat.
--Type Dirigeix
CREATE OR REPLACE TYPE Dirigeix AS OBJECT (
  refProjecte REF Projecte,
  refEmpleat REF Empleat
) NOT FINAL;
/

--Type Treballa
CREATE OR REPLACE TYPE Treballa AS OBJECT (
  refProjecte REF Projecte,
  refEmpleat REF Empleat
) NOT FINAL;
/

--• Implementeu un type FasesProj que inclogui referències a ProjDesenv i Fase
--Type FasesProj
CREATE OR REPLACE TYPE FasesProj AS OBJECT (
  dataInici DATE,
  dataFi DATE,
  refProjDesenv REF ProjDesenv,
  refFase REF Fase
) NOT FINAL;
/

--• Cal implementar l'herència entre les classes Projecte i Empleat, creant els subtipus necessaris.
--Type Analista heredada de Empleat:
CREATE OR REPLACE TYPE Analista UNDER Empleat (
  dataInici DATE,
  despatx VARCHAR2(10)
) NOT FINAL;
/

--Type Programador heredada de Empleat:
CREATE OR REPLACE TYPE Programador UNDER Empleat (
  llenguatge VARCHAR2(40)
) NOT FINAL;
/

--Type Tecnic heredada de Empleat:
CREATE OR REPLACE TYPE Tecnic UNDER Empleat (
  titulacio VARCHAR2(40)
) NOT FINAL;
/

-- DEFINIR LOS METODOS ESTÁN HECHOS EN EL PUNTO 3!!
-------------------------------------------------------------------------------------------------------------
--2. Creeu taules per a objectes
--• Creeu taules per a totes les classes.
--• Definiu com a clau primària els atributs en negreta. Els types que hereten de Persona utilitzen la clau primària de Persona.
CREATE TABLE clientes OF Client (
    PRIMARY KEY (nif)
);

CREATE TABLE projectes OF Projecte (
    PRIMARY KEY (idProjecte)
);


CREATE TABLE empleats OF Empleat (
    PRIMARY KEY (dni)
);

CREATE TABLE analistes OF Analista (
    PRIMARY KEY (dni)
);
CREATE TABLE programadors OF Programador(
 PRIMARY KEY (dni)
);

CREATE TABLE tecnics OF Tecnic(
 PRIMARY KEY (dni)
);

CREATE TABLE projectesdesenv OF ProjDesenv(
 PRIMARY KEY (idProjecte)
);

CREATE TABLE projectesestudi OF ProjEstudi(
 PRIMARY KEY (idProjecte)
);

CREATE TABLE fases OF Fase (
    PRIMARY KEY (idFase)
);

--• Les taules corresponent a Dirigeix, Treballa i FasesProj no cal que tinguin clau primària.
CREATE TABLE dirigeixen OF Dirigeix;
CREATE TABLE treballen OF Treballa;
CREATE TABLE fasesprojecte OF FasesProj;



--• Inseriu algunes files de dades en cada taula.
INSERT INTO clientes VALUES (Client('123456789', 'Juan', 'Pérez', 'Carrer de la Pau 10', '987654321'));
INSERT INTO clientes VALUES (Client('123587789', 'Lucas', 'Pérez', 'Carrer de la Pau 10', '987654321'));

INSERT INTO projectes VALUES (Projecte(100442, 'Projecte A', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123456789')));
INSERT INTO projectes VALUES (Projecte(100443, 'Projecte B', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123587789')));
INSERT INTO projectes VALUES (Projecte(100444, 'Projecte C', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123587789')));

INSERT INTO empleats VALUES (Empleat('141111121', 'Lucas', 'Gonzalez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2020-08-15', 'YYYY-MM-DD')));
INSERT INTO empleats VALUES (Empleat('141111131', 'Marina', 'Gonzalez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2020-05-15', 'YYYY-MM-DD')));
INSERT INTO empleats VALUES (Empleat('141111132', 'Marina', 'Perez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2020-05-15', 'YYYY-MM-DD')));

INSERT INTO analistes VALUES (Analista('111111111', 'Carlos', 'Martínez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2022-01-15', 'YYYY-MM-DD'), TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'D001'));
INSERT INTO analistes VALUES (Analista('111111113', 'Carlos', 'Perez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2022-01-15', 'YYYY-MM-DD'), TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'D003'));
INSERT INTO analistes VALUES (Analista('111111114', 'Carlos', 'Gonzalez', 'Carrer de la Vaca 15', '612345678', TO_DATE('2022-01-15', 'YYYY-MM-DD'), TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'D004'));

INSERT INTO programadors VALUES (Programador('444444444', 'David', 'Sánchez', 'Carrer del Sol 25', '612345681', TO_DATE('2019-03-10', 'YYYY-MM-DD'), 'Java'));
INSERT INTO programadors VALUES (Programador('444444443', 'Lucas', 'Sánchez', 'Carrer del Sol 25', '612345681', TO_DATE('2019-03-16', 'YYYY-MM-DD'), 'Python'));

INSERT INTO tecnics VALUES (Tecnic('666666666', 'Jordi', 'Hernández', 'Carrer de la Rosa 11', '612345683', TO_DATE('2018-07-19', 'YYYY-MM-DD'), 'Enginyer en Informàtica'));
INSERT INTO tecnics VALUES (Tecnic('666666663', 'Jordi', 'Perez', 'Carrer de la Rosa 11', '612345683', TO_DATE('2018-07-19', 'YYYY-MM-DD'), 'Enginyer en Bioinformàtica'));

INSERT INTO projectesdesenv VALUES (ProjDesenv(100443, 'Projecte B', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123456789'), TO_DATE('2022-01-01', 'YYYY-MM-DD'), null));
INSERT INTO projectesdesenv VALUES (ProjDesenv(100444, 'Projecte C', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123456789'), TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD')));

INSERT INTO projectesestudi VALUES (ProjEstudi(100443, 'Projecte B', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123456789'), 5000.00, 12));
INSERT INTO projectesestudi VALUES (ProjEstudi(100444, 'Projecte C', 'Desenvolupament de software', (SELECT REF(C) FROM clientes c WHERE c.nif = '123456789'), 5000.00, 12));

INSERT INTO fases VALUES (Fase(1, 'Planificacio', 'Analista'));
INSERT INTO fases VALUES (Fase(2, 'Execució', 'Analista'));

INSERT INTO dirigeixen VALUES (Dirigeix((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100442), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111111')));
INSERT INTO dirigeixen VALUES (Dirigeix((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100443), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111113')));
INSERT INTO dirigeixen VALUES (Dirigeix((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100444), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111113')));

INSERT INTO treballen VALUES (Treballa((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100442), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111111')));
INSERT INTO treballen VALUES (Treballa((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100443), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111114')));
INSERT INTO treballen VALUES (Treballa((SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100444), (SELECT REF(e) FROM empleats e WHERE e.dni = '111111114')));

INSERT INTO fasesprojecte VALUES (FasesProj(TO_DATE('2022-01-01', 'YYYY-MM-DD'), null,(SELECT REF(pd) FROM projectesdesenv pd WHERE pd.idProjecte = 100442), (SELECT REF(f) FROM fases f WHERE f.idFase = 1)));
        
INSERT INTO fasesprojecte VALUES (FasesProj(TO_DATE('2022-01-01', 'YYYY-MM-DD'), null,(SELECT REF(pd) FROM projectesdesenv pd WHERE pd.idProjecte = 100443),(SELECT REF(f) FROM fases f WHERE f.idFase = 2)));

INSERT INTO fasesprojecte VALUES (FasesProj(TO_DATE('2022-01-01', 'YYYY-MM-DD'), null,(SELECT REF(pd) FROM projectesdesenv pd WHERE pd.idProjecte = 100444),(SELECT REF(f) FROM fases f WHERE f.idFase = 2)));


-------------------------------------------------------------------------------------------------------------
--3. Implementeu els mètodes de les classes amb CREATE OR REPLACE TYPE BODY
--• El mètode director() de Projecte mostrarà el nom i cognoms del director del projecte. Cal concatenar els diferents valors en una cadena de text (varchar) amb ||
CREATE OR REPLACE TYPE BODY Projecte AS 
MEMBER FUNCTION director RETURN VARCHAR2 IS
nomDirector VARCHAR2(25);
cognomDirector VARCHAR2(25);
BEGIN
    SELECT e.nom, e.cognoms
    INTO nomDirector, cognomDirector
    FROM empleats e
    WHERE REF(e) IN (SELECT refEmpleat FROM dirigeixen d WHERE DEREF(d.refProjecte).idProjecte = self.idProjecte);
    
    RETURN 'DirProj: ' || nomDirector || ' ' || cognomDirector;
      EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Sense director assignat';
    END director;
END;
/
--• El mètode acceptat() torna cert (T) si existeix un objecte en la taula d'objectes ProjDesenv corresponent al mateix «id» de projecte.
CREATE OR REPLACE TYPE BODY ProjEstudi AS
  MEMBER FUNCTION acceptat RETURN CHAR IS
  existeProj NUMBER;
   BEGIN
    -- Verifica si existe un proyecto con el mismo idProjecte en la tabla ProjDesenv
    SELECT COUNT(*)
    INTO existeProj
    FROM ProjectesEstudi pe
    WHERE pe.idProjecte = self.idProjecte;
    
    IF existeProj > 0 THEN
      RETURN 'T';  
    ELSE
      RETURN 'F'; 
    END IF;
  END acceptat;
END;
/

--• El mètode numProjDir() d’empleat compta quants projectes dirigeix un empleat.
--• El mètode numProjTreb() d’empleat compta en quants projectes està treballant un empleat.
--• El mètode antiguitat() de Empleat ha de calcular la diferència en anys entre la data del sistema (sysdate) i la data de contracte (dataContracte), amb extract(year from data) es pot extreure l’any d’una data, si en lloc d’una data poseu sysdate, obtindreu l’any actual.
--3en1:
CREATE OR REPLACE TYPE BODY Empleat AS
  MEMBER FUNCTION numProjDir RETURN NUMERIC IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*) INTO num
    FROM dirigeixen d
    WHERE d.refEmpleat = (
      SELECT REF(e) FROM empleats e WHERE e.dni = self.dni
    );
    RETURN num;
  END;

  MEMBER FUNCTION numProjTreb RETURN NUMERIC IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*) INTO num
    FROM treballen t
    WHERE t.refEmpleat = (
      SELECT REF(e) FROM empleats e WHERE e.dni = self.dni
    );
    RETURN num;
  END;

  MEMBER FUNCTION antiguitat RETURN NUMERIC IS
  BEGIN
    RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM datacontracte);
  END;
END;
/

--• El mètode faseActual() torna el nom de la fase del projecte en desenvolupament que tingui dataFi=null en la taula FasesProj
CREATE OR REPLACE TYPE BODY ProjDesenv AS
  MEMBER FUNCTION faseActual RETURN VARCHAR2 IS
  nomFase VARCHAR2(50);
  BEGIN
    SELECT f.nom
    INTO nomFase
    FROM FasesProjecte fp
    JOIN Fases f ON fp.refFase = REF(f)
    WHERE fp.refProjDesenv.idProjecte = self.idProjecte AND fp.dataFi IS NULL;
    RETURN 'Fase actual: ' || nomFase;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Sense fase activa';
  END faseActual;
END;
/

--• El mètode numProj() de client compta quants projectes té el client.
CREATE OR REPLACE TYPE BODY Client AS
  MEMBER FUNCTION numProj RETURN NUMBER IS
    contarprojclient NUMBER;
  BEGIN


    SELECT COUNT(*) 
    INTO contarprojclient
    FROM projectes p
    WHERE p.nomclient = (SELECT REF(c) FROM clientes c WHERE c.nif = self.nif);
    
    RETURN contarprojclient;
  END numProj;
END;
/

--• El mètode numProj() de fase compta quants projectes hi ha en una fase.
CREATE OR REPLACE TYPE BODY Fase AS
  MEMBER FUNCTION numProj RETURN NUMBER IS
    contarprojfase NUMBER;
  BEGIN
    
    SELECT COUNT(*) 
    INTO contarprojfase
    FROM fasesprojecte p
    WHERE p.reffase = (SELECT REF(f) FROM fases f WHERE f.nom = self.nom);
    
    RETURN contarprojfase;
  END numProj;
END;
/



-------------------------------------------------------------------------------------------------------------
--4. Consulteu els atributs i les funcions membre de cada classe. Comprovant que totes les funcions membre funcionen correctament.
--Comprobar metodo director
SELECT p.nom, p.director() AS director FROM projectes p;
--Comprobar metodo faseactual
SELECT pd.idProjecte, pd.nom, pd.faseActual() AS fase_actual FROM ProjectesDesenv pd;
--Comprobar metodo acceptat 
SELECT pd.idProjecte, pd.acceptat() AS ProyectoAceptado FROM ProjectesEstudi pd;

--Comprobar metodo numProj de clientes
SELECT c.nom, c.numProj() AS numProj FROM clientes c;
--Comprobar metodo numProj de fases
SELECT f.nom, f.numProj() AS numProj FROM fases f;
--Comprobar 3 metodos empleados (mirar como comprobar)
--SELECT e.numProjDir() AS numProjDir FROM empleats e;
SELECT e.numProjDir(), e.numProjTreb(), e.antiguitat() FROM empleats e;


