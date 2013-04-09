class Louvian::Community
  attr_accessor :in, :tot, :nodes_ids, :id
  @@count = 0
  def initialize adj_list
    @id = @@count
    @@count+=1
    @nodes_ids = [adj_list.keys]

    # sum of links weights inside the community
    @in = adj_list.select {|k,v| nodes_ids.include? k}.inject(0) {|r,(k,v)| r+v.count}

    # sum of links weights incident to the community
    @tot = adj_list.inject(0) {|r,(k,v)| r+v.count}
  end 

  def self.reset
    @@count = 0
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
