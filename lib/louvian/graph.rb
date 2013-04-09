class Louvian::Graph

  attr_accessor :adj_list, :nodes, :communities, :directed, :n2c, :total_weight
  def initialize edges_list, directed

    # Adjacency list
    @adj_list = Louvian::Graph.make_adj edges_list, directed

    # List of all nodes
    @nodes = @adj_list.keys.sort

    # List of all communities (meta_nodes)
    @communities = []

    # whether the graph is diercted or not
    @directed = false

    # node_id => community_id
    @n2c = {}

    @adj_list.each do |k, v|
      @communities << Louvian::Community.new({k: v})
      @n2c[k] = @communities.last.id
    end

    # Sum of all links half edges (double the number of edges)
    @total_weight = @adj_list.inject(0) {|r,(k,v)| r+v.count}
  end

  # This method builds the adjacency list from list of edges
  # @param list [Array] in the form of [src dest] (edge per cell)
  # @param directed, whether the edge list is directed or not
  def self.make_adj edges_list, directed
    adj = {}
    edges_list.each do |edge|
      adj[edge[0]] ||= []
      adj[edge[1]] ||= []

      adj[edge[0]] << edge[1]
      if not directed
        adj[edge[1]] << edge[0]
      end
    end
    adj
  end

  def get_neighbour_nodes node
    neighbour = adj_list[node]
  end

  def get_neighbour_comms node
    node_to_comms_links = get_node_to_comms_links node

    neighbour_communities = @communities.find_all {|comm| node_to_comms_links.include? comm.id}
  end

  def get_community node
    @communities.find {|comm| comm.id == @n2c[node]}
  end

  # This method gets all neighbour communities and the number of links from node
  # to all neighbou communities
  # @param node to be considered
  # @return node_to_comms_links [Hash] {community => number_of_links from node
  # to community}
  def get_node_to_comms_links node
    neighbour_nodes = get_neighbour_nodes node
    node_to_comms_links = {}
    neighbour_nodes.each do |n|
      node_to_comms_links[@n2c[n]] = (node_to_comms_links[@n2c[n]] || 0) + 1
    end
    node_to_comms_links[@n2c[node]] ||= 1
    return node_to_comms_links
  end

  def get_number_of_links from_node, to_comm
    get_node_to_comms_links(from_node)[to_comm.id]
  end

  # This method calcualtes the current modularity of the communities
  # @returns q [Float] which is the modularity
  def modularity
    q = 0.0
    m2 = @total_weight

    @communities.each do |m_node|
      q += m_node.in.to_f/m2 - (m_node.tot.to_f/m2 * m_node.tot.to_f/m2)
    end
    q
  end

  # This method calcualtes the modularity gain for moving +node+ to community
  # @param node this is the node to be moved
  # @param community this is the destination community
  # @param nb_links_to_comm is the number of links from +node+ to community
  # @returns delta_q (the gain of modularity)
  def modularity_gain node, community
    nb_links_to_comm = 
    tot = community.tot
    deg = get_adj(node).count
    m2 = @total_weight

    #puts "\t\t\tcomm #{community.id} #{[tot, deg, m2, nb_links_to_comm]}"
    # what makes sense
    #return (nb_links_to_comm.to_f/m2) - (tot * deg.to_f/m2**2/2)

    # copied from the cpp code
    return nb_links_to_comm.to_f - tot*deg.to_f/m2
  end
end
