-----------------------------------------------------------------------------------
-- SCRIPT CORREGIT I EXECUTABLE PER L'EXERCICI 3 - SIMM BDOR ORACLE
-- Autor: [Corregit amb ajuda d'IA]
-- Data: 2025-04-04
-----------------------------------------------------------------------------------

-- ELIMINACIÓ DE TOTS ELS OBJECTES (FORÇAT AMB FORCE I PURGE)
DROP TABLE fasesprojecte PURGE;
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
DROP TYPE Client FORCE;

-----------------------------------------------------------------------------------
-- DEFINICIÓ DE TYPES
-----------------------------------------------------------------------------------

CREATE OR REPLACE TYPE Client AS OBJECT (
  nif CHAR(9),
  nom VARCHAR2(25),
  cognoms VARCHAR2(50),
  adreça VARCHAR2(100),
  telefon VARCHAR2(9),
  MEMBER FUNCTION numProj RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE Projecte AS OBJECT (
  idProjecte NUMERIC(6),
  nom VARCHAR2(50),
  descripcio VARCHAR2(100),
  nomclient REF Client,
  MEMBER FUNCTION director RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE Empleat AS OBJECT (
  dni CHAR(9),
  nom VARCHAR2(25),
  cognoms VARCHAR2(50),
  adreça VARCHAR2(80),
  telefon NUMERIC(9),
  datacontracte DATE,
  MEMBER FUNCTION numProjDir RETURN NUMERIC,
  MEMBER FUNCTION numProjTreb RETURN NUMERIC,
  MEMBER FUNCTION antiguitat RETURN NUMERIC
) NOT FINAL;
/

CREATE OR REPLACE TYPE ProjDesenv UNDER Projecte (
  dataInici DATE,
  dataPrevistaFi DATE,
  MEMBER FUNCTION faseActual RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE ProjEstudi UNDER Projecte (
  preu NUMERIC(8,2),
  termini NUMERIC(3),
  MEMBER FUNCTION acceptat RETURN CHAR
);
/

CREATE OR REPLACE TYPE Fase AS OBJECT (
  idFase NUMERIC(2),
  nom VARCHAR2(50),
  tipusEmp VARCHAR2(30),
  MEMBER FUNCTION numProj RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE Dirigeix AS OBJECT (
  refProjecte REF Projecte,
  refEmpleat REF Empleat
) NOT FINAL;
/

CREATE OR REPLACE TYPE Treballa AS OBJECT (
  refProjecte REF Projecte,
  refEmpleat REF Empleat
) NOT FINAL;
/

CREATE OR REPLACE TYPE FasesProj AS OBJECT (
  dataInici DATE,
  dataFi DATE,
  refProjDesenv REF ProjDesenv,
  refFase REF Fase
) NOT FINAL;
/

CREATE OR REPLACE TYPE Analista UNDER Empleat (
  dataInici DATE,
  despatx VARCHAR2(10)
) NOT FINAL;
/

CREATE OR REPLACE TYPE Programador UNDER Empleat (
  llenguatge VARCHAR2(40)
) NOT FINAL;
/

CREATE OR REPLACE TYPE Tecnic UNDER Empleat (
  titulacio VARCHAR2(40)
) NOT FINAL;
/


-----------------------------------------------------------------------------------
-- CREACIÓ DE TAULES
-----------------------------------------------------------------------------------

CREATE TABLE clientes OF Client (PRIMARY KEY(nif));
CREATE TABLE projectes OF Projecte (PRIMARY KEY(idProjecte));
CREATE TABLE empleats OF Empleat (PRIMARY KEY(dni));
CREATE TABLE analistes OF Analista (PRIMARY KEY(dni));
CREATE TABLE programadors OF Programador (PRIMARY KEY(dni));
CREATE TABLE tecnics OF Tecnic (PRIMARY KEY(dni));
CREATE TABLE projectesdesenv OF ProjDesenv (PRIMARY KEY(idProjecte));
CREATE TABLE projectesestudi OF ProjEstudi (PRIMARY KEY(idProjecte));
CREATE TABLE fases OF Fase (PRIMARY KEY(idFase));
CREATE TABLE dirigeixen OF Dirigeix;
CREATE TABLE treballen OF Treballa;
CREATE TABLE fasesprojecte OF FasesProj;

-----------------------------------------------------------------------------------
-- DEFINICIÓ DE TYPE BODY
-----------------------------------------------------------------------------------

-- Client
CREATE OR REPLACE TYPE BODY Client AS
  MEMBER FUNCTION numProj RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*) INTO num
    FROM projectes p
    WHERE p.nomclient = (
      SELECT REF(c) FROM clientes c WHERE c.nif = self.nif
    );
    RETURN num;
  END;
END;
/

-- Projecte
CREATE OR REPLACE TYPE BODY Projecte AS
  MEMBER FUNCTION director RETURN VARCHAR2 IS
    nom VARCHAR2(50);
    cognoms VARCHAR2(50);
  BEGIN
    SELECT e.nom, e.cognoms
    INTO nom, cognoms
    FROM empleats e
    WHERE REF(e) IN (
      SELECT d.refEmpleat
      FROM dirigeixen d
      WHERE d.refProjecte = (
        SELECT REF(p) FROM projectes p WHERE p.idProjecte = Self.idProjecte
      )
    );
    RETURN 'DirProj: ' || nom || ' ' || cognoms;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Sense director assignat';
  END;
END;
/

-- Empleat
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

-- ProjDesenv
CREATE OR REPLACE TYPE BODY ProjDesenv AS
  MEMBER FUNCTION faseActual RETURN VARCHAR2 IS
    nomFase VARCHAR2(50);
  BEGIN
    SELECT f.nom INTO nomFase
    FROM fasesprojecte fp
    JOIN fases f ON fp.refFase = (
      SELECT REF(f2) FROM fases f2 WHERE f2.idFase = f.idFase
    )
    WHERE fp.refProjDesenv = (
      SELECT REF(pd) FROM projectesdesenv pd WHERE pd.idProjecte = Self.idProjecte
    )
    AND fp.dataFi IS NULL;

    RETURN 'Fase actual: ' || nomFase;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Sense fase activa';
  END;
END;
/

-- ProjEstudi
CREATE OR REPLACE TYPE BODY ProjEstudi AS
  MEMBER FUNCTION acceptat RETURN CHAR IS
    existeix NUMBER;
  BEGIN
    SELECT COUNT(*) INTO existeix
    FROM projectesdesenv p
    WHERE p.idProjecte = self.idProjecte;
    IF existeix > 0 THEN
      RETURN 'T';
    ELSE
      RETURN 'F';
    END IF;
  END;
END;
/

-- Fase
CREATE OR REPLACE TYPE BODY Fase AS
  MEMBER FUNCTION numProj RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*) INTO num
    FROM fasesprojecte fp
    WHERE fp.refFase = (
      SELECT REF(f) FROM fases f WHERE f.idFase = Self.idFase
    );
    RETURN num;
  END;
END;
/
-----------------------------------------------------------------------------------
-- INSERTS
-----------------------------------------------------------------------------------

INSERT INTO clientes VALUES (
  Client('123456789', 'Juan', 'Pérez', 'Carrer de la Pau 10', '987654321')
);

INSERT INTO projectes VALUES (
  Projecte(100442, 'Projecte B', 'Desenvolupament de software', 
  (SELECT REF(c) FROM clientes c WHERE c.nif = '123456789'))
);

INSERT INTO empleats VALUES (
  Empleat('141111121', 'Lucas', 'Gonzalez', 'Carrer de la Vaca 15', '612345678',
  TO_DATE('2020-08-15', 'YYYY-MM-DD'))
);

INSERT INTO analistes VALUES (
  Analista('111111111', 'Carlos', 'Martínez', 'Carrer de la Vaca 15', '612345678',
  TO_DATE('2022-01-15', 'YYYY-MM-DD'), TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'D001')
);

INSERT INTO programadors VALUES (
  Programador('444444444', 'David', 'Sánchez', 'Carrer del Sol 25', '612345681',
  TO_DATE('2019-03-10', 'YYYY-MM-DD'), 'Java')
);

INSERT INTO tecnics VALUES (
  Tecnic('666666666', 'Jordi', 'Hernández', 'Carrer de la Rosa 11', '612345683',
  TO_DATE('2018-07-19', 'YYYY-MM-DD'), 'Enginyer en Informàtica')
);

INSERT INTO projectesdesenv VALUES (
  ProjDesenv(100443, 'Projecte A', 'Desenvolupament de software', 
  (SELECT REF(c) FROM clientes c WHERE c.nif = '123456789'), TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL)
);

INSERT INTO projectesestudi VALUES (
  ProjEstudi(100444, 'Projecte C', 'Estudi de viabilitat', 
  (SELECT REF(c) FROM clientes c WHERE c.nif = '123456789'), 5000.00, 12)
);

INSERT INTO fases VALUES (
  Fase(2, 'Execució', 'Analista')
);

INSERT INTO dirigeixen VALUES (
  Dirigeix(
    (SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100442),
    (SELECT REF(e) FROM empleats e WHERE e.dni = '141111121')
  )
);

INSERT INTO treballen VALUES (
  Treballa(
    (SELECT REF(p) FROM projectes p WHERE p.idProjecte = 100442),
    (SELECT REF(e) FROM empleats e WHERE e.dni = '141111121')
  )
);

INSERT INTO fasesprojecte VALUES (
  FasesProj(TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL,
    (SELECT REF(pd) FROM projectesdesenv pd WHERE pd.idProjecte = 100443),
    (SELECT REF(f) FROM fases f WHERE f.idFase = 2))
);

-----------------------------------------------------------------------------------
-- COMPROVACIONS
-----------------------------------------------------------------------------------

SELECT p.nom, p.director() FROM projectes p;
SELECT pd.faseActual() FROM projectesdesenv pd;
SELECT pe.acceptat() FROM projectesestudi pe;
SELECT c.numProj() FROM clientes c;
SELECT f.numProj() FROM fases f;
SELECT e.numProjDir(), e.numProjTreb(), e.antiguitat() FROM empleats e;
