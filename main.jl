include("algorithms/sparse_sampling.jl")
include("algorithms/expectiminimax.jl")
include("algorithms/mcts.jl")
include("games/utictactoe.jl")
using BSON

function choose_action(game::UTicTacToe, algo)
    error("invalid algorithm specified")
end

function setup(algorithm, ARGS) 
    algo = nothing
    # add other algorithms here 
    # they must specify a choose_action function
    # that's clearly typed
    if (algorithm == "sparse_sampling")
        if length(ARGS) != 4
            error("usage: julia project1.jl sparse_sampling <m> <d> <g>")
        end
        algo = SparseSampling(tryparse(Int8, ARGS[2]), tryparse(Int8, ARGS[3]), tryparse(Float64, ARGS[4]))
    end

    if (algorithm == "expectiminimax")
        if length(ARGS) != 3
            error("usage: julia project1.jl expectiminimax <d> <g>")
        end
        algo = ExpectiMiniMax(tryparse(Int8, ARGS[2]), tryparse(Float64, ARGS[3]))
    end

    if (algorithm == "mcts")
        if length(ARGS) < 5
            error("usage: julia project1.jl mcts <d> <m> <c> <γ> <load_no>")
        end
        N = Dict{String, Int16}()
        Q = Dict{String, Float64}()
        d = tryparse(Int8, ARGS[2])
        m = tryparse(Int8, ARGS[3])
        c = tryparse(Float64, ARGS[4])
        γ = tryparse(Float64, ARGS[5])
        if length(ARGS) == 6
            N = BSON.load("mcts_states/rr_mcts_N_game_" * ARGS[6] * "_d" * string(d) * "_m" * string(m))
            Q = BSON.load("mcts_states/rr_mcts_Q_game_" * ARGS[6] * "_d" * string(d) * "_m" * string(m))
            c = 0
        end
        algo = MonteCarloTreeSearch(N, Q, d, m, c, γ)
        if (isempty(algo.N)) 
            algo = train(d, m, c, γ, 100, 1000000000)
            algo.c = 0
        end
    end

    # Initialize 9 individual TicTacToe boards
    ttt_boards = [TicTacToe(zeros(Int8, 3, 3)) for i = 1:3, j = 1:3]

    # Initialize Ultimate TicTacToe game
    game = UTicTacToe(ttt_boards, 1, -1, -1, (-1,-1,-1,-1))
    return algo, game
end

function move_prompt_text(game::UTicTacToe, move::Union{Tuple{Int8, Int8, Int8, Int8}, Nothing})
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println()

    if move !== nothing
        print("The bot's last move was: ")
        println(move)
    end

    if game.ttt_boards_x != -1
        println("You must play in TicTacToe board $(game.ttt_boards_x), $(game.ttt_boards_y)")
    end
    println()
end

function waiting_text(game::UTicTacToe, move::Union{Tuple{Int8, Int8, Int8, Int8}, Nothing})
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println()

    if move !== nothing
        print("Your move was: ")
        println(move)
    end

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

function main(algorithm, ARGS)
    algo, game = setup(algorithm, ARGS)
    bots_turn = false
    move = nothing
    while(u_has_won(game) == 0 && !isempty(u_valid_moves_all(game)))
        if bots_turn == false
            move_prompt_text(game, move)
            move = get_player_move(game)
            take_turn(game, move)
            waiting_text(game, move)
            bots_turn = true
        else
            move = choose_action(game, algo)
            take_turn(game, move)
            bots_turn = false
        end
    end
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println("Game over!") 
    #println("Player $(u_has_won(uttt_game)) has won the game.") 
end

if length(ARGS) < 1
    error("usage: julia project1.jl <algorithm>")
end

algorithm = ARGS[1]
main(algorithm, ARGS)