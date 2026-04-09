% =============================================================================
% SISTEMA DE INFERÊNCIA — Sistema de Triagem SNS24
% Técnicas de Inteligência Artificial — LEGSI / LCD — 2025/2026
% =============================================================================
% Motor de inferência por encadeamento progressivo (forward chaining),
% com suporte a Fatores de Certeza (FC) inspirado no modelo MYCIN.
%
% Fórmulas de combinação de FC:
%   FC_combinado = FC1 + FC2 * (1 - FC1)   quando FC1 >= 0 e FC2 >= 0
%   FC_combinado = FC1 + FC2 * (1 + FC1)   quando FC1 <  0 e FC2 <  0
%   FC_combinado = (FC1 + FC2) / (1 - min(|FC1|,|FC2|))  caso misto
% =============================================================================

:- module(inferencia, [
    inferir/1,
    inferir_com_explicacao/2,
    combinar_fc/3,
    classificar_disposicao/2,
    disposicao_label/2
]).

:- use_module(base_conhecimento).

% -----------------------------------------------------------------------------
% PONTO DE ENTRADA — Inferir a melhor disposição final
% -----------------------------------------------------------------------------

% inferir(-Resultado)
% Resultado = disposicao(Disposicao, FC, Explicacao)
% Devolve a disposição com maior FC entre todas as regras satisfeitas.
% Em caso de empate, dá preferência à de maior gravidade.
inferir(melhor(Disposicao, FC, Explicacao)) :-
    findall(
        candidato(FC, Disposicao, Explicacao),
        disposicao(Disposicao, FC, Explicacao),
        Candidatos
    ),
    Candidatos \= [],
    melhor_candidato(Candidatos, Disposicao, FC, Explicacao).

% Seleciona o candidato com maior FC; em empate, maior gravidade
melhor_candidato(Candidatos, Disposicao, FC, Explicacao) :-
    predsort(comparar_candidatos, Candidatos, [candidato(FC, Disposicao, Explicacao)|_]).

% Ordem de comparação: maior FC primeiro; em empate, maior gravidade
comparar_candidatos(Ordem, candidato(FC1, D1, _), candidato(FC2, D2, _)) :-
    ( FC1 > FC2  -> Ordem = (<)
    ; FC1 < FC2  -> Ordem = (>)
    ; gravidade(D1, G1), gravidade(D2, G2),
      ( G1 < G2  -> Ordem = (<)
      ; G1 > G2  -> Ordem = (>)
      ;             Ordem = (=)
      )
    ).

% Gravidade numérica de cada disposição (menor número = mais grave)
gravidade(inem,                   1).
gravidade(su_urgente,             2).
gravidade(su_programado,          3).
gravidade(autocuidado_seguimento, 4).
gravidade(autocuidado,            5).

% -----------------------------------------------------------------------------
% INFERÊNCIA COM EXPLICAÇÃO DETALHADA (P1MAX)
% -----------------------------------------------------------------------------

% inferir_com_explicacao(-Disposicao, -RelatorioCompleto)
% Devolve TODAS as regras ativadas, ordenadas por FC, para explicação ao utente.
inferir_com_explicacao(melhor(Disposicao, FC, Explicacao), TodasRegras) :-
    findall(
        candidato(FC_r, Disp_r, Expl_r),
        disposicao(Disp_r, FC_r, Expl_r),
        Candidatos
    ),
    predsort(comparar_candidatos, Candidatos, [candidato(FC, Disposicao, Explicacao)|RestoCandidatos]),
    TodasRegras = [candidato(FC, Disposicao, Explicacao)|RestoCandidatos].

% -----------------------------------------------------------------------------
% COMBINAÇÃO DE FATORES DE CERTEZA — Modelo MYCIN
% -----------------------------------------------------------------------------

% combinar_fc(+FC1, +FC2, -FCCombinado)
combinar_fc(FC1, FC2, FC) :-
    ( FC1 >= 0, FC2 >= 0 ->
        FC is FC1 + FC2 * (1 - FC1)
    ; FC1 < 0, FC2 < 0 ->
        FC is FC1 + FC2 * (1 + FC1)
    ;
        Min is min(abs(FC1), abs(FC2)),
        ( Min =:= 1 -> FC is 0
        ; FC is (FC1 + FC2) / (1 - Min)
        )
    ).

% combinar_lista_fc(+ListaFC, -FCFinal)
combinar_lista_fc([], 0).
combinar_lista_fc([FC], FC).
combinar_lista_fc([FC1, FC2 | Resto], FCFinal) :-
    combinar_fc(FC1, FC2, FCCombinado),
    combinar_lista_fc([FCCombinado | Resto], FCFinal).

% -----------------------------------------------------------------------------
% CLASSIFICAÇÃO DA DISPOSIÇÃO PARA APRESENTAÇÃO
% -----------------------------------------------------------------------------

% Nível de urgência (para cor/ícone na interface)
classificar_disposicao(inem,                   emergencia).
classificar_disposicao(su_urgente,             urgente).
classificar_disposicao(su_programado,          programado).
classificar_disposicao(autocuidado_seguimento, seguimento).
classificar_disposicao(autocuidado,            casa).

% Label legível em português para cada disposição
disposicao_label(inem,
    'EMERGÊNCIA — Ligue 112 (INEM) imediatamente').
disposicao_label(su_urgente,
    'URGENTE — Dirija-se ao Serviço de Urgência agora').
disposicao_label(su_programado,
    'CONSULTA — Dirija-se ao Serviço de Urgência (sem urgência imediata)').
disposicao_label(autocuidado_seguimento,
    'AUTOCUIDADO — Fique em casa; o SNS24 irá contactá-lo em 24 horas').
disposicao_label(autocuidado,
    'AUTOCUIDADO — Gerir em casa; contacte o SNS24 se houver agravamento').
