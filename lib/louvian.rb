module Louvian
  require 'louvian/community'
  require 'louvian/graph'

  MIN_INCREASE = 0.000001

  # This method outputs information about communities
  def self.display_communities
    @@communities.each do |m|
      puts "#{m.id} => #{m.nodes_ids} in=#{m.in} tot=#{m.tot}"
    end
  end

  # This method sets up the whole environemnt for calculations
  #
  # @param string [String] in the form of src dest (one edge per line)
  def self.init_env string, directed=false
    list = string.split("\n").map {|line| line.split.map{|n| n.to_i}}
    @@graph = Graph.new list
    nil
  end

  def self.run
    l = 0
    mod = self.modularity
    begin 
      self.update_nodes
      puts "Level #{l}: Comms #{@@communities.size}"
    end while self.one_level
  end


  # This method iterates over the graph to optimze the modularity. Iterations
  # stops when there are no possible moves anymore.
  # @returns improvement [Boolean] indicates whether there was improvment or no
  def self.one_level
    cur_mod = self.modularity
    new_mod =  cur_mod
    improvement = false
    nb_passes = 0
    begin
      #puts "Iterating"
      #puts "modularity is #{self.modularity}"
      cur_mod = new_mod
      nb_moves = 0
      nb_passes += 1
      @@nodes.shuffle.each do |node|
        #puts "\tconsidering node #{node}"
        orig_community_id = @@n2c[node]
        orig_community = @@communities.find {|i| i.id == orig_community_id}
        node_to_comms_links = self.get_node_to_comms_links node
        neighbour_communities = @@communities.find_all {|i| node_to_comms_links.include? i.id}

        orig_community.remove node, node_to_comms_links[orig_community_id]


        best_community_id = orig_community_id
        max_gain = 0.0

        neighbour_communities.each do |m_node|
          mod_gain = self.modularity_gain(node, m_node, node_to_comms_links[m_node.id])
          #puts "\t\tfor comm #{m_node.id} mod increase is #{mod_gain}"
          if mod_gain > max_gain
            max_gain = mod_gain
            best_community_id = m_node.id
          end
        end
        if best_community_id != orig_community_id
          nb_moves += 1
          improvement = true
        end

        best_community = @@communities.find{|m| m.id == best_community_id}
        #puts "\t\tbest comm #{best_community.id}"

        best_community.insert node, node_to_comms_links[best_community.id]
        @@n2c[node] = best_community_id

        if  orig_community.nodes_ids.empty?
          @@communities.delete orig_community
        end
      end
      #display_communities
      new_mod = self.modularity
      puts "modularity was #{cur_mod} and now #{new_mod}"
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

    Louvian.init_env s
    Louvian.iterate
    Louvian.display_communities
    Louvian.reset
    nil
  end
end
