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

    edges='0 1
    0 8
    1 3
    1 4
    1 8
    2 3
    2 5
    2 7
    3 8
    5 6
    5 7'

    Louvian.init_env edges
    Louvian.iterate
    communities_hash = Louvian.communities
    Louvian.display_communities
    Louvian.reset


