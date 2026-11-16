# FerriteAdaptiveTriangular.jl

Conforming adaptive refinement of linear triangle meshes for
[Ferrite.jl](https://github.com/Ferrite-FEM/Ferrite.jl), by newest vertex bisection. The refined
meshes have no hanging nodes: they are plain `Ferrite.Grid`s, need no `ConformityConstraint`,
and continuous spaces of any order can be used on them.

The package works with released Ferrite (1.7 and later). It adds one type, `BisectionMesh`, and
methods for Ferrite's own `refine!`, `coarsen!`, `refine_and_coarsen!` and `creategrid`.

## Installation

The package is not in the General registry.

```julia
using Pkg
Pkg.add(url = "https://github.com/DanielBoigk/FerriteAdaptiveTriangular.jl")
```

## Use

```julia
using Ferrite, FerriteAdaptiveTriangular

grid = generate_grid(Triangle, (4, 4))        # 32 cells
mesh = BisectionMesh(grid)                    # optional second argument: maximum level, 30

refine!(mesh, [5, 6])                         # bisect cells 5 and 6, then restore conformity
fine = creategrid(mesh)                       # a conforming Grid; cell and facet sets carried over

coarsen!(mesh, collect(1:getncells(mesh)))    # undo the latest bisection wherever possible
refine_and_coarsen!(mesh, Int[], [1])         # both, with ids from one numbering
```

`mesh.levels` holds the refinement level of every current cell: the number of bisections from
its cell in the initial grid. Two bisections quarter a cell, so a level counts bisections, not
quarterings as for Ferrite's `ForestBWG`.

Only the `cellsets` and `facetsets` of the initial grid are carried over to the refined grids;
`nodesets` and `vertexsets` are not.

## Method

A triangle is split into two by connecting the midpoint of one of its edges, the *refinement
edge*, with the opposite vertex. If the neighbour across that edge is not bisected along the same
edge, the midpoint would be a hanging node, so the neighbour is bisected as well, possibly after
a bisection along its own refinement edge. This closure continues until the mesh is conforming.

Newest vertex bisection (Mitchell 1991) chooses the refinement edges so that the cells do not
degenerate. Every triangle stores its vertices as `(i, j, k)` with refinement edge `(i, j)`;
bisection inserts the midpoint `m` and creates the children `(k, i, m)` and `(j, k, m)`, whose
refinement edges lie opposite the new vertex:

```
            k                                 k
           / \                               /|\
          /   \                             / | \
         /     \          bisection        /  |  \
        /       \        --------->       /   |   \
       /         \                       /    |    \
      i-----------j                     i-----m-----j
```

All cells created from one initial triangle fall into at most four similarity classes, so the
angles of the refined mesh are bounded below by a fixed fraction of the angles of the initial
mesh. The initial refinement edge of every triangle is its longest edge.

Coarsening undoes bisections without a stored refinement tree (Chen and Zhang 2010). A vertex
created by bisection is removed if it is the newest vertex of every cell around it, two cells on
the boundary or four in the interior; merging these cells pairwise restores the parents.
Coarsening is thus the exact inverse of refinement and keeps the mesh conforming. One call
undoes at most one bisection around each vertex.

## References

- W. F. Mitchell, Adaptive refinement for arbitrary finite-element spaces with hierarchical
  bases, J. Comput. Appl. Math. 36 (1991) 65–78, doi:10.1016/0377-0427(91)90226-A
- P. Binev, W. Dahmen, R. DeVore, Adaptive finite element methods with convergence rates,
  Numer. Math. 97 (2004) 219–268, doi:10.1007/s00211-003-0492-7
- R. Stevenson, The completion of locally refined simplicial partitions created by bisection,
  Math. Comp. 77 (2008) 227–241, doi:10.1090/S0025-5718-07-01959-X
- L. Chen, C. Zhang, A coarsening algorithm on adaptive grids by newest vertex bisection and its
  applications, J. Comput. Math. 28 (2010) 767–789, doi:10.4208/jcm.1004-m3172

## Origin

The code was written as a branch of a Ferrite.jl fork
([DanielBoigk/Ferrite.jl](https://github.com/DanielBoigk/Ferrite.jl), `adaptive-triangular`) and
moved into a package of its own so that it can be used with released Ferrite. It extends the
functions of `Ferrite.AMR`.
