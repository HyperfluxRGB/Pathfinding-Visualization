Map map;

float w;
float h;

PVector A;
PVector B;

void setup()
{
  map = new Map(40, 40);
  
  do
  {
    A = new PVector(round(random(0, map.Width)), round(random(0, map.Height)));
    B = new PVector(round(random(0, map.Width)), round(random(0, map.Height)));
  } while (A.equals(B));
  
  for(int i = 0; i < map.Width; i++)
  {
    for(int j = 0; j < map.Height; j++)
    {
      map.GetNode(i, j).Blocked = !(new PVector(i, j).equals(A)) && !(new PVector(i, j).equals(B)) && random(1) < 0.3f;
    }
  }
  
  size(1000, 1000);
  
  frameRate(20);
  
  w = width / (float) (map.Width + 2);
  h = height / (float) (map.Height + 2);
  println(w, h);
}

void draw()
{
  background(255);
  stroke(0);
  strokeWeight(6);
  for(int i = 0; i < map.Width; i++)
  {
    for(int j = 0; j < map.Height; j++)
    {
      MapNode node = map.GetNode(i, j);
      if(node.Blocked)
      {
        point((node.Position.x + 1) * w, (node.Position.y + 1) * h);
      }
    }
  }
  
  strokeWeight(13);
  stroke(0, 0, 255);
  
  point((A.x + 1) * w, (A.y + 1) * h);
  point((B.x + 1) * w, (B.y + 1) * h);
  
  strokeWeight(6);
  
  ArrayList<PVector> path = map.ReconstructPath();
  
  if(path != null)
  {
    stroke(255, 182, 193);
    
    for(int i = 0; i < path.size() - 1; i++)
    {      
      PVector pos1 = path.get(i);
      PVector pos2 = path.get(i + 1);
      
      line((pos1.x + 1) * w, (pos1.y + 1) * h, (pos2.x + 1) * w, (pos2.y + 1) * h);
    }
  }
  
  map.FindPath(A, B);
}
