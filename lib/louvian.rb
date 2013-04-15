class Louvian
  require 'louvian/community'
  require 'louvian/graph'

  MIN_INCREASE = 0.000001


  # This method sets up the whole environemnt for calculations
  #
  # @param string [String] in the form of src dest (one edge per line)
  #
  def initialize string, directed
    list = string.split("\n").map {|line| line.split.map{|n| n.to_i}}
    @graph = Graph.new list, directed, 0
    @levels = [] # List of Graphs
  end

  def graph
    @graph
  end

  def graph= value
    @graph = value
  end

  def levels
    @levels
  end

  def levels= value
    @levels = value
  end

  def run
    l = 0
    puts "Level #{l}: Comms #{@graph.communities.size}"
    l +=1

    while self.one_level
      puts "Level #{l}: Comms #{@graph.communities.size}"
      @levels << @graph
      @graph = @graph.build_graph_from_comms

      l+=1
    end
    self
  end

  def unfold_levels!
    @levels[(1..-1)].each_with_index do |graph, i|
      graph.expand! @levels[i]
    end
    true
  end

  def display_hierarchy
    @levels.each do |graph|
      puts "level #{graph.level}: Nodes #{graph.communities.count}"
    end
    nil
  end

  # This method iterates over the graph to optimze the modularity. Iterations
  # stops when there are no possible moves anymore.
  # @returns improvement [Boolean] indicates whether there was improvment or no
  def one_level
    improvement = false
    nb_passes = 0
    cur_mod = @graph.modularity
    new_mod = cur_mod
    begin
      #puts "Iterating"
      #puts "modularity is #{@graph.modularity}"
      cur_mod = new_mod
      nb_moves = 0
      nb_passes += 1
      @graph.nodes.shuffle.each do |node|
        #puts "\t#{@graph.n2c}"
        #puts "\tconsidering node #{node}"
        orig_community = @graph.get_community node

        neighbour_communities = @graph.get_neighbour_comms node

        #puts "\tneihbours#{neighbour_communities.map {|i| i.id}} origin #{orig_community.id}"
        @graph.remove_node node, orig_community


        best_community = orig_community
        max_gain = 0.0

        neighbour_communities.each do |comm|
          mod_gain = @graph.modularity_gain node, comm
          #puts "\t\tfor comm #{comm.id} mod increase is #{mod_gain}"
          if mod_gain > max_gain
            max_gain = mod_gain
            best_community = comm
          end
        end
        if best_community != orig_community
          nb_moves += 1
          improvement = true
          #puts "\t\tbest comm #{best_community.id}"
        end

        @graph.insert_node node, best_community

        @graph.garbage_collect orig_community

      end
      new_mod = @graph.modularity
      #puts "modularity was #{cur_mod} and now #{new_mod}, moves #{nb_moves}"
    end while  nb_moves > 0 and new_mod - cur_mod >= MIN_INCREASE
    return improvement
  end


  def self.example
    s='0 1 1
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

    l = Louvian.new s, false
    #l.one_level
    #ng = l.graph.build_graph_from_comms
    #l.levels << l.graph
    #l.graph = ng
    l.run
    return l
  end
end
