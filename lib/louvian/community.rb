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
      @in += neighbors.select {|node| @nodes_ids.include? node}.count
    end

    # sum of links weights incident to the community
    @tot = adj_list.inject(0) {|r,(k,v)| r+v.count}
  end

  def self.reset
    @@count = 0
  end

  def insert node, node_adj
    #puts "\t\tinsert node #{node} to comm #{@id}"
    @nodes_ids << node

    # what makes sense
    #@in += links_to_comm
    #@tot += (Louvian.get_adj(node).count - links_to_comm)

    links_to_comm = node_adj.select {|n| nodes_ids.include? n}.count
    # Copied from the cpp code
    @in += 2*links_to_comm
    @tot += node_adj.count
  end

  def remove node, node_adj
    #puts "\t\tremove node #{node} to comm #{@id}"
    @nodes_ids.delete node

    # what makes sense
    #@in -= links_to_comm
    #@tot -= (Louvian.get_adj(node).count - links_to_comm)

    links_to_comm = node_adj.select {|n| nodes_ids.include? n}.count
    # Copied from the cpp code
    @in -= 2*links_to_comm
    @tot -= node_adj.count
  end

end
