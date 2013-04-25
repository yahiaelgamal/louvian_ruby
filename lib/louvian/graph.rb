class Louvian::Graph

  attr_accessor :adj_list, :nodes, :communities, :directed, :n2c, :total_weight, :level
  def initialize edges_list, directed, level
    # Adjacency list
    @adj_list = Louvian::Graph.make_adj edges_list, directed

    # List of all nodes
    # TODO remove sort
    @nodes = @adj_list.keys.sort

    # List of all communities (meta_nodes)
    @communities = []

    # whether the graph is diercted or not
    @directed = false

    # node_id => community_id
    @n2c = {}

    @level = level
    # TODO remove sort
    @adj_list.sort.each do |k, v|
      @communities << Louvian::Community.new({k => v}, @level)
      @n2c[k] = @communities.last.id
    end

    # Sum of all links half edges (double the number of edges)
    @total_weight = 0
    @adj_list.each do |node, links|
      @total_weight += links.values.inject(0, :+)
    end
  end

  # This method builds the adjacency list from list of edges
  # @param list [Array] in the form of [src dest] (edge per cell)
  # @param directed, whether the edge list is directed or not
  # @return hash of hashes {src => {dest1 => weight1, dest1 => weight1}}
  def self.make_adj edges_list, directed
    adj = {}
    edges_list.each do |edge|
      adj[edge[0]] ||= {}

      adj[edge[1]] ||= {}

      adj[edge[0]][edge[1]] = (adj[edge[0]][edge[1]] || 0 ) + (edge[2] || 1)
      if not directed
        adj[edge[1]][edge[0]]  = (adj[edge[1]][edge[0]] || 0 ) + (edge[2] || 1)
      end
    end
    adj
  end

  def get_neighbour_nodes node
    neighbours = adj_list[node]
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
    neighbour_nodes.each do |n, weight|
      node_to_comms_links[@n2c[n]] = (node_to_comms_links[@n2c[n]] || 0) + weight
    end
    node_to_comms_links[@n2c[node]] ||= 0
    return node_to_comms_links
  end

  # OPTIMIZE
  def get_number_of_links from_node, to_comm
    get_node_to_comms_links(from_node)[to_comm.id]
  end

  # This method calcualtes the current modularity of the communities
  # @returns q [Float] which is the modularity
  def modularity verbose=false
    q = 0.0
    m2 = @total_weight
    puts "m2 #{m2},  comms #{@communities.count}" if verbose
    @communities.each do |comm|
      puts " in #{comm.in}, tot #{comm.tot}"  if verbose
      q += comm.in.to_f/m2 - (comm.tot.to_f/m2 * comm.tot.to_f/m2)
    end
    q
  end

  # This method calcualtes the modularity gain for moving +node+ to community
  # @param node this is the node to be moved
  # @param community this is the destination community
  # @param nb_links_to_comm is the number of links from +node+ to community
  # @returns delta_q (the gain of modularity)
  def modularity_gain node, community
    nb_links_to_comm = (get_number_of_links node, community) || 0
    #puts "node #{node}, comm #{community.id}"
    #puts "####################{nb_links_to_comm}"

    tot = community.tot
    deg = @adj_list[node].values.inject(0,:+)
    m2 = @total_weight

    # copied from the cpp code
    return nb_links_to_comm.to_f - tot*deg.to_f/m2
  end

  # This method outputs information about communities
  def display_communities
    @communities.each do |m|
      puts "#{m.id} => #{m.nodes_ids} in=#{m.in} tot=#{m.tot}"
    end
    nil
  end

  def get_links_from_comm_to_node community, node
    links = 0
    nodes = community.nodes_ids - [node]
    nodes.each do |n|
      links+=@adj_list[n].select {|adj| adj == node}.values.inject(0,:+)
    end
    links
  end

  def insert_node node, comm
    comm.insert node, @adj_list[node], (get_links_from_comm_to_node comm, node)
    @n2c[node] = comm.id
  end

  def remove_node node, comm
    comm.remove node, @adj_list[node], (get_links_from_comm_to_node comm, node)
    @n2c[node] = -1
  end

  def garbage_collect community
    if  community.nodes_ids.empty?
      @communities.delete community
    end
  end

  def build_graph_from_comms
    comm_edges = []

    @communities.each do |comm|
      comm.nodes_ids.each do |node|
        @adj_list[node].each do |linked_node, weight|
          if not comm.nodes_ids.include? linked_node
            comm_edges << [comm.id, @n2c[linked_node], weight]
          end
        end
      end
      comm_edges << [comm.id, comm.id, comm.in]
    end
    return Louvian::Graph.new comm_edges, true, @level+1
  end

  def expand! lower_graph
    comm_2_nodes = lower_graph.communities.inject({}) {|r,comm| r[comm.id]= comm.nodes_ids;r}
    new_graph_nodes = []
    @communities.each do |comm|
      new_comm_nodes = []
      comm.nodes_ids.each do |node|
        new_comm_nodes += comm_2_nodes[node]
        comm_2_nodes[node].each do |low_node|
          @n2c[low_node] = comm.id
        end
      end
      comm.nodes_ids = new_comm_nodes
      new_graph_nodes += new_comm_nodes
    end
    @nodes = new_graph_nodes
  end
end
