class Louvian::Community
  attr_accessor :in, :tot, :nodes_ids, :id
  @@count = 0
  def initialize node_id
    @id = @@count
    @@count+=1
    @nodes_ids = [node_id]
    @in = 0 # sum of links weights inside the community
    @tot = Louvian.get_adj(node_id).count # sum of links weights incident to the community
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
