% =============================================================================
% BASE DE DADOS — Sistema de Triagem SNS24
% Técnicas de Inteligência Artificial — LEGSI / LCD — 2025/2026
% =============================================================================
% Contém os factos dinâmicos sobre o utente atual.
% Estes factos são criados em tempo de execução pela interface,
% com base nas respostas do utente, e limpos no fim de cada triagem.
%
% Predicados dinâmicos:
%   tem_sintoma(+Sintoma)       — sintoma presente no utente
%   tem_fator(+Fator)           — fator agravante/contexto presente
%   dado_utente(+Campo, +Valor) — dados gerais do utente (nome, idade)
% =============================================================================

:- module(base_dados, [
    tem_sintoma/1,
    tem_fator/1,
    dado_utente/2,
    limpar_sessao/0,
    registar_sintoma/1,
    registar_fator/1,
    registar_dado/2
]).

% Declaração dinâmica — os factos são inseridos em runtime
:- dynamic tem_sintoma/1.
:- dynamic tem_fator/1.
:- dynamic dado_utente/2.

% -----------------------------------------------------------------------------
% CATÁLOGO DE SINTOMAS VÁLIDOS (para validação na interface)
% -----------------------------------------------------------------------------

sintoma_valido(perda_consciencia).
sintoma_valido(dificuldade_respiratoria_grave).
sintoma_valido(hemorragia_grave).
sintoma_valido(cefaleia).
sintoma_valido(confusao_mental).
sintoma_valido(fraqueza_unilateral).
sintoma_valido(alteracao_visual).
sintoma_valido(dificuldade_falar).
sintoma_valido(convulsao).
sintoma_valido(vertigens).
sintoma_valido(vomitos).
sintoma_valido(febre).
sintoma_valido(rigidez_nuca).

% Descrição legível de cada sintoma (para uso na interface)
descricao_sintoma(perda_consciencia,           'Perda ou alteração grave da consciência').
descricao_sintoma(dificuldade_respiratoria_grave, 'Dificuldade respiratória grave').
descricao_sintoma(hemorragia_grave,            'Hemorragia grave').
descricao_sintoma(cefaleia,                    'Dor de cabeça (cefaleia)').
descricao_sintoma(confusao_mental,             'Confusão mental ou desorientação').
descricao_sintoma(fraqueza_unilateral,         'Fraqueza ou dormência num lado do corpo').
descricao_sintoma(alteracao_visual,            'Alteração da visão ou visão dupla').
descricao_sintoma(dificuldade_falar,           'Dificuldade em falar ou compreender').
descricao_sintoma(convulsao,                   'Convulsões').
descricao_sintoma(vertigens,                   'Vertigens ou tonturas').
descricao_sintoma(vomitos,                     'Vómitos').
descricao_sintoma(febre,                       'Febre').
descricao_sintoma(rigidez_nuca,               'Rigidez da nuca').

% -----------------------------------------------------------------------------
% CATÁLOGO DE FATORES VÁLIDOS
% -----------------------------------------------------------------------------

fator_valido(inicio_subito).
fator_valido(intensidade_maxima).
fator_valido(intensidade_elevada).
fator_valido(intensidade_moderada).
fator_valido(intensidade_baixa).
fator_valido(hipertensao).
fator_valido(diabetes).
fator_valido(idade_superior_65).
fator_valido(convulsao_prolongada).
fator_valido(incapacidade_marcha).

descricao_fator(inicio_subito,       'Início súbito dos sintomas (menos de 1 hora)').
descricao_fator(intensidade_maxima,  'Intensidade máxima ("a pior dor da minha vida")').
descricao_fator(intensidade_elevada, 'Intensidade elevada (7-9 em 10)').
descricao_fator(intensidade_moderada,'Intensidade moderada (4-6 em 10)').
descricao_fator(intensidade_baixa,   'Intensidade baixa (1-3 em 10)').
descricao_fator(hipertensao,         'Hipertensão arterial conhecida').
descricao_fator(diabetes,            'Diabetes').
descricao_fator(idade_superior_65,   'Idade superior a 65 anos').
descricao_fator(convulsao_prolongada,'Convulsão com duração superior a 5 minutos').
descricao_fator(incapacidade_marcha, 'Incapacidade de andar/manter equilíbrio').

% -----------------------------------------------------------------------------
% OPERAÇÕES SOBRE A BASE DE DADOS
% -----------------------------------------------------------------------------

% Registar um sintoma (evita duplicados)
registar_sintoma(Sintoma) :-
    ( tem_sintoma(Sintoma) -> true ; assertz(tem_sintoma(Sintoma)) ).

% Registar um fator (evita duplicados)
registar_fator(Fator) :-
    ( tem_fator(Fator) -> true ; assertz(tem_fator(Fator)) ).

% Registar dado do utente
registar_dado(Campo, Valor) :-
    retractall(dado_utente(Campo, _)),
    assertz(dado_utente(Campo, Valor)).

% Limpar todos os dados da sessão corrente
limpar_sessao :-
    retractall(tem_sintoma(_)),
    retractall(tem_fator(_)),
    retractall(dado_utente(_, _)).
