local GrdCtl={}

local s=require("sequins")
local MusicUtil = require("musicutil")


function GrdCtl:new(args)
  local m=setmetatable({},{
    __index=GrdCtl
  })
 m:init()
  return m
end

function GrdCtl:init()
    -- setup grid 
    local g_=include("grdctl/lib/ggrid")
    self.seqs={}
    self.clocks={}
    self.g=g_:new({self_=self,add_sequence=self.add_sequence,get_sequences=self.get_sequences})
    -- setup params
    print("setting up parameters for grdctl")
    for i=1,16 do 
        params:add_group("step "..i,3)
        params:add_number(i.."pitch","pitch",-30,30,0,nil,true)
        params:add_number(i.."strength","strength",-30,30,0,nil,true)
        params:add_number(i.."duration","duration",-30,30,0,nil,true)
        -- TODO add options for changing the range for each
    end


    self.duration_quantized={}
    for i=1,32 do 
        table.insert(self.duration_quantized,i/16)
        table.insert(self.duration_quantized,i/16)
    end
    for i=1,32 do 
        table.insert(self.duration_quantized,i/16)
        table.insert(self.duration_quantized,i/16)
    end
    self.notes = MusicUtil.generate_scale_of_length(20, 5, 61)
    self.transpose=0
end

function GrdCtl:get_sequences()
    local seqs={}
    for i,v in ipairs(self.seqs) do 
        table.insert(seqs,{seq=v.data,cur=v.data[v.ix]})
    end
    return seqs
end

function GrdCtl:add_sequence(sequence)
    print("add_sequence")
    tab.print(sequence)
    local seq=s(sequence)
    table.insert(self.seqs,seq)
    table.insert(self.clocks,clock.run(function()
        while true do 
            local step=seq()
            -- local duration=util.linlin(-30,30,1/32,2,params:get(step.."duration"))
            local duration=self.duration_quantized[params:get(step.."duration")+31]
            local pitch=util.clamp(params:get(step.."pitch")+31+self.transpose,1,#self.notes)
            local note=self.notes[pitch]
            local amp=util.linlin(-30,30,0,1,params:get(step.."strength"))
            if step>8 then
                self.transpose=params:get(step.."pitch")
                print(self.transpose)
            else
                engine.amp(amp)
                engine.hz(MusicUtil.note_num_to_freq(note))
            end
            clock.sleep(clock.get_beat_sec()*duration)    
        end
    end))
end


return GrdCtl
