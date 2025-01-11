CREATE TABLE analise_cand_2 AS
with candidato_top_n as 
(
with top_n_candidatos as
	(
		select sq_candidato, sum(dfr.qt_votos_nominais_validos ) as votos_totais_validos from dep_fed_results dfr 
		group by dfr.sq_candidato
		order by votos_totais_validos desc
		offset 1
		limit 1
	)
	select e.nm_municipio, e.sq_candidato, e.nr_candidato, e.nm_candidato, e.nm_urna_candidato, e.nm_social_candidato, e.nr_partido, e.sg_partido, e.nm_partido, sum(e.qt_votos_nominais_validos) as qt_votos_nominais_validos
    from dep_fed_results e 
	where e.sq_candidato in (select sq_candidato from top_n_candidatos)
	group by e.sq_candidato, e.nr_candidato, e.nm_candidato, e.nm_urna_candidato, e.nm_social_candidato, e.nr_partido, e.sg_partido, e.nm_partido, e.nm_municipio
)
SELECT 
    m.*,
    p.vb_pecuaria, p.vb_indust, p.vb_servicos, p.vb_adm, p.vb_total, p.impostos, p.pib, p.pip_per_capita, p.atv_maior_vb, p.atv_seg_maior_vb, p.atv_terc_maior_vb,
    e.nm_municipio, e.sq_candidato, e.nr_candidato, e.nm_candidato, e.nm_urna_candidato, e.nm_social_candidato, e.nr_partido, e.sg_partido, e.nm_partido, e.qt_votos_nominais_validos,
    d.tot_pop, d.abs_pop_branca, d.abs_pop_preta, d.abs_pop_amarela, d.abs_pop_parda, d.abs_pop_indigena, d.ignorados, d.perc_branca, d.perc_preta, d.perc_amarela, d.perc_parda, d.perc_indigena, d.abs_indigena_cor_raca, d.perc_indigena_cor_raca,
    (e.qt_votos_nominais_validos::DECIMAL / NULLIF(d.tot_pop, 0)) as perc_votos_validos
FROM 
    municipios m
JOIN 
    pib_municipios p ON m.cd_mun = p.cd_mun
JOIN 
    candidato_top_n e ON upper(m.nm_mun) = e.nm_municipio
JOIN 
    distribuicao_populacao d ON m.cd_mun = d.cd_mun
WHERE 
    m.sigla_uf = 'SC' and p.ano = 2020;
