include("algorithms/sparse_sampling.jl")
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

    ttt_boards = [TicTacToe(zeros(Int64, 3, 3)) for i = 1:3, j = 1:3]
    game = UTicTacToe(ttt_boards, 1, -1, -1)
    return algo, game
end

function main(algorithm, ARGS)
    algo, game = setup(algorithm, ARGS)
    while(u_has_won(game) == 0)
        a = choose_action(game, algo)
        take_turn(game, a)
        # display_board(game)
        println()
    end
end

if length(ARGS) < 1
    error("usage: julia project1.jl <algorithm>")
end

algorithm = ARGS[1]
main(algorithm, ARGS)