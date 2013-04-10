class Louvian::Community
  attr_accessor :in, :tot, :nodes_ids, :id
  @@count = 0
  def initialize adj_list, level
    #puts "Adj list is "
    @id = @@count
    @@count+=1

    # TODO NO NEED TO SORT
    @nodes_ids = adj_list.keys.sort
    @level = level

    # sum of links weights inside the community
    #@in = adj_list.select {|k,v| nodes_ids.include? k}.inject(0) {|r,(k,v)| r+v.count}

    @in = 0
    adj_list.each do |node, neighbors|
      @in += neighbors.select {|node| @nodes_ids.include? node}.values.inject(0,:+)
    end

    # sum of links weights inside the community
    @tot = 0
    adj_list.each do |node, links|
      @tot += links.values.inject(0, :+)
    end

  end

  def self.reset
    @@count = 0
  end

  def insert node, node_adj, links_from_community
    links_to_comm = node_adj.select {|n| @nodes_ids.include? n}.values.inject(0,:+)

    @nodes_ids << node
    # Copied from the cpp code
    @in += links_to_comm + links_from_community + (node_adj[node] || 0)
    @tot += node_adj.values.inject(0,:+)

  end

  def remove node, node_adj, links_from_community
    @nodes_ids.delete node
    links_to_comm = node_adj.select {|n| @nodes_ids.include? n}.values.inject(0,:+)

    #puts "linksto t-com  #{links_to_comm}"
    # Copied from the cpp code
    @in -= (links_to_comm + links_from_community + (node_adj[node] || 0))
    @tot -= node_adj.values.inject(0,:+)

  end

end
