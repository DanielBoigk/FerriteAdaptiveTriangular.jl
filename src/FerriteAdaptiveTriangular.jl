"""
    FerriteAdaptiveTriangular

Conforming adaptive refinement of linear triangle meshes for
[Ferrite.jl](https://github.com/Ferrite-FEM/Ferrite.jl) by newest vertex bisection.

[`BisectionMesh`](@ref) is the mesh type. It is refined and coarsened with Ferrite's own
`refine!`, `coarsen!` and `refine_and_coarsen!`, and `creategrid` returns the current grid, a
plain `Ferrite.Grid` without hanging nodes.
"""
module FerriteAdaptiveTriangular

using Ferrite
using LinearAlgebra: norm
using OrderedCollections: OrderedSet

# The methods below extend the functions of Ferrite's AMR module for `BisectionMesh`.
import Ferrite.AMR: refine!, coarsen!, refine_and_coarsen!, creategrid

export BisectionMesh

include("bisection.jl")

end # module
