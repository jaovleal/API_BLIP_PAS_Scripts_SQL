create or replace PROCEDURE inserir_notificacoes_consulta IS
BEGIN
    INSERT INTO API_BLIP_PAS (
        nr_seq_segurado, 
        nr_seq_notificacao, 
        ds_mensagem, 
        cd_status, 
        dt_criacao, 
        dt_visualizacao, 
        ds_titulo
    )
    SELECT 
    s.nr_sequencia,  
    API_BLIP_PAS.NEXTVAL, 
    'Olá ' || pls_obter_dados_segurado(s.nr_sequencia, 'N') || 
    ', este é um lembrete que você tem uma consulta com ' || obter_desc_agenda(a.cd_agenda) ||
    ' para o dia ' || obter_data_agenda_consulta(a.nr_sequencia) || ' ' || 
    pkg_date_formaters.to_varchar(a.dt_agenda, 'shortTime', wheb_usuario_pck.get_cd_estabelecimento(), wheb_usuario_pck.get_nm_usuario()) || '.' 
    AS ds_mensagem,
    1,
    SYSDATE,
    NULL,
    'Padre Albino Saúde'
    FROM agenda_consulta a
    JOIN pls_segurado s ON a.cd_pessoa_fisica = s.cd_pessoa_fisica 
    WHERE TRUNC(a.dt_agenda) = TRUNC(SYSDATE + 1)  
    AND a.cd_convenio = 3
    AND a.ie_status_agenda <> 'C';
COMMIT;
END inserir_notificacoes_consulta;
