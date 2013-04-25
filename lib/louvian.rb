class Louvian
  require 'louvian/community'
  require 'louvian/graph'

  MIN_INCREASE = 0.000001


  # This method sets up the whole environemnt for calculations
  #
  # @param string [String] in the form of src dest (one edge per line)
  #
  def initialize tuples, directed, save_intermediate=true
    @graph = Graph.new tuples, directed, 0
    @levels = [] # List of Graphs
    @save_intermediate_graphs = save_intermediate
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

  def run verbose=false
    l = 0
    puts "Level #{l}: Comms #{@graph.communities.size}" if verbose
    l +=1

    while self.one_level
      puts "Level #{l}: Comms #{@graph.communities.size}" if verbose
      @levels << @graph if @save_intermediate_graphs
      @graph = @graph.build_graph_from_comms

      l+=1
    end
    self
  end

  def unfold_levels!
    return false if @levels.size < 2
    @levels[(1..-1)].each_with_index do |graph, i|
      graph.expand! @levels[i]
    end
    true
  end

  def display_hierarchy
    if not @save_intermediate
      puts "level #{@graph.level}: Nodes #{graph.communities.count}"
      puts "Note, save_intermediate is set to be false, set it to true"+
        "if you want to make use of hierarchy"
    else
      @levels.each do |graph|
        puts "level #{graph.level}: Nodes #{graph.communities.count}"
      end
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
      cur_mod = new_mod
      nb_moves = 0
      nb_passes += 1
      @graph.nodes.shuffle.each do |node|
        orig_community = @graph.get_community node

        neighbour_communities = @graph.get_neighbour_comms node

        @graph.remove_node node, orig_community


        best_community = orig_community
        max_gain = 0.0

        neighbour_communities.each do |comm|
          mod_gain = @graph.modularity_gain node, comm
          if mod_gain > max_gain
            max_gain = mod_gain
            best_community = comm
          end
        end
        if best_community != orig_community
          nb_moves += 1
          improvement = true
        end

        @graph.insert_node node, best_community

        @graph.garbage_collect orig_community

      end
      new_mod = @graph.modularity
    end while  nb_moves > 0 and new_mod - cur_mod >= MIN_INCREASE
    return improvement
  end

  def self.example s=nil
    s ||='0 1 1
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
    list = self.make_list_from_string s

    l = Louvian.new(list, false)
    l.run
    return l
  end

  def self.make_list_from_string s
    list = (s.split("\n").map {|line| line.split.map{|n| n.to_i}})
  end

end
