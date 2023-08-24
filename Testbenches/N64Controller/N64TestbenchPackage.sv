package N64TestbenchPackage;
	
parameter logic [8:0] POLL_COMMAND = 9'b110000000;
  class N64CommandPacket;
    rand logic [33:0] command;
  endclass
	
endpackage