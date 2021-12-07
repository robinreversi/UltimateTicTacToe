include("games/tictactoe.jl")
include("games/utictactoe.jl")
include("heuristics/heuristics.jl")
include("algorithms/sparse_sampling.jl")
include("algorithms/expectiminimax.jl")
include("algorithms/mcts.jl")
include("algorithms/composite.jl")

using BSON

function choose_mode()
    println("What mode of Ultimate Tic Tac Toe would you like to play?")
    print("Type 1 for human vs human, 2 for human vs bot, and 3 for bot vs bot: ")
    input = readline()
    println()
    if input == "1"
        return 1, nothing, nothing
    elseif input == "2"
        println("What algorithm should your opponent bot use?")
        algo = choose_algo()
        return 2, algo, nothing
    elseif input == "3"
        println("What algorithm should bot 1 use?")
        algo1 = choose_algo()
        println("What algorithm should bot 2 use?")
        algo2 = choose_algo()
        return 3, algo1, algo2
    else
        print("Sorry, unable to understand your input.")
        return choose_mode()
    end
end

function choose_algo()
    print("Type 1 for sparse sampling, 2 for expectiminimax, 3 for Monte Carlo Tree Search, and 4 for the composite model: ")
    input = readline()
    println()
    if input == "1"
        return setup_algo(["sparse_sampling", "3", "3", ".9"])
    elseif input == "2"
        return setup_algo(["expectiminimax", "3", ".9"])
    elseif input == "3"
        #return setup_algo(["mcts", "3", "10", "5", ".9", "1000"])
        return setup_algo(["mcts", "15", "5", "15", ".9"])
    elseif input == "4"
        return setup_algo(["composite", "3", "7", "5", "4", "15", ".9"])
        #return setup_algo(["composite", "3", "10", "5", "4", "15", ".9", "1000"])
    else
        println("Sorry, unable to understand your input.")
        return choose_algo()
    end
end

function choose_action(game::UTicTacToe, algo)
    error("invalid algorithm specified")
end

function setup_algo(params)
    algo = nothing
    if (params[1] == "sparse_sampling")
        if length(params) != 4
            error("usage: julia project1.jl sparse_sampling <m> <d> <g>")
        end
        algo = SparseSampling(tryparse(Int8, params[2]), tryparse(Int8, params[3]), tryparse(Float64, params[4]))
    end

    if (params[1] == "expectiminimax")
        if length(params) != 3
            error("usage: julia project1.jl expectiminimax <d> <g>")
        end
        algo = ExpectiMiniMax(tryparse(Int8, params[2]), tryparse(Float64, params[3]))
    end

    if (params[1] == "mcts")
        if length(params) < 5
            error("usage: julia project1.jl mcts <d> <m> <c> <γ> <num_games>")
        end
        N = Dict{String, Int16}()
        Q = Dict{String, Float64}()
        d = tryparse(Int8, params[2])
        m = tryparse(Int8, params[3])
        c = tryparse(Float64, params[4])
        γ = tryparse(Float64, params[5])
        if length(params) == 6
            N = BSON.load("mcts_states/rr_mcts_N_game_" * params[6] * "_d" * string(d) * "_m" * string(m))
            Q = BSON.load("mcts_states/rr_mcts_Q_game_" * params[6] * "_d" * string(d) * "_m" * string(m))
            c = 0
        end
        algo = MonteCarloTreeSearch(N, Q, d, m, c, γ)
        if (isempty(algo.N)) 
            println("Please wait while the MCTS model is trained.")
            algo = train(d, m, c, γ, 1000, 2500)
        end
        algo.m = 100
    end

    if (params[1] == "composite")
        if length(params) < 7 
            error("usage: julia project1.jl composite <d_mcts> <m> <c> <d_expectiminimax> <τ> <γ> <load_no>")
        end
        N = Dict{String, Int16}()
        Q = Dict{String, Float64}()
        d_mcts = tryparse(Int8, params[2])
        m = tryparse(Int8, params[3])
        c = tryparse(Float64, params[4])
        d_expectiminimax = tryparse(Int8, params[5])
        τ = tryparse(Float64, params[6])
        γ = tryparse(Float64, params[7])
        if length(params) == 8
            N = BSON.load("mcts_states/rr_mcts_N_game_" * params[8] * "_d" * string(d_mcts) * "_m" * string(m))
            Q = BSON.load("mcts_states/rr_mcts_Q_game_" * params[8] * "_d" * string(d_mcts) * "_m" * string(m))
        end
        algo1 = MonteCarloTreeSearch(N, Q, d_mcts, m, c, γ)
        if (isempty(algo1.N)) 
            println("Please wait while the MCTS model is trained.")
            algo1 = train(d_mcts, m, c, γ, 1000, 1000000000)
        end
        algo1.m = 100
        algo2 = ExpectiMiniMax(d_expectiminimax, γ)
        algo = Composite(algo1, algo2, τ, 0)
    end

    return algo
end

function setup_game() 
    # Initialize 9 individual TicTacToe boards
    ttt_boards = [TicTacToe(zeros(Int8, 3, 3)) for i = 1:3, j = 1:3]

    # Initialize Ultimate TicTacToe game
    game = UTicTacToe(ttt_boards, 1, -1, -1, (-1,-1,-1,-1))
    return game
end

function clear_and_display_board(game::UTicTacToe)
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println()
end

function move_prompt_text(game::UTicTacToe)
    clear_and_display_board(game)
    if game.ttt_boards_x != -1
        println("You must play in TicTacToe board $(game.ttt_boards_x), $(game.ttt_boards_y)")
    end
    println()
end

function waiting_text(game::UTicTacToe)
    clear_and_display_board(game)

    if game.ttt_boards_x != -1
        println("The bot must play in TicTacToe board $(game.ttt_boards_x), $(game.ttt_boards_y)")
    end

    println("\nPlease wait while the bot is determining it's next move.")
end

function get_player_move(game::UTicTacToe)
    print("Your move is: ")
    while true 
        board_xidx, board_yidx, xloc, yloc = -1, -1, -1, -1
        while true
            move_vec = split(readline(), ",")
            if size(move_vec) == (4,)
                board_xidx, board_yidx, xloc, yloc = tryparse(Int8, move_vec[1]), tryparse(Int8, move_vec[2]), tryparse(Int8, move_vec[3]), tryparse(Int8, move_vec[4])
                if board_xidx !== nothing  && board_yidx !== nothing && xloc !== nothing && yloc !== nothing
                    break
                end
            end
            println()
            print("Please enter your move in the form of \"int,int,int,int\" \"1,1,1,1\": ")
        end

        move = (board_xidx, board_yidx, xloc, yloc)

        valid_mvs = u_valid_moves_all(game)
        for a in valid_mvs
            if move == a
                return move
            end
        end
        println()
        print("Please enter a valid move: ")
    end
end

function human_turn!(game::UTicTacToe)
    move_prompt_text(game)
    move = get_player_move(game)
    take_turn(game, move) 
end

function bot_turn!(game::UTicTacToe, algo)
    move = choose_action(game, algo)
    take_turn(game, move)
end

function main()
    run(`clear`)
    mode, algo1, algo2 = choose_mode()
    game = setup_game()
    player1s_turn = true
    #move = nothing # can replace this with previous move?
    if mode == 1
        while(u_has_won(game) == 0 && !isempty(u_valid_moves_all(game)))
            if player1s_turn == true
                human_turn!(game)
                player1s_turn = false
            else
                human_turn!(game)
                player1s_turn = false
            end
        end
    elseif mode == 2
        while(u_has_won(game) == 0 && !isempty(u_valid_moves_all(game)))
            if player1s_turn == true
                human_turn!(game)
                waiting_text(game)
                player1s_turn = false
            else
                bot_turn!(game, algo1)
                player1s_turn = true
            end
        end
    else # mode == 3
        while(u_has_won(game) == 0 && !isempty(u_valid_moves_all(game)))
            if player1s_turn == true
                clear_and_display_board(game)
                bot_turn!(game, algo1)
                player1s_turn = false
            else
                clear_and_display_board(game)
                bot_turn!(game, algo2)
                player1s_turn = true
            end
        end
    end
    
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println("Game over!") 
end

main()