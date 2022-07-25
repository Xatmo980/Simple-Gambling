local MGuI = 44332235
local BGuI = 44332240
local MaxRollNumber = 100     -- How High the max Roll Number is
local WinMultiplier = 5       -- How much to multiply a Win
local BidAmount = ""
local WinNumb = ""
local Numb = ""
Win = 0
local Gamble = {}

Gamble.Main = function(pid)
      if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
         if BidAmount == nil then
            BidAmount = 0
         end
      tes3mp.CustomMessageBox(pid, MGuI, color.DarkOrange.."Your Gold (" .. Gamble.GoldGetAmount(pid) .. ")\n" .. "Your Bid (" .. BidAmount .. ")", "SetBid;Roll;Close")
      end
end

Gamble.Results = function(pid)
      if Win == 1 then
         tes3mp.CustomMessageBox(pid, MGuI, color.DarkOrange.."Your Gold (" .. Gamble.GoldGetAmount(pid) .. ")\n" ..  "Your Bid (" .. BidAmount .. ")\n\n" .. color.Green .. "You Win!!(" .. BidAmount .. ") x " .. WinMultiplier .. "\n" .. "Winning Number (" .. WinNumb .. ")", "SetBid;Roll;Close")
      else
         tes3mp.CustomMessageBox(pid, MGuI, color.DarkOrange.."Your Gold (" .. Gamble.GoldGetAmount(pid) .. ")\n" .. "Your Bid (" .. BidAmount .. ")\n\n" .. color.Red .. "You Lose!!("  .. BidAmount .. ")\n" .. "Winning Number (" .. WinNumb .. ")\n You Got (" .. Numb .. ")", "SetBid;Roll;Close")
      end
end

Gamble.GoldGetAmount = function(pid)
    local goldIndex

    if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", "gold_001", true) then
        goldIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", "gold_001")

        return Players[pid].data.inventory[goldIndex].count
    end

    return 0
end

Gamble.GoldSetAmount = function(pid, gold)
    local goldIndex

    if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", "gold_001", true) then
        goldIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", "gold_001")

        Players[pid].data.inventory[goldIndex].count = gold
        Players[pid]:Save()
        Players[pid]:LoadInventory()
        Players[pid]:LoadEquipment()
    end
end

Gamble.SetBid = function(pid)
       tes3mp.InputDialog(pid, BGuI, color.DarkOrange.."How Much Gold?","Enter the amount of gold")
end

Gamble.Roll = function(pid)
 local G = Gamble.GoldGetAmount(pid)
         if BidAmount <= G then
            math.randomseed(os.time() + tonumber(tostring({}):sub(8)))
            WinNumb = math.floor(math.random(MaxRollNumber))
            Numb = math.floor(math.random(MaxRollNumber))
            if Numb == WinNumb then
               Win = 1
               Gamble.GoldSetAmount(pid, G + (BidAmount * WinMultiplier))
               Gamble.Results(pid)
               return Win
            else
               Win = 0
               Gamble.GoldSetAmount(pid, G - BidAmount)
               Gamble.Results(pid)
               return Win
            end 
         else
            tes3mp.MessageBox(pid, -1, "You are out of Gold. Cannot place bid!")
            return
   end
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
    local isValid = eventStatus.validDefaultHandler
    if isValid ~= false then
        if idGui == MGuI then
           if tonumber(data) == 0 then
              Gamble.SetBid(pid)
              return
           elseif tonumber(data) == 1 then
              Gamble.Roll(pid)
              return
           elseif tonumber(data) == 2 then
	      --Do nothing
	      return
	   end
        end
       if idGui == BGuI then
          if data ~= nil then
             BidAmount = tonumber(data)
              if BidAmount == nil then
                 tes3mp.MessageBox(pid, -1, "You can only post numbers!")
                 return
              else
                 Gamble.Main(pid)
                 return
              end
          end
       end
     end
end)

customCommandHooks.registerCommand("gamble", Gamble.Main)
