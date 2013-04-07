module Louvian
  
  @@n2c = {}

  @@adj={}

  @@communities = []
  @@nodes = []

  @@total_weight = 0.0

  def self.adj
    @@adj
  end

  def self.n2c
    @@n2c
  end

  def self.communities
    @@communities
  end

  def self.nodes
    @@nodes
  end

  def self.find_m id
    @@communities.find {|i| i.id == id}
  end

  def self.find_all_m ids
    @@communities.find_all {|i| ids.include? i.id}
  end

  def self.find_n id
    @@nodes.find {|i| i.id == id}
  end

  def self.display_communities
    @@communities.each do |m|
      puts "#{m.id} => #{m.nodes_ids} in=#{m.in} tot=#{m.tot}"
    end
  end
  def self.init_env string
    make_adj string
    @@nodes = @@adj.keys.sort
    @@nodes.each do |k,v|
      @@communities << Community.new(k)
      @@n2c[k] = @@communities.last.id
    end
   @@total_weight = adj.inject(0) {|r,(k,v)| r+v.count}

  end

  def self.make_adj string
    @@adj = {}
    lines = string.split("\n")
    lines.each do |l|
      adj[l.split[0].to_i] ||= []
      adj[l.split[0].to_i] << l.split[1].to_i
      adj[l.split[1].to_i] ||= []
      adj[l.split[1].to_i] << l.split[0].to_i
    end
    nil
  end

  def self.get_adj node_id
    return adj[node_id]
  end

  def self.modularity
    q = 0.0
    # m is the sum of weights in the set of nodes
    #m2 = communities.sum{|m_node| m_node.symmetric_links.count}
    m2 = @@total_weight

    @@communities.each do |m_node|
      q += m_node.in.to_f/m2 - (m_node.tot.to_f/m2 * m_node.tot.to_f/m2)
    end
    return q
  end

  def self.modularity_gain node, community, nb_links_to_comm
    tot = community.tot
    deg = get_adj(node).count
    m2 = @@total_weight

    #puts "\t\t\tcomm #{community.id} #{[tot, deg, m2, nb_links_to_comm]}"
    # what makes sense
    return (nb_links_to_comm.to_f/m2) - (tot * deg.to_f/m2**2/2)

    # copied from the cpp code
    #return nb_links_to_comm.to_f - tot*deg.to_f/m2
  end

  def self.iterate
    cur_mod = self.modularity
    new_mod =  cur_mod
    improvement = 0.0
    min_improvement = 0.01
    nb_passes = 0
    max_passes = 10
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
        if  orig_community.nodes_ids.empty?
          @@communities.delete orig_community
        end


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
        end

        best_community = @@communities.find{|m| m.id == best_community_id}
        #puts "\t\tbest comm #{best_community.id}"

        best_community.insert node, node_to_comms_links[best_community.id]
        @@n2c[node] = best_community_id
      end
      display_comms
      puts "modularity is #{self.modularity}"
    end while  nb_moves > 0
  end

  def self.get_node_to_comms_links node
    neighbour_nodes = self.get_adj node
    node_to_comms_links = {}
    neighbour_nodes.each do |node|
      node_to_comms_links[@@n2c[node]] = (node_to_comms_links[@@n2c[node]] || 0) + 1
    end
    node_to_comms_links[@@n2c[node]] ||= 0
    return node_to_comms_links
  end

  class Community
    attr_accessor :in, :tot, :nodes_ids, :id
    @@count = 0
    def initialize node_id
      @id = @@count
      @@count+=1
      #@nodes_ids = [trust_node.id]
      @nodes_ids = [node_id]
      @in = 0 # sum of links weights inside the community

      # what makes sense
      @tot = Louvian.get_adj(node_id).count # sum of links weights incident to the community
    end

    def insert node, links_to_comm
      #puts "\t\tinsert node #{node} to comm #{@id}"
      @nodes_ids << node

      # what makes sense
      #@in += links_to_comm
      #@tot += (Louvian.get_adj(node).count - links_to_comm)

      # Copied from the cpp code
      @in += 2*links_to_comm
      @tot += (Louvian.get_adj(node).count)
    end

    def remove node, links_to_comm
      #puts "\t\tremove node #{node} to comm #{@id}"
      @nodes_ids.delete node

      # what makes sense
      #@in -= links_to_comm
      #@tot -= (Louvian.get_adj(node).count - links_to_comm)

      # Copied from the cpp code
      @in -= 2*links_to_comm
      @tot -= (Louvian.get_adj(node).count)
    end

  end
end
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
