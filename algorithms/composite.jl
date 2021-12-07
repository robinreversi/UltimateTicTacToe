include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")
include("../algorithms/expectiminimax.jl")
include("../algorithms/mcts.jl")

struct Composite
    mcts::MonteCarloTreeSearch  # start strong with MCTS
    expectiminimax::ExpectiMiniMax # finish strong with expectiminimax
    τ::Int8 # Turn when switch from MCTS to expectiminimax
    num_turns::Int8 # Turn counter
end 

function choose_action(game::UTicTacToe, algo::Composite)
    move = nothing
    if algo.num_turns < algo.τ
        move = choose_action(game, algo.mcts)
    else
        move = choose_action(game, algo.expectiminimax)
    end
    num_turns += 1
    return move
end 