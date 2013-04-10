module Louvian
  require 'louvian/community'
  require 'louvian/graph'

  MIN_INCREASE = 0.000001


  def self.graph
    @@graph
  end

  def self.graph= value
    @@graph = value
  end

  def self.levels
    @@levels
  end
  # This method sets up the whole environemnt for calculations
  #
  # @param string [String] in the form of src dest (one edge per line)
  def self.init_env string, directed
    list = string.split("\n").map {|line| line.split.map{|n| n.to_i}}
    @@graph = Graph.new list, directed, 0
    @@levels = [] # List of Graphs
    nil
  end

  def self.run
    l = 0
    mod = @@graph.modularity
    begin
      puts "Level #{l}: Comms #{@@graph.communities.size}"
      @@levels << @@graph
      @@graph = @@graph.build_graph_from_comms
      l+=1
    end while self.one_level
  end

  def self.unfold_levels!
    @@levels[(1..-1)].each_with_index do |graph, i|
      graph.expand! @@levels[i]
    end
  end

  def self.display_hierarchy
    @@levels.each do |graph|
      puts "level #{graph.level}: Nodes #{graph.communities.count}"
    end

  end

  # This method iterates over the graph to optimze the modularity. Iterations
  # stops when there are no possible moves anymore.
  # @returns improvement [Boolean] indicates whether there was improvment or no
  def self.one_level
    improvement = false
    nb_passes = 0
    cur_mod = @@graph.modularity
    new_mod = cur_mod
    begin
      #puts "Iterating"
      #puts "modularity is #{@@graph.modularity}"
      cur_mod = new_mod
      nb_moves = 0
      nb_passes += 1
      @@graph.nodes.shuffle.each do |node|
        #puts "\t#{@@graph.n2c}"
        #puts "\tconsidering node #{node}"
        orig_community = @@graph.get_community node

        neighbour_communities = @@graph.get_neighbour_comms node

        #puts "\tneihbours#{neighbour_communities.map {|i| i.id}}"
        @@graph.remove_node node, orig_community


        best_community = orig_community
        max_gain = 0.0

        neighbour_communities.each do |comm|
          mod_gain = @@graph.modularity_gain node, comm
          #puts "\t\tfor comm #{comm.id} mod increase is #{mod_gain}"
          if mod_gain > max_gain
            max_gain = mod_gain
            best_community = comm
          end
        end
        if best_community != orig_community
          nb_moves += 1
          improvement = true
        end

        @@graph.insert_node node, best_community

        @@graph.garbage_collect orig_community

      end
      #display_communities
      new_mod = @@graph.modularity
      #puts "modularity was #{cur_mod} and now #{new_mod}, moves #{nb_moves}"
    end while  nb_moves > 0 and new_mod - cur_mod >= MIN_INCREASE
    return improvement
  end


  def self.example
    s='0 1
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

    Louvian.init_env s, false
    Louvian.run
    nil
  end
end
