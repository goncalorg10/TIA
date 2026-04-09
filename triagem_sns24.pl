% =============================================================================
% SISTEMA DE TRIAGEM SNS24 — Ponto de Entrada
% Técnicas de Inteligência Artificial — LEGSI / LCD — 2025/2026
% =============================================================================
% Para iniciar o sistema em SWI-Prolog:
%
%   ?- [triagem_sns24].
%   ?- iniciar.
%
% Ou directamente da linha de comandos:
%
%   swipl triagem_sns24.pl -g iniciar
% =============================================================================

:- use_module(base_dados).
:- use_module(base_conhecimento).
:- use_module(inferencia).
:- use_module(interface).

% Inicia automaticamente ao carregar o ficheiro (opcional)
:- initialization(main, main).

main :-
    iniciar.




















