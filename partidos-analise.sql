CREATE TABLE analise_autocorrelacao_partidos AS
WITH partidos_representativos AS 
(
    SELECT 
        sg_partido, 
        SUM(qt_votos_nominais_validos) AS votos_totais
    FROM 
        dep_fed_results
    GROUP BY 
        sg_partido
    ORDER BY 
        votos_totais DESC
    LIMIT 4 
),
votos_agrupados_por_municipio AS
(
    SELECT 
        e.nm_municipio,
        e.sg_partido,
        SUM(e.qt_votos_nominais_validos) AS votos_por_partido_municipio
    FROM 
        dep_fed_results e
    WHERE 
        e.sg_partido IN (SELECT sg_partido FROM partidos_representativos)
    GROUP BY 
        e.nm_municipio, e.sg_partido
),
dados_demograficos_economicos AS
(
    SELECT 
        m.cd_mun,
        UPPER(m.nm_mun) AS nm_municipio,
        m.geom,
        d.tot_pop,
        d.area_km2,
        p.pib,
        p.pip_per_capita
    FROM 
        municipios m
    JOIN 
        distribuicao_populacao d ON m.cd_mun = d.cd_mun
    JOIN 
        pib_municipios p ON m.cd_mun = p.cd_mun
    WHERE 
        p.ano = 2020
)
SELECT 
    d.cd_mun,
    d.nm_municipio,
    d.geom,
    d.tot_pop,
    d.area_km2,
    d.pib,
    d.pip_per_capita,
    v.sg_partido,
    COALESCE(v.votos_por_partido_municipio, 0) AS votos_por_partido_municipio,
    (COALESCE(v.votos_por_partido_municipio, 0)::DECIMAL / NULLIF(d.tot_pop, 0)) AS perc_votos_municipio
FROM 
    dados_demograficos_economicos d
LEFT JOIN 
    votos_agrupados_por_municipio v ON d.nm_municipio = v.nm_municipio;
