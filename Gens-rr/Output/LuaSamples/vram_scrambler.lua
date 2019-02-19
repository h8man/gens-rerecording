-- VRAM scramber's goal is to coolect Plane information,
-- and serialize it with apropriate VScrol and HSroll shifts
-- essentially to serialize lvl tiles posotion

function writebytes(f,x)
    local b2=string.char(x%256) x=(x-x%256)/256;
    local b1=string.char(x%256) x=(x-x%256)/256;
    f:write(b1);
	f:write(b2);
end

function us2si(ss)
  if(AND(ss,0x8000) == 0x8000) then --negative
    ss = ss-0xFFFF;
  end
  return ss;
end

function display()
  local basex = 200;
  local basey = 200;
  gui.text(basex,basey,"VDP");
  gui.text(basex+15,basey,"HEX");
  gui.text(basex+50,basey,"INT");
  gui.text(basex+80,basey,"TILE");
  gui.text(basex+100,basey,"DIR");
  gui.text(basex   ,basey+10,"HS:");
  gui.text(basex+15,basey+10,string.format("0x%X",uHS)); 
  gui.text(basex+50,basey+10,string.format("(%i)",iHS)); 
  gui.text(basex   ,basey+20,"VS:");
  gui.text(basex+15,basey+20,string.format("0x%X",uVS));
  gui.text(basex+50,basey+20,string.format("(%i)",iVS));   

  gui.text(basex+80,basey+10,HS8);
  gui.text(basex+80,basey+20,VS8);
  
  if(iHS<0) then
	gui.text(basex+100,basey+10,"R");  
  else
    gui.text(basex+100,basey+10,"L")
  end
  if(iVS<0) then
    gui.text(basex+100,basey+20,"U"); 
  else
    gui.text(basex+100,basey+20,"D");  
  end
  
end
-- initialize
print("VRAM Scramble - START")
print(vdp);

N=300; --1000 to the left and 1000 tj the right 
Path = "D:\\Workspace\\"

PlaneB = 0xE000;
PlaneA = 0xC000;

PLANE = PlaneA;

hNTSC40 = 40;
vNTSC40 = 28;

hPlane = 64;
vPlane = 32;

wBaseX = 0x11;
wBaseY = 0x1F;

mt = {}
for i=1,N do
  mt[i] = {}     -- create a new row
  for j=1,N do
    mt[i][j] = 0x4fb
  end
end
  
gens.registerafter( function()
  -- put any code you want to run after each frame here
  -- (such as getting the last frame's input or reading from memory)

  uHS = vdp.readwordvram(0x0000);
  uVS = vdp.readwordvsram(0x0000);

  iHS = -us2si(uHS);
  iVS = us2si(uVS);
  
  HS8 = math.floor(iHS/8) % hPlane;
  VS8 = math.floor(iVS/8) % vPlane;
  
  display();
  
  tile_x = math.floor(iHS/8)+math.floor(N/2);
  tile_y = math.floor(iVS/8)+math.floor(N/2);
  
  if(true) then 
    --return -1;
  end
  
  for i=0, (hNTSC40-1) , 1 do
    for j=0, (vNTSC40-1), 1 do
	  h_offset = (i+HS8)%hPlane;
	  v_offset = (j+VS8)%vPlane;

	  tile_index = vdp.readwordvram(PLANE+2*h_offset+2*v_offset*hPlane);
	  mt[tile_x+i][tile_y+j]=tile_index;
	end
  end  
  
end)

gens.registerexit( function()
  -- cleanup code (if any) goes here
  local f = io.open(Path .. "tmp.bytes","wb");
  for j=1, N do
   for i=1, N do
    writebytes(f,mt[i][j]);
   end
  end  
  f:close();
end) 