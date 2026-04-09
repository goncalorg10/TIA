% =============================================================================
% INTERFACE — Sistema de Triagem SNS24
% Técnicas de Inteligência Artificial — LEGSI / LCD — 2025/2026
% =============================================================================
% Interface de texto com menus numerados.
% Fluxo: Menu Principal → Dados do Utente → Pré-triagem → Triagem →
%        Resultado + Explicação → Repetir ou Sair
% =============================================================================

:- module(interface, [iniciar/0]).

:- use_module(base_dados).
:- use_module(inferencia).

% Utilitário para limpar o ecrã (funciona na maioria dos terminais)
limpar :- write('\33\[2J\33\[H').

% Linha separadora
separador :-
    writeln('══════════════════════════════════════════════════════════════').

separador_fino :-
    writeln('──────────────────────────────────────────────────────────────').

% =============================================================================
% PONTO DE ENTRADA
% =============================================================================

iniciar :-
    limpar,
    apresentar_cabecalho,
    menu_principal.

% =============================================================================
% CABEÇALHO
% =============================================================================

apresentar_cabecalho :-
    nl,
    separador,
    writeln('       SISTEMA DE TRIAGEM SNS24 — Sintomas Neurológicos'),
    writeln('       Técnicas de Inteligência Artificial | LEGSI / LCD'),
    separador,
    nl.

% =============================================================================
% MENU PRINCIPAL
% =============================================================================

menu_principal :-
    writeln('  MENU PRINCIPAL'),
    nl,
    writeln('  [1] Iniciar nova triagem'),
    writeln('  [2] Sobre o sistema'),
    writeln('  [0] Sair'),
    nl,
    write('  Opção: '),
    read_term(Opcao, []),
    nl,
    processar_menu_principal(Opcao).

processar_menu_principal(1) :-
    limpar_sessao,
    recolher_dados_utente.
processar_menu_principal(2) :-
    mostrar_sobre,
    menu_principal.
processar_menu_principal(0) :-
    writeln('  Obrigado por utilizar o Sistema de Triagem SNS24. Cuide-se!'),
    nl.
processar_menu_principal(_) :-
    writeln('  Opção inválida. Por favor escolha 0, 1 ou 2.'),
    nl,
    menu_principal.

% =============================================================================
% SOBRE O SISTEMA
% =============================================================================

mostrar_sobre :-
    limpar,
    separador,
    writeln('  SOBRE O SISTEMA'),
    separador,
    nl,
    writeln('  Este sistema apoia a triagem clínica de sintomas neurológicos,'),
    writeln('  seguindo os protocolos Altitude do SNS24.'),
    nl,
    writeln('  Sintomas cobertos:'),
    writeln('    • Cefaleia (dor de cabeça)'),
    writeln('    • Confusão mental / desorientação'),
    writeln('    • Fraqueza ou dormência unilateral'),
    writeln('    • Alteração da visão'),
    writeln('    • Dificuldade em falar'),
    writeln('    • Convulsões'),
    writeln('    • Vertigens / tonturas'),
    nl,
    writeln('  AVISO: Este sistema é uma ferramenta de apoio à decisão.'),
    writeln('  Em caso de emergência, ligue SEMPRE para o 112.'),
    nl,
    separador,
    nl,
    write('  Prima ENTER para voltar ao menu...'),
    read_term(_, []),
    limpar.

% =============================================================================
% RECOLHA DE DADOS DO UTENTE
% =============================================================================

recolher_dados_utente :-
    limpar,
    separador,
    writeln('  DADOS DO UTENTE'),
    separador,
    nl,
    write('  Nome do utente: '),
    read_term(Nome, []),
    registar_dado(nome, Nome),
    write('  Idade: '),
    read_term(Idade, []),
    registar_dado(idade, Idade),
    ( Idade > 65 -> registar_fator(idade_superior_65) ; true ),
    nl,
    pre_triagem.

% =============================================================================
% PRÉ-TRIAGEM — Avaliação ABC (prioridade máxima)
% =============================================================================

pre_triagem :-
    limpar,
    separador,
    writeln('  PRÉ-TRIAGEM — Avaliação de Emergência Imediata'),
    separador,
    writeln('  ATENÇÃO: Em caso de resposta SIM a qualquer pergunta,'),
    writeln('  o sistema irá activar o protocolo de emergência.'),
    nl,
    perguntar_abc.

perguntar_abc :-
    % A — Consciência
    writeln('  [A] Estado de consciência'),
    separador_fino,
    pergunta_sim_nao(
        'O utente está inconsciente ou com alteração grave da consciência?',
        RespA
    ),
    ( RespA = sim ->
        registar_sintoma(perda_consciencia),
        resultado_imediato
    ;
        % B — Respiração
        nl,
        writeln('  [B] Respiração'),
        separador_fino,
        pergunta_sim_nao(
            'O utente tem dificuldade respiratória grave?',
            RespB
        ),
        ( RespB = sim ->
            registar_sintoma(dificuldade_respiratoria_grave),
            resultado_imediato
        ;
            % C — Circulação / Hemorragia
            nl,
            writeln('  [C] Circulação'),
            separador_fino,
            pergunta_sim_nao(
                'O utente tem hemorragia grave (sangramento incontrolável)?',
                RespC
            ),
            ( RespC = sim ->
                registar_sintoma(hemorragia_grave),
                resultado_imediato
            ;
                nl,
                writeln('  Pré-triagem: sem emergência imediata identificada.'),
                writeln('  A avançar para a triagem de sintomas...'),
                nl,
                write('  Prima ENTER para continuar...'),
                read_term(_, []),
                triagem_sintomas
            )
        )
    ).

% Resultado imediato para emergências ABC
resultado_imediato :-
    limpar,
    separador,
    writeln('  !! EMERGÊNCIA IDENTIFICADA NA PRÉ-TRIAGEM !!'),
    separador,
    nl,
    writeln('  LIGUE IMEDIATAMENTE PARA O 112 (INEM)'),
    nl,
    writeln('  Enquanto aguarda a ambulância:'),
    writeln('    • Mantenha o utente deitado em posição lateral de segurança'),
    writeln('    • Não dê nada a comer ou beber'),
    writeln('    • Não deixe o utente desacompanhado'),
    nl,
    separador,
    nl,
    menu_pos_triagem.

% =============================================================================
% TRIAGEM DE SINTOMAS NEUROLÓGICOS
% =============================================================================

triagem_sintomas :-
    limpar,
    separador,
    writeln('  TRIAGEM — Sintomas Neurológicos'),
    separador,
    nl,
    writeln('  Vou agora perguntar sobre os sintomas presentes.'),
    writeln('  Responda com o número da opção correspondente.'),
    nl,
    recolher_sintomas,
    recolher_fatores,
    calcular_e_apresentar_resultado.

% --- Recolha de sintomas ---

recolher_sintomas :-
    writeln('  SINTOMAS PRESENTES'),
    separador_fino,
    writeln('  Selecione os sintomas que o utente apresenta (pode selecionar vários):'),
    nl,
    mostrar_lista_sintomas,
    nl,
    write('  Introduza os números separados por vírgula (ex: 1,3,5) ou 0 para nenhum: '),
    read_term(Input, []),
    processar_selecao_sintomas(Input).

mostrar_lista_sintomas :-
    findall(S, sintoma_valido(S), Sintomas),
    mostrar_numerado(Sintomas, 1).

mostrar_numerado([], _).
mostrar_numerado([S|Resto], N) :-
    descricao_sintoma(S, Desc),
    format('  [~w] ~w~n', [N, Desc]),
    N1 is N + 1,
    mostrar_numerado(Resto, N1).

processar_selecao_sintomas(0) :- !.
processar_selecao_sintomas(Input) :-
    findall(S, sintoma_valido(S), Sintomas),
    ( is_list(Input) -> Nums = Input ; Nums = [Input] ),
    maplist(registar_sintoma_por_numero(Sintomas), Nums).

registar_sintoma_por_numero(Sintomas, Num) :-
    ( integer(Num), Num > 0, nth1(Num, Sintomas, Sintoma) ->
        registar_sintoma(Sintoma)
    ;
        format('  Aviso: opção ~w ignorada (inválida).~n', [Num])
    ).

% --- Recolha de fatores agravantes ---

recolher_fatores :-
    nl,
    writeln('  FATORES ADICIONAIS'),
    separador_fino,
    writeln('  Selecione os fatores que se aplicam:'),
    nl,
    % Se há cefaleia, perguntar intensidade
    ( tem_sintoma(cefaleia) ->
        perguntar_intensidade_cefaleia
    ; true ),
    % Início súbito
    pergunta_sim_nao(
        'Os sintomas tiveram início súbito (menos de 1 hora)?',
        RespSubito
    ),
    ( RespSubito = sim -> registar_fator(inicio_subito) ; true ),
    nl,
    % Fatores de risco
    writeln('  Antecedentes relevantes:'),
    pergunta_sim_nao('O utente tem hipertensão arterial?', RespHTA),
    ( RespHTA = sim -> registar_fator(hipertensao) ; true ),
    pergunta_sim_nao('O utente tem diabetes?', RespDM),
    ( RespDM = sim -> registar_fator(diabetes) ; true ),
    % Convulsão prolongada
    ( tem_sintoma(convulsao) ->
        pergunta_sim_nao(
            'A convulsão durou mais de 5 minutos?',
            RespConv
        ),
        ( RespConv = sim -> registar_fator(convulsao_prolongada) ; true )
    ; true ),
    % Incapacidade de marcha
    ( tem_sintoma(vertigens) ->
        pergunta_sim_nao(
            'O utente está incapaz de andar / manter equilíbrio?',
            RespMarcha
        ),
        ( RespMarcha = sim -> registar_fator(incapacidade_marcha) ; true )
    ; true ).

perguntar_intensidade_cefaleia :-
    nl,
    writeln('  Intensidade da dor de cabeça (escala 0-10):'),
    writeln('  [1] Baixa  (1-3) — incómodo mas tolerável'),
    writeln('  [2] Moderada (4-6) — interfere com actividades'),
    writeln('  [3] Elevada  (7-9) — muito intensa'),
    writeln('  [4] Máxima  (10)  — a pior dor da minha vida'),
    nl,
    write('  Opção: '),
    read_term(OpcaoInt, []),
    ( OpcaoInt =:= 1 -> registar_fator(intensidade_baixa)
    ; OpcaoInt =:= 2 -> registar_fator(intensidade_moderada)
    ; OpcaoInt =:= 3 -> registar_fator(intensidade_elevada)
    ; OpcaoInt =:= 4 -> registar_fator(intensidade_maxima)
    ; writeln('  Opção inválida, intensidade não registada.')
    ),
    nl.

% =============================================================================
% CÁLCULO E APRESENTAÇÃO DO RESULTADO
% =============================================================================

calcular_e_apresentar_resultado :-
    limpar,
    separador,
    writeln('  RESULTADO DA TRIAGEM'),
    separador,
    nl,
    ( inferir_com_explicacao(melhor(Disposicao, FC, Explicacao), TodasRegras) ->
        apresentar_resultado(Disposicao, FC, Explicacao, TodasRegras)
    ;
        writeln('  Não foi possível determinar uma disposição.'),
        writeln('  Recomenda-se contacto com um profissional de saúde.')
    ),
    nl,
    menu_pos_triagem.

apresentar_resultado(Disposicao, FC, Explicacao, TodasRegras) :-
    dado_utente(nome, Nome),
    format('  Utente: ~w~n', [Nome]),
    nl,
    % Resultado principal
    disposicao_label(Disposicao, Label),
    separador,
    format('  >> ~w~n', [Label]),
    separador,
    nl,
    % Fator de certeza
    FCPct is round(FC * 100),
    format('  Confiança do sistema: ~w%~n', [FCPct]),
    nl,
    % Explicação — razões que levaram a esta conclusão (P1MAX)
    writeln('  JUSTIFICAÇÃO (por que foi tomada esta decisão):'),
    separador_fino,
    maplist([Razao]>>(format('    • ~w~n', [Razao])), Explicacao),
    nl,
    % Sintomas e fatores registados
    apresentar_dados_sessao,
    % Todas as regras ativadas (P1MAX — transparência completa)
    apresentar_regras_ativadas(TodasRegras).

apresentar_dados_sessao :-
    writeln('  DADOS REGISTADOS NESTA SESSÃO:'),
    separador_fino,
    findall(S, tem_sintoma(S), Sintomas),
    findall(F, tem_fator(F), Fatores),
    ( Sintomas \= [] ->
        write('  Sintomas: '),
        maplist([S]>>(descricao_sintoma(S, D), write(D), write(' | ')), Sintomas),
        nl
    ; true ),
    ( Fatores \= [] ->
        write('  Fatores:  '),
        maplist([F]>>(descricao_fator(F, D), write(D), write(' | ')), Fatores),
        nl
    ; true ),
    nl.

% Mostra todas as regras ativadas por ordem de FC (P1MAX — explicação)
apresentar_regras_ativadas(TodasRegras) :-
    length(TodasRegras, N),
    N > 1,
    !,
    writeln('  OUTRAS HIPÓTESES CONSIDERADAS (por ordem de confiança):'),
    separador_fino,
    TodasRegras = [_|Resto],  % ignora a primeira (já apresentada acima)
    forall(
        member(candidato(FC_r, Disp_r, _), Resto),
        (
            disposicao_label(Disp_r, Label_r),
            FCPct_r is round(FC_r * 100),
            format('    [~w%] ~w~n', [FCPct_r, Label_r])
        )
    ),
    nl.
apresentar_regras_ativadas(_).  % Sem outras hipóteses: silêncio

% =============================================================================
% MENU PÓS-TRIAGEM
% =============================================================================

menu_pos_triagem :-
    separador,
    writeln('  O QUE PRETENDE FAZER?'),
    nl,
    writeln('  [1] Realizar nova triagem'),
    writeln('  [0] Sair'),
    nl,
    write('  Opção: '),
    read_term(Opcao, []),
    nl,
    processar_menu_pos_triagem(Opcao).

processar_menu_pos_triagem(1) :-
    limpar_sessao,
    limpar,
    apresentar_cabecalho,
    recolher_dados_utente.
processar_menu_pos_triagem(0) :-
    writeln('  Obrigado por utilizar o Sistema de Triagem SNS24. Cuide-se!'),
    nl.
processar_menu_pos_triagem(_) :-
    writeln('  Opção inválida.'),
    menu_pos_triagem.

% =============================================================================
% UTILITÁRIO — Pergunta Sim/Não
% =============================================================================

pergunta_sim_nao(Pergunta, Resposta) :-
    format('  ~w~n', [Pergunta]),
    write('  [1] Sim   [2] Não   Opção: '),
    read_term(Input, []),
    ( Input =:= 1 -> Resposta = sim
    ; Input =:= 2 -> Resposta = nao
    ; writeln('  Opção inválida. Por favor responda 1 ou 2.'),
      pergunta_sim_nao(Pergunta, Resposta)
    ).
