louvian_ruby
============

Implementation of Louvian community detection algorithm in Ruby

Good for experimenting with louvian algorithm. Results are identical to the original cpp code written by authors.

<b>Original Paper</b>: Vincent D. Blondel, Jean-Loup Guillaume, Renaud Lambiotte, Etienne Lefebvre - Fast unfolding of communities in large networks (2008). [PDF](http://lanl.arxiv.org/abs/0803.0476)

[Original Implementation](http://sites.google.com/site/findcommunities/)


Install
=======

    $ gem install 'louvian_ruby'

Usage
=====

    require 'louvian'
    Louvian.example
or 

    # source target weight
    edges ='0 1 1
    0 8 1
    1 3 1
    1 4 1
    1 8 1
    2 3 1
    2 5 1
    2 7 1
    3 8 1
    4 7 1
    5 6 1
    5 7 1'
    edges_list = self.make_list_from_string(edges)

    l = Louvian.new(edges_list, false)
    l.run
    # After run, the l.levels array will have a graph for each level
    # You can use graph.display_communities for a user friendly output
    l.display_hierarchy
    


