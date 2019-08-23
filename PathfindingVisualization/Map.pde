class Map
{
  MapNode[] Nodes;
  
  int Width;
  int Height;
  
  boolean finished;
  
  public Map(int mapwidth, int mapheight)
  {
    if(mapwidth > 0)
    {
      this.Width = mapwidth;
    }
    else
    {
      throw new IllegalArgumentException("Width has to be greater than 0.");
    }
    
    if(mapheight > 0)
    {
      this.Height = mapheight;
    }
    else
    {
      throw new IllegalArgumentException("Height has to be greater than 0.");
    }
    
    this.Nodes = new MapNode[this.Width * this.Height];
    
    for(int i = 0; i < this.Width * this.Height; i++)
    {
      this.Nodes[i] = new MapNode(0, 0, false, new PVector(i % this.Width, floor(i / this.Width)));
    }
    
    Reset();
  }
  
  public float Heuristic(PVector a, PVector b)
  {
    //return abs(a.x - b.x) + abs(a.y - b.y);
    return dist(a.x, a.y, b.x, b.y);
  }
  
  void Reset()
  {
    openset = new ArrayList<MapNode>();
    closedset = new ArrayList<MapNode>();
    finished = false;
    firstiteration = true;
  }
  
  ArrayList<MapNode> openset; // nodes that are currently being evaluated
  ArrayList<MapNode> closedset; // nodes that have been evaluated;
  
  ArrayList<PVector> currentpath;
  
  MapNode current;
  
  boolean firstiteration;
  
  public void FindPath(PVector start, PVector end)
  {
    MapNode startnode = GetNode((int)start.x, (int)start.y);
    MapNode endnode = GetNode((int)end.x, (int)end.y);
    
    if(firstiteration)
    {
      startnode.g = 0; // to get from the start node to the start node doesn't take any time
      startnode.h = Heuristic(start, end); // add the guessed time from start to end#
      // h score of startnode isn't actually needed because it will be removed immediately
      openset.add(startnode); // at the beginning only the startnode is beeing evaluated
      firstiteration = false;
    }
    
    if(finished)
    {
      return; 
    }
    
    if(openset.size() > 0) // if there are still nodes to be evaluated then continue
    {
      // get the node with the lowes f score value (current)
      current = openset.get(0);
      
      for(MapNode mn : openset)
      {
        if(mn.f() < current.f())
        {
          current = mn;
        }
      }
      
      if(current == endnode) // end has been found, return the path
      {
        finished = true;
        return;
      }
      
      // remove the current node from the openset and add it to the closedset
      
      openset.remove(current);
      closedset.add(current);
      
      // discover new nodes
      
      ArrayList<MapNode> currentneighbours = GetNeighbours((int) current.Position.x, 
        (int) current.Position.y);
        
      for(MapNode neighbour : currentneighbours)
      {
        if(neighbour.Blocked && !neighbour.Position.equals(end))
        {
          continue; // Blocked nodes cannot be taken for a route so skip the node
        }
        
        if(closedset.contains(neighbour))
        {
          continue; // if node has been evaluated then skip the node
        }
      
        float tentativegscore = current.g + 1; // how long it takes to get to the node
        
        if(!openset.contains(neighbour))
        {
          // no potential better gscore so the node can be added to the open set
          openset.add(neighbour);
        }
        else
        {
          // a node was rediscoverd, check if the new gscore is better
          if(tentativegscore >= neighbour.g)
          {
            continue; // gscore wasn't better so skip this node
          }
        }
        
        neighbour.g = tentativegscore;
        neighbour.h = Heuristic(neighbour.Position, end);
        // reference the previous node for path reconstruction
        neighbour.Previous = current;        
      }
    }
  }
  
  public ArrayList<PVector> ReconstructPath()
  {
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    if(current != null)
    {
      // go through all of the nodes backwards and reconstruct the path
      MapNode pathnode = current;
      do
      {
        path.add(0, pathnode.Position);
        pathnode = pathnode.Previous;
      } while(pathnode != null);
    }
    
    return path;
  }
  
  public ArrayList<MapNode> GetNeighbours(int x, int y)
  {
    if(!WithinBorders(x, y))
    {
      throw new IllegalArgumentException("Position outside of borders.");
    }
    
    ArrayList<MapNode> neighbours = new ArrayList<MapNode>();
    
    // check if the node has a neighbour in each direction and then add it
    
    if(x > 0)
    {
      neighbours.add(GetNode(x - 1, y));
    }
    
    if(x < this.Width - 1)
    {
      neighbours.add(GetNode(x + 1, y));
    }
    
    if(y > 0)
    {
      neighbours.add(GetNode(x, y - 1));
    }
    
    if(y < this.Height - 1)
    {
      neighbours.add(GetNode(x, y + 1));
    }
    
    return neighbours;
  }
  
  public boolean WithinBorders(int x, int y)
  {
    return ((x >= 0) && (x < this.Width)) && ((y >= 0) && (y < this.Height));
  }
  
  public MapNode GetNode(int x, int y)
  {
    if(!WithinBorders(x, y))
    {
      throw new IllegalArgumentException("Position outside of borders.");
    }
    
    return Nodes[x + y * this.Width];
  }
}
