INSERT INTO Location (RegName, AreaName, TerName, terTypeName)
SELECT DISTINCT REGNAME, AREANAME, TERNAME, TerTypeName
FROM zno_data;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT EORegName, EOAreaName, EOTerName
FROM zno_data
WHERE EORegName IS NOT NULL AND EOAreaName IS NOT NULL AND EOTerName IS NOT NULL
EXCEPT
SELECT RegName, areaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT UkrPTRegName, UkrPTAreaName, UkrPTTerName
FROM zno_data
WHERE UkrPTRegName IS NOT NULL AND UkrPTAreaName IS NOT NULL AND UkrPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT histPTRegName, histPTAreaName, histPTTerName
FROM zno_data
WHERE histPTRegName IS NOT NULL AND histPTAreaName IS NOT NULL AND histPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT mathPTRegName, mathPTAreaName, mathPTTerName
FROM zno_data
WHERE mathPTRegName IS NOT NULL AND mathPTAreaName IS NOT NULL AND mathPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT physPTRegName, physPTAreaName, physPTTerName
FROM zno_data
WHERE physPTRegName IS NOT NULL AND physPTAreaName IS NOT NULL AND physPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT chemPTRegName, chemPTAreaName, chemPTTerName
FROM zno_data
WHERE chemPTRegName IS NOT NULL AND chemPTAreaName IS NOT NULL AND chemPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT bioPTRegName, bioPTAreaName, bioPTTerName
FROM zno_data
WHERE bioPTRegName IS NOT NULL AND bioPTAreaName IS NOT NULL AND bioPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT geoPTRegName, geoPTAreaName, geoPTTerName
FROM zno_data
WHERE geoPTRegName IS NOT NULL AND geoPTAreaName IS NOT NULL AND geoPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT engPTRegName, engPTAreaName, engPTTerName
FROM zno_data
WHERE engPTRegName IS NOT NULL AND engPTAreaName IS NOT NULL AND engPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT fraPTRegName, fraPTAreaName, fraPTTerName
FROM zno_data
WHERE fraPTRegName IS NOT NULL AND fraPTAreaName IS NOT NULL AND fraPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT deuPTRegName, deuPTAreaName, deuPTTerName
FROM zno_data
WHERE deuPTRegName IS NOT NULL AND deuPTAreaName IS NOT NULL AND deuPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;


INSERT INTO Location (RegName, AreaName, TerName)
SELECT DISTINCT spaPTRegName, spaPTAreaName, spaPTTerName
FROM zno_data
WHERE spaPTRegName IS NOT NULL AND spaPTAreaName IS NOT NULL AND spaPTTerName IS NOT NULL
EXCEPT
SELECT RegName, AreaName, TerName
FROM Location;



DELETE FROM Location WHERE TerName IS NULL;






INSERT INTO EduInstitution(EOName, EOTypeName, loc_id, EOParent)
SELECT DISTINCT ON (allEduInfo.eduName)
	allEduInfo.eduName,
	zno_data.EOTypeName,
	Location.loc_id,
	zno_data.EOParent
FROM (
    select distinct *
    FROM (
        SELECT DISTINCT EOName, EOTerName, EOAreaName, EORegName FROM zno_data
        UNION SELECT DISTINCT ukrPTName,  ukrPTTerName,  ukrPTAreaName,  ukrPTRegName  FROM zno_data
        UNION SELECT DISTINCT mathPTName, mathPTTerName, mathPTAreaName, mathPTRegName FROM zno_data
        UNION SELECT DISTINCT histPTName, histPTTerName, histPTAreaName, histPTRegName FROM zno_data
        UNION SELECT DISTINCT physPTName, physPTTerName, physPTAreaName, physPTRegName FROM zno_data
        UNION SELECT DISTINCT chemPTName, chemPTTerName, chemPTAreaName, chemPTRegName FROM zno_data
        UNION SELECT DISTINCT bioPTName,  bioPTTerName,  bioPTAreaName,  bioPTRegName  FROM zno_data
        UNION SELECT DISTINCT geoPTName,  geoPTTerName,  geoPTAreaName,  geoPTRegName  FROM zno_data
        UNION SELECT DISTINCT engPTName,  engPTTerName,  engPTAreaName,  engPTRegName  FROM zno_data
        UNION SELECT DISTINCT fraPTName,  fraPTTerName,  fraPTAreaName,  fraPTRegName  FROM zno_data
        UNION SELECT DISTINCT deuPTName,  deuPTTerName,  deuPTAreaName,  deuPTRegName  FROM zno_data
        UNION SELECT DISTINCT spaPTName,  spaPTTerName,  spaPTAreaName,  spaPTRegName  FROM zno_data
    ) as temp
) AS allEduInfo (eduName, TerName, AreaName, RegName)


LEFT JOIN zno_data ON
	allEduInfo.EduName = zno_data.EOName


LEFT JOIN Location ON
	allEduInfo.TerName = Location.TerName AND
	allEduInfo.AreaName = Location.AreaName AND
	allEduInfo.RegName = Location.RegName
WHERE allEduInfo.eduName IS NOT NULL;



INSERT INTO Participant (OutID, birth, SexTypeName, loc_id,
    ParticipType, ClassProfileName, ClassLangName, EOName)
SELECT DISTINCT ON (OutID) OutID, birth, SexTypeName, loc_id,
    RegTypeName, ClassProfileName, ClassLangName, EOName
FROM zno_data INNER JOIN Location
ON zno_data.TerTypeName = Location.TerTypeName
    AND zno_data.TerName = Location.TerName
    AND zno_data.AreaName = Location.AreaName
    AND zno_data.RegName = Location.RegName;



INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, ukrTest, Year, NULL, ukrTestStatus, NULL,
    ukrBall100, ukrBall12, ukrBall, ukrAdaptScale, UkrPTName
FROM zno_data
WHERE ukrTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, histTest, Year, histLang, histTestStatus, NULL,
    histBall100, histBall12, histBall, NULL, histPTName
FROM zno_data
WHERE histTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, mathTest, Year, mathLang, mathTestStatus, NULL,
    mathBall100, mathBall12, mathBall, NULL, mathPTName
FROM zno_data
WHERE mathTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, physTest, Year, physLang, physTestStatus, NULL,
    physBall100, physBall12, physBall, NULL, physPTName
FROM zno_data
WHERE physTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, chemTest, Year, chemLang, chemTestStatus, NULL,
    chemBall100, chemBall12, chemBall, NULL, chemPTName
FROM zno_data
WHERE chemTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, bioTest, Year, bioLang, bioTestStatus, NULL,
    bioBall100, bioBall12, bioBall, NULL, bioPTName
FROM zno_data
WHERE bioTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, geoTest, Year, geoLang, geoTestStatus, NULL,
    geoBall100, geoBall12, geoBall, NULL, geoPTName
FROM zno_data
WHERE geoTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, engTest, Year, NULL, engTestStatus, engDPALevel,
    engBall100, engBall12, engBall, NULL, engPTName
FROM zno_data
WHERE engTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, fraTest, Year, NULL, fraTestStatus, fraDPALevel,
    fraBall100, fraBall12, fraBall, NULL, fraPTName
FROM zno_data
WHERE fraTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, deuTest, Year, NULL, deuTestStatus, deuDPALevel,
    deuBall100, deuBall12, deuBall, NULL, deuPTName
FROM zno_data
WHERE deuTest IS NOT NULL;


INSERT INTO TestResult (OutID, TestName, Year, Lang, TestStatus,
    DPALevel, Ball100, Ball12, Ball, AdaptScale, PTName)
SELECT OutID, spaTest, Year, NULL, spaTestStatus, spaDPALevel,
    spaBall100, spaBall12, spaBall, NULL, spaPTName
FROM zno_data
WHERE spaTest IS NOT NULL;

