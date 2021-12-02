include("algorithms/sparse_sampling.jl")
include("algorithms/expectiminimax.jl")
include("games/utictactoe.jl")

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
        algo = SparseSampling(tryparse(Int64, ARGS[2]), tryparse(Int64, ARGS[3]), tryparse(Float64, ARGS[4]))
    end

    if (algorithm == "expectiminimax")
        if length(ARGS) != 3
            error("usage: julia project1.jl expectiminimax <d> <g>")
        end
        algo = ExpectiMiniMax(tryparse(Int64, ARGS[2]), tryparse(Float64, ARGS[3]))
    end

    # Initialize 9 individual TicTacToe boards
    ttt_boards = [TicTacToe(zeros(Int64, 3, 3)) for i = 1:3, j = 1:3]

    # Initialize Ultimate TicTacToe game
    game = UTicTacToe(ttt_boards, 1, -1, -1, (-1,-1,-1,-1))
    return algo, game
end

function print_game_info(game::UTicTacToe, a::Union{Tuple{Int64, Int64, Int64, Int64}, Nothing})
    run(`clear`)
    println("Current board:\n")
    display_board(game)
    println()

    if a !== nothing
        print("The computer's last move was: ")
        println(a)
    end

    if game.ttt_boards_x != -1
        println("You must play in TicTacToe board $(game.ttt_boards_x), $(game.ttt_boards_y)")
    end
    println()
end

function get_player_move(game::UTicTacToe)
    print("Your move is: ")
    while true 
        board_xidx, board_yidx, xloc, yloc = -1, -1, -1, -1
        while true
            move_vec = split(readline(), ",")
            if size(move_vec) == (4,)
                board_xidx, board_yidx, xloc, yloc = tryparse(Int64, move_vec[1]), tryparse(Int64, move_vec[2]), tryparse(Int64, move_vec[3]), tryparse(Int64, move_vec[4])
                if board_xidx !== nothing  && board_yidx !== nothing && xloc !== nothing && yloc !== nothing
                    break
                end
            end
            println()
            print("Please enter your move in the form of \"int,int,int,int\" \"1,1,1,1\": ")
        end

        move = (board_xidx, board_yidx, xloc, yloc)
        valid_mvs = u_valid_moves(game)
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
    # while(u_has_won(game) == 0 && !isempty(u_valid_moves(game)))
    #     a = choose_action(game, algo)
    #     take_turn(game, a)
    #     display_board(game)
    #     println()
    # end
    computers_turn = false
    a = nothing
    while(u_has_won(game) == 0 && !isempty(u_valid_moves(game)))
        if computers_turn == false
            print_game_info(game, a)
            move = get_player_move(game)
            take_turn(game, move)
            computers_turn = true
        else
            a = choose_action(game, algo)
            take_turn(game, a)
            computers_turn = false
        end
    end
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