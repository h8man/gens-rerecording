-- VRAM scramber's goal is to coolect Plane information,
-- and serialize it with apropriate VScrol and HSroll shifts
-- essentially to serialize lvl tiles position

function writebytes(f,x)
    local b2=string.char(x%256) x=(x-x%256)/256;
    local b1=string.char(x%256) x=(x-x%256)/256;
    f:write(b1);
	f:write(b2);
end

--unsigned short to signed short (16 bits)
function us2si(ss)
  if(AND(ss,0x8000) == 0x8000) then --negative
    ss = ss-0xFFFF;
  end
  return ss;
end

--display debug info and screen scroll coorinates
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

function writeAll(tiles, Nx, Ny, file_stream)
  for j=1, Nx do
   for i=1, Ny do
    writebytes(file_stream,tiles[i][j]);
   end
  end
end

-- initialize
print("VRAM Scramble - START")
print(vdp);

N=500; -- -N to the left and N tj the right 
Path = "D:\\Workspace\\"


PlaneB = 0xE000; --specific to game renderer mode
PlaneA = 0xC000; --specific to game renderer mode

--PLANE = PlaneA;

hNTSC40 = 40; --specific to game renderer mode
vNTSC40 = 28; --specific to game renderer mode

hPlane = 64; --specific to game renderer mode
vPlane = 32; --specific to game renderer mode

mtA = {}
for i=1,N do
  mtA[i] = {}     -- create a new row
  for j=1,N do
    mtA[i][j] = 0x4fb --empty value
  end
end
mtB = {}
for i=1,N do
  mtB[i] = {}     -- create a new row
  for j=1,N do
    mtB[i][j] = 0x4fb --empty value
  end
end
  
gens.registerafter( function()
  -- put any code you want to run after each frame here
  -- (such as getting the last frame's input or reading from memory)

  uHS = vdp.readwordvram(0x0000); --usigned horizontal scroll value
  uVS = vdp.readwordvsram(0x0000); --usigned vertical scroll value

  iHS = -us2si(uHS);
  iVS = us2si(uVS);
  
  --pixels to tiles 8x8
  HS8 = math.floor(iHS/8) % hPlane;
  VS8 = math.floor(iVS/8) % vPlane;
  
  display();
  
  --tile global coordinates in grid
  tile_x = math.floor(iHS/8)+math.floor(N/2);
  tile_y = math.floor(iVS/8)+math.floor(N/2);
  
  if(true) then 
    --return -1;
  end
  
  for i=0, (hNTSC40-1) , 1 do
    for j=0, (vNTSC40-1), 1 do
	  h_offset = (i+HS8)%hPlane;
	  v_offset = (j+VS8)%vPlane;
	  --un-flatern array
	  tile_index = vdp.readwordvram(PlaneA+2*h_offset+2*v_offset*hPlane);
	  mtA[tile_x+i][tile_y+j]=tile_index;
	  
	  tile_index = vdp.readwordvram(PlaneB+2*h_offset+2*v_offset*hPlane);
	  mtB[tile_x+i][tile_y+j]=tile_index;
	end
  end  
  
end)

gens.registerexit( function()
  -- cleanup code (if any) goes here
  local f1 = io.open(Path .. "PlaneA.bytes","wb");
  writeAll(mtA, N, N, f1);
  f1:close();
  local f2 = io.open(Path .. "PlaneB.bytes","wb");
  writeAll(mtB, N, N, f2);
  f2:close();
end) 