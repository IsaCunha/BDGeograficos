CREATE TABLE analise_cand_transferencias_agregada AS
WITH top_n_candidatos AS
(
SELECT 
    sq_candidato,
    SUM(dfr.qt_votos_nominais_validos) AS votos_totais_validos
FROM 
    dep_fed_results dfr
GROUP BY 
    dfr.sq_candidato
ORDER BY 
    votos_totais_validos DESC
LIMIT 5
),
votos_agregados_municipio AS
(
SELECT
    nm_municipio,
    SUM(qt_votos_nominais_validos) AS total_votos_top5
FROM
    dep_fed_results e
WHERE
    e.sq_candidato IN (SELECT sq_candidato FROM top_n_candidatos)
GROUP BY
    nm_municipio
),
transferencias_agrupadas AS
(
SELECT
    UPPER(nmmunicipiocredor) AS nm_municipio,
    SUM(vlempenhado) AS total_empenhado,
    SUM(vlliquidado) AS total_liquidado,
    SUM(vlpagoorcamentario) AS total_pago_orcamentario,
    SUM(valor_total) AS valor_total_transferencias
FROM
    transferencias_aggregadas_sc
GROUP BY
    UPPER(nmmunicipiocredor)
)
SELECT
    m.*,
    p.vb_pecuaria,
    p.vb_indust,
    p.vb_servicos,
    p.vb_adm,
    p.vb_total,
    p.impostos,
    p.pib,
    p.pip_per_capita,
    p.atv_maior_vb,
    p.atv_seg_maior_vb,
    p.atv_terc_maior_vb,
    v.total_votos_top5,
    d.tot_pop,
    d.abs_pop_branca,
    d.abs_pop_preta,
    d.abs_pop_amarela,
    d.abs_pop_parda,
    d.abs_pop_indigena,
    d.ignorados,
    d.perc_branca,
    d.perc_preta,
    d.perc_amarela,
    d.perc_parda,
    d.perc_indigena,
    d.abs_indigena_cor_raca,
    d.perc_indigena_cor_raca,
    (v.total_votos_top5::DECIMAL / NULLIF(d.tot_pop, 0)) AS perc_votos_validos,
    t.total_empenhado,
    t.total_liquidado,
    t.total_pago_orcamentario,
    t.valor_total_transferencias
FROM
    municipios m
JOIN
    pib_municipios p ON m.cd_mun = p.cd_mun
JOIN
    votos_agregados_municipio v ON UPPER(m.nm_mun) = v.nm_municipio
JOIN
    distribuicao_populacao d ON m.cd_mun = d.cd_mun
LEFT JOIN
    transferencias_agrupadas t ON UPPER(m.nm_mun) = t.nm_municipio
WHERE
    p.ano = 2020;

------
CREATE TABLE analise_cand_transferencias_ultimos_eleitos AS
WITH candidatos_ranking AS
(
SELECT 
    sq_candidato,
    SUM(dfr.qt_votos_nominais_validos) AS votos_totais_validos
FROM 
    dep_fed_results dfr
GROUP BY 
    dfr.sq_candidato
ORDER BY 
    votos_totais_validos DESC
LIMIT 6
OFFSET 10
),
votos_agregados_municipio AS
(
SELECT
    nm_municipio,
    SUM(qt_votos_nominais_validos) AS total_votos_ultimos_eleitos
FROM
    dep_fed_results e
WHERE
    e.sq_candidato IN (SELECT sq_candidato FROM candidatos_ranking)
GROUP BY
    nm_municipio
),
transferencias_agrupadas AS
(
SELECT
    UPPER(nmmunicipiocredor) AS nm_municipio,
    SUM(vlempenhado) AS total_empenhado,
    SUM(vlliquidado) AS total_liquidado,
    SUM(vlpagoorcamentario) AS total_pago_orcamentario,
    SUM(valor_total) AS valor_total_transferencias
FROM
    transferencias_aggregadas_sc
GROUP BY
    UPPER(nmmunicipiocredor)
)
SELECT
    m.*,
    p.vb_pecuaria,
    p.vb_indust,
    p.vb_servicos,
    p.vb_adm,
    p.vb_total,
    p.impostos,
    p.pib,
    p.pip_per_capita,
    p.atv_maior_vb,
    p.atv_seg_maior_vb,
    p.atv_terc_maior_vb,
    v.total_votos_ultimos_eleitos,
    d.tot_pop,
    d.abs_pop_branca,
    d.abs_pop_preta,
    d.abs_pop_amarela,
    d.abs_pop_parda,
    d.abs_pop_indigena,
    d.ignorados,
    d.perc_branca,
    d.perc_preta,
    d.perc_amarela,
    d.perc_parda,
    d.perc_indigena,
    d.abs_indigena_cor_raca,
    d.perc_indigena_cor_raca,
    (v.total_votos_ultimos_eleitos::DECIMAL / NULLIF(d.tot_pop, 0)) AS perc_votos_validos,
    t.total_empenhado,
    t.total_liquidado,
    t.total_pago_orcamentario,
    t.valor_total_transferencias
FROM
    municipios m
JOIN
    pib_municipios p ON m.cd_mun = p.cd_mun
JOIN
    votos_agregados_municipio v ON UPPER(m.nm_mun) = v.nm_municipio
JOIN
    distribuicao_populacao d ON m.cd_mun = d.cd_mun
LEFT JOIN
    transferencias_agrupadas t ON UPPER(m.nm_mun) = t.nm_municipio
WHERE
    p.ano = 2020;