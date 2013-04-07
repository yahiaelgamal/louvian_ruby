module Louvian
  
  @@n2c = {}

  @@adj={}

  @@meta_nodes = []
  @@nodes = []

  @@total_weight = 0.0

  def self.adj
    @@adj
  end

  def self.n2c
    @@n2c
  end

  def self.meta_nodes
    @@meta_nodes
  end

  def self.nodes
    @@nodes
  end

  def self.find_m id
    @@meta_nodes.find {|i| i.id == id}
  end

  def self.find_all_m ids
    @@meta_nodes.find_all {|i| ids.include? i.id}
  end

  def self.find_n id
    @@nodes.find {|i| i.id == id}
  end

  def self.display_metas
    @@meta_nodes.each do |m|
      puts "#{m.id} => #{m.nodes_ids}"
    end
  end
  def self.init_env string
    make_adj string
    @@nodes = @@adj.keys.sort
    @@nodes.each do |k,v|
      @@meta_nodes << MetaNode.new(k)
      @@n2c[k] = @@meta_nodes.last.id
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
    #m2 = meta_nodes.sum{|m_node| m_node.symmetric_links.count}
    m2 = @@total_weight

    @@meta_nodes.each do |m_node|
      q += m_node.in.to_f/m2 - (m_node.tot.to_f/m2 * m_node.tot.to_f/m2)
    end
    return q
  end

  def self.modularity_gain node, meta_node, nb_links_to_comm
    tot = meta_node.tot
    deg = get_adj(node).count
    m2 = @@total_weight

    #puts "\t\t\tcomm #{meta_node.id} #{[tot, deg, m2, nb_links_to_comm]}"
    return (nb_links_to_comm.to_f/m2) - (tot * deg.to_f/m2**2/2)
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
      puts "Iterating"
      puts "modularity is #{self.modularity}"
      cur_mod = new_mod
      nb_moves = 0
      nb_passes += 1
      @@nodes.shuffle.each do |node|
        puts "\tconsidering node #{node}"
        orig_meta_node_id = @@n2c[node]
        orig_meta_node = @@meta_nodes.find {|i| i.id == orig_meta_node_id}
        node_to_comms_links = self.get_node_to_comms_links node
        neighbour_meta_nodes = @@meta_nodes.find_all {|i| node_to_comms_links.include? i.id}

        orig_meta_node.remove node, node_to_comms_links[orig_meta_node_id]
        best_meta_id = orig_meta_node_id
        max_gain = 0.0

        neighbour_meta_nodes.each do |m_node|
          mod_gain = self.modularity_gain(node, m_node, node_to_comms_links[m_node.id])
          #puts "\t\tfor comm #{m_node.id} mod increase is #{mod_gain}"
          if mod_gain > max_gain
            max_gain = mod_gain
            best_meta_id = m_node.id
          end
        end
        if best_meta_id != orig_meta_node_id
          nb_moves += 1
        end

        best_meta = @@meta_nodes.find{|m| m.id == best_meta_id}
        puts "\t\tbest comm #{best_meta.id}"

        best_meta.insert node, node_to_comms_links[best_meta.id]
        @@n2c[node] = best_meta_id
      end
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

  class MetaNode
    attr_accessor :in, :tot, :nodes_ids, :id
    @@count = 0
    def initialize node_id
      @id = @@count
      @@count+=1
      #@nodes_ids = [trust_node.id]
      @nodes_ids = [node_id]
      @in = 0 # sum of links weights inside the community
      #@tot = trust_node.symmetric_links # sum of links weights incident to the community
      @tot = Louvian.get_adj(node_id).count # sum of links weights incident to the community
    end

    def insert node, links_to_comm
      puts "\t\tinsert node #{node} to comm #{@id}"
      @nodes_ids << node
      @in += links_to_comm
      @tot += Louvian.get_adj(node).count - links_to_comm
    end

    def remove node, links_to_comm
      puts "\t\tremove node #{node} to comm #{@id}"
      @nodes_ids.delete node
      @in -= links_to_comm
      @tot -= Louvian.get_adj(node).count - links_to_comm
    end

  end
end
s='0 1
0 8
1 4
1 8
2 3
2 5
2 7
3 8
5 6
5 7'

Louvian.init_env s 
