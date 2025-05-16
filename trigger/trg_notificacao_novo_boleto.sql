create or replace TRIGGER trg_notificacao_novo_boleto
AFTER INSERT ON titulo_receber
FOR EACH ROW
DECLARE
    v_nr_seq_segurado pls_segurado.nr_sequencia%TYPE;
BEGIN
    -- Verifica se o boleto está vinculado a uma pessoa física
    IF :NEW.cd_pessoa_fisica IS NOT NULL THEN
        -- Valida algumas informações do beneficiário
        SELECT s.nr_sequencia
        INTO v_nr_seq_segurado
        FROM pls_segurado s
        WHERE s.cd_pessoa_fisica = :NEW.cd_pessoa_fisica;

        -- Mensagem personalizada
        DECLARE
            v_mensagem VARCHAR2(4000);
        BEGIN
            v_mensagem := 'Olá ' || pls_obter_dados_segurado(v_nr_seq_segurado, 'N') ||
                          ', informamos que um novo boleto foi emitido em ' ||
                          TO_CHAR(:NEW.dt_emissao, 'DD/MM/YYYY') || 
                          '. Fique atento à data de vencimento: ' || TO_CHAR(:NEW.dt_vencimento, 'DD/MM/YYYY');

            -- Insere na tabela para o aplicativo
            INSERT INTO zek_app_notificacoes (
                nr_seq_segurado,
                nr_seq_notificacao,
                ds_mensagem,
                cd_status,
                dt_criacao,
                dt_visualizacao,
                ds_titulo
            )
            VALUES (
                v_nr_seq_segurado,
                SEQ_ZEK_NOTIFICACOES.NEXTVAL,
                v_mensagem,
                1,
                SYSDATE,
                NULL,
                'Padre Albino Saúde'
            );

            -- Insere na tabela da API
            INSERT INTO api_blip_pas (
                nr_seq_segurado,
                nr_seq_notificacao,
                ds_mensagem,
                cd_status,
                dt_criacao,
                dt_visualizacao,
                ds_titulo,
                cd_permissao
            )
            VALUES (
                v_nr_seq_segurado,
                SEQ_ZEK_NOTIFICACOES.CURRVAL,
                v_mensagem,
                1,
                SYSDATE,
                NULL,
                'Padre Albino Saúde',
                1
            );
        END;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        NULL;
END;