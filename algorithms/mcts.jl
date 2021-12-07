include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

using BSON
using ProgressBars
using SHA

mutable struct MonteCarloTreeSearch
    N # visit counts
    Q # action value estimates 
    d::Int64 # depth
    m::Int64 # number of simulations 
    c::Float64 # exploration constant
    γ::Float64 # discount
end 

function get_s(uttt::UTicTacToe)
    uttt_board = create_9x9_board(uttt)
    uttt_board *= uttt.current_player
    return (uttt_board, uttt.ttt_boards_x, uttt.ttt_boards_y)
    # str_board = join(collect(Iterators.flatten(uttt_board)))
    # return str_board * string(uttt.ttt_boards_x) * string(uttt.ttt_boards_y)
end

function choose_action(game::UTicTacToe, algo::MonteCarloTreeSearch)
    bot_game, transform_idx = setup_bot_game(game)
    
    for k in 1:algo.m
        simulate!(bot_game, algo, game.current_player)
    end
    valid_mvs = u_valid_moves_unique(bot_game)
    a = argmax(a->algo.N[compress_s_a(get_s(bot_game), a)], valid_mvs)
    return to_player_move(a, transform_idx)
end 

function simulate!(game::UTicTacToe, algo::MonteCarloTreeSearch, player, d=algo.d)
    if (algo.d <= 0 || u_has_won(game) != 0 || isempty(u_valid_moves_all(game)))
        return U(game, player)
    end

    s = get_s(game)
    valid_mvs = u_valid_moves_unique(game)
    
    if (!haskey(algo.N, compress_s_a(s, first(valid_mvs))))
        for a in valid_mvs
            algo.N[compress_s_a(s, a)] = 0
            algo.Q[compress_s_a(s, a)] = 0.0
        end
        return U(game, player)
    end
    
    a = explore(algo, s, valid_mvs)
    game′ = randstep(game, a)
    q = U(game′, player) + algo.γ * simulate!(game′, algo, player, algo.d - 1)
    algo.N[compress_s_a(s, a)] += 1
    algo.Q[compress_s_a(s, a)] += (q - algo.Q[compress_s_a(s, a)])/algo.N[compress_s_a(s, a)]
    return q
end

function compress_s_a(s, a)
    return (s, a)
    # compressed_s = s * string(a[1]) * string(a[2]) * string(a[3]) * string(a[4])
    # return bytes2hex(sha256(compressed_s))
end

bonus(Nsa, Ns) = Nsa == 0 ? Inf : sqrt(log(Ns)/Nsa)

function explore(algo::MonteCarloTreeSearch, s, valid_mvs) 
    Ns = sum(algo.N[compress_s_a(s,a)] for a in valid_mvs)
    return argmax(a->algo.Q[compress_s_a(s,a)] + algo.c*bonus(algo.N[compress_s_a(s,a)], Ns), valid_mvs)
end 

function train(d::Int8, m::Int8, c::Float64, γ::Float64, num_games::Int64, save_every::Int64)
    N = Dict{Any, Int64}()
    Q = Dict{Any, Float64}()
    mcts = MonteCarloTreeSearch(N, Q, d, m, c, γ)
    for i in ProgressBar(1:num_games)
        ttt_boards = [TicTacToe(zeros(Int64, 3, 3)) for i = 1:3, j = 1:3]
        game = UTicTacToe(ttt_boards, 1, -1, -1, (-1, -1, -1, -1))
        while(u_has_won(game) == 0 && !isempty(u_valid_moves_all(game)))
            a = choose_action(game, mcts)
            take_turn(game, a)
        end
        
        if (i % save_every == 0)
            bson("mcts_states/rr_mcts_N_game_" * string(i) * "_d" * string(d) * "_m" * string(m), mcts.N)
            bson("mcts_states/rr_mcts_Q_game_" * string(i) * "_d" * string(d) * "_m" * string(m), mcts.Q)
        end
    end
    return mcts
end
