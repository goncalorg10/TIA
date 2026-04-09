% =============================================================================
% BASE DE CONHECIMENTO — Sistema de Triagem SNS24 (Sintomas Neurológicos)
% Técnicas de Inteligência Artificial — LEGSI / LCD — 2025/2026
% =============================================================================
% Representa o conhecimento clínico sob a forma de regras de produção.
% Cada regra associa um conjunto de sintomas/fatores a uma disposição final,
% acompanhada de um Fator de Certeza (FC) no intervalo [-1, 1].
%
% Disposições finais possíveis:
%   inem               — Emergência: ligar 112 imediatamente
%   su_urgente         — Serviço de Urgência com urgência
%   su_programado      — Serviço de Urgência sem urgência imediata
%   autocuidado_seguimento — Ficar em casa + seguimento SNS24 em 24h
%   autocuidado        — Gerir em casa, sem seguimento necessário
% =============================================================================

:- module(base_conhecimento, [disposicao/3]).

:- use_module(base_dados).
:- use_module(inferencia).

% -----------------------------------------------------------------------------
% PRÉ-TRIAGEM — ABC (Avaliação de Emergência Imediata)
% Estas regras têm prioridade máxima e FC = 1.0
% -----------------------------------------------------------------------------

% A — Alteração do estado de consciência grave
disposicao(inem, 1.0, ['Perda de consciência: emergência neurológica imediata']) :-
    tem_sintoma(perda_consciencia).

% B — Dificuldade respiratória grave
disposicao(inem, 1.0, ['Dificuldade respiratória grave: compromisso das vias aéreas']) :-
    tem_sintoma(dificuldade_respiratoria_grave).

% C — Hemorragia grave
disposicao(inem, 1.0, ['Hemorragia grave: risco de vida imediato']) :-
    tem_sintoma(hemorragia_grave).

% -----------------------------------------------------------------------------
% REGRAS NEUROLÓGICAS — EMERGÊNCIA (INEM / SU Urgente)
% -----------------------------------------------------------------------------

% AVC agudo — triada clássica: fraqueza unilateral + dificuldade a falar + início súbito
disposicao(inem, 0.95, [
    'Fraqueza/dormência unilateral de início súbito',
    'Dificuldade em falar ou compreender',
    'Início há menos de 1 hora: janela terapêutica para AVC'
]) :-
    tem_sintoma(fraqueza_unilateral),
    tem_sintoma(dificuldade_falar),
    tem_fator(inicio_subito).

% AVC provável — fraqueza unilateral + alteração visual súbita
disposicao(inem, 0.90, [
    'Fraqueza/dormência unilateral',
    'Alteração visual súbita',
    'Quadro sugestivo de AVC: activar 112'
]) :-
    tem_sintoma(fraqueza_unilateral),
    tem_sintoma(alteracao_visual).

% Cefaleia em trovoada — possível hemorragia subaracnoide
disposicao(inem, 0.92, [
    'Cefaleia de início súbito e intensidade máxima (tipo trovoada)',
    'Possível hemorragia subaracnoide: risco de vida'
]) :-
    tem_sintoma(cefaleia),
    tem_fator(inicio_subito),
    tem_fator(intensidade_maxima).

% Convulsão ativa ou prolongada (> 5 min)
disposicao(inem, 0.95, [
    'Convulsão em curso ou prolongada',
    'Risco de estado de mal epilético: emergência'
]) :-
    tem_sintoma(convulsao),
    tem_fator(convulsao_prolongada).

% Confusão súbita com febre alta — possível meningite/encefalite
disposicao(inem, 0.88, [
    'Confusão mental de início súbito',
    'Febre associada',
    'Suspeita de meningite/encefalite: emergência infecciosa'
]) :-
    tem_sintoma(confusao_mental),
    tem_sintoma(febre),
    tem_fator(inicio_subito).

% Confusão com rigidez da nuca — sinal de meningite
disposicao(inem, 0.93, [
    'Confusão mental',
    'Rigidez da nuca: sinal meníngeo',
    'Suspeita de meningite bacteriana: emergência'
]) :-
    tem_sintoma(confusao_mental),
    tem_sintoma(rigidez_nuca).

% -----------------------------------------------------------------------------
% REGRAS NEUROLÓGICAS — URGENTE (Serviço de Urgência)
% -----------------------------------------------------------------------------

% AVC menos agudo — fraqueza unilateral sem critérios de emergência imediata
disposicao(su_urgente, 0.85, [
    'Fraqueza/dormência unilateral',
    'Sem outros sinais de alarme imediatos',
    'Avaliação urgente no SU recomendada'
]) :-
    tem_sintoma(fraqueza_unilateral),
    \+ tem_fator(inicio_subito).

% Cefaleia intensa com fatores de risco cardiovascular
disposicao(su_urgente, 0.80, [
    'Cefaleia de intensidade elevada',
    'Fator de risco cardiovascular presente (HTA / diabetes)',
    'Avaliação urgente no SU'
]) :-
    tem_sintoma(cefaleia),
    tem_fator(intensidade_elevada),
    ( tem_fator(hipertensao) ; tem_fator(diabetes) ).

% Cefaleia com febre (sem sinais meníngeos) — possível infecção SNC
disposicao(su_urgente, 0.78, [
    'Cefaleia associada a febre',
    'Sem rigidez da nuca identificada',
    'Avaliação no SU recomendada para exclusão de causa infecciosa'
]) :-
    tem_sintoma(cefaleia),
    tem_sintoma(febre),
    \+ tem_sintoma(rigidez_nuca).

% Convulsão isolada com recuperação completa
disposicao(su_urgente, 0.82, [
    'Convulsão com recuperação espontânea completa',
    'Avaliação urgente no SU para investigação etiológica'
]) :-
    tem_sintoma(convulsao),
    \+ tem_fator(convulsao_prolongada).

% Vertigens intensas com vómitos e incapacidade de marcha
disposicao(su_urgente, 0.75, [
    'Vertigens intensas com vómitos',
    'Incapacidade de marcha',
    'Avaliação no SU: excluir causa central'
]) :-
    tem_sintoma(vertigens),
    tem_sintoma(vomitos),
    tem_fator(incapacidade_marcha).

% Alteração visual súbita isolada
disposicao(su_urgente, 0.80, [
    'Alteração visual/visão dupla de início súbito',
    'Avaliação urgente: excluir causa neurológica ou vascular'
]) :-
    tem_sintoma(alteracao_visual),
    tem_fator(inicio_subito),
    \+ tem_sintoma(fraqueza_unilateral).

% Idoso com confusão mental aguda (delirium)
disposicao(su_urgente, 0.78, [
    'Confusão mental aguda',
    'Idade superior a 65 anos: risco elevado de causa orgânica grave',
    'Avaliação urgente no SU'
]) :-
    tem_sintoma(confusao_mental),
    tem_fator(idade_superior_65).

% -----------------------------------------------------------------------------
% REGRAS — SU PROGRAMADO (menos urgente)
% -----------------------------------------------------------------------------

% Cefaleia moderada sem fatores de alarme, recorrente
disposicao(su_programado, 0.65, [
    'Cefaleia de intensidade moderada',
    'Sem fatores de alarme identificados',
    'Consulta médica programada recomendada'
]) :-
    tem_sintoma(cefaleia),
    tem_fator(intensidade_moderada),
    \+ tem_sintoma(febre),
    \+ tem_sintoma(fraqueza_unilateral),
    \+ tem_fator(inicio_subito).

% Vertigens sem sinais de alarme, com recuperação
disposicao(su_programado, 0.60, [
    'Vertigens com recuperação parcial',
    'Sem vómitos incapacitantes',
    'Avaliação programada recomendada'
]) :-
    tem_sintoma(vertigens),
    \+ tem_sintoma(vomitos),
    \+ tem_fator(incapacidade_marcha).

% Confusão ligeira episódica em idoso sem febre
disposicao(su_programado, 0.62, [
    'Confusão mental ligeira e episódica',
    'Sem febre ou outros sinais de alarme',
    'Avaliação médica programada recomendada'
]) :-
    tem_sintoma(confusao_mental),
    \+ tem_sintoma(febre),
    \+ tem_fator(idade_superior_65).

% -----------------------------------------------------------------------------
% REGRAS — AUTOCUIDADO COM SEGUIMENTO
% -----------------------------------------------------------------------------

% Cefaleia ligeira tensional sem fatores de risco
disposicao(autocuidado_seguimento, 0.70, [
    'Cefaleia de baixa intensidade, tipo tensional',
    'Sem fatores de risco ou sinais de alarme',
    'Autocuidado: repouso, hidratação, analgesia OTC',
    'Seguimento SNS24 em 24h se agravamento'
]) :-
    tem_sintoma(cefaleia),
    tem_fator(intensidade_baixa),
    \+ tem_sintoma(febre),
    \+ tem_sintoma(fraqueza_unilateral),
    \+ tem_fator(hipertensao),
    \+ tem_fator(diabetes).

% Vertigens ligeiras isoladas
disposicao(autocuidado_seguimento, 0.65, [
    'Vertigens ligeiras sem outros sintomas neurológicos',
    'Autocuidado: repouso, evitar movimentos bruscos',
    'Seguimento se persistência além de 24h'
]) :-
    tem_sintoma(vertigens),
    \+ tem_sintoma(confusao_mental),
    \+ tem_sintoma(fraqueza_unilateral),
    \+ tem_fator(incapacidade_marcha).

% -----------------------------------------------------------------------------
% REGRA DE DEFEITO — quando não há regra específica aplicável
% -----------------------------------------------------------------------------

disposicao(autocuidado, 0.50, [
    'Sintomas sem critérios de urgência identificados',
    'Autocuidado em casa com vigilância dos sintomas',
    'Contacte novamente o SNS24 se agravamento'
]).
